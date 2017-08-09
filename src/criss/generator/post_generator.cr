class Criss::PostGenerator
  include Generator::Base(Post)

  FILE_EXTENSIONS = Processor::Markdown::FILE_EXTENSIONS + {".html", ".htm"}

  @processor : Processor?
  def processor
    processor = @processor
    processor || (@processor = Processor.build_chain([
        Processor::Crinja.new(context),
        Processor::Markdown.new(context),
        Processor::Frontmatter.new(context),
      ]))
  end

  def each_entry
    file_glob = "_posts/*"

    Dir[context.root_path(file_glob)].each do |file|
      if(file_name_matches?(file))
        file = file.lchop(context.root_path)
        yield create_entry(path_for(file), file)
      end
    end
  end

  def path_for(file)
    file = file.sub("_posts", "posts")
    FILE_EXTENSIONS.each do |ext|
      file = file.rchop(ext)
    end
    file += "/"
    file
  end

  def file_name(path)
    name = path.lchop("posts/").rchop('/').rchop(".html")
    file_glob = "_posts/#{name}.*"

    Dir[context.root_path file_glob].each do |file|
      return file.lchop(context.root_path) if file_name_matches?(file)
    end
  end

  protected def create_entry(path, match_result)
    Post.new(path, match_result, context)
  end

  private def file_name_matches?(file)
    File.file?(file) && FILE_EXTENSIONS.includes? File.extname(file)
  end

  def matches?(path)
    if path.starts_with?("posts/")
      file_name(path)
    end
  end

  private def render_template(template, vars)
    rendered = super
    path = template.filename
    if path && MARKDOWN_FILE_EXTENSIONS.includes?(File.extname(path))
      process_markdown(rendered)
    else
      rendered
    end
  end
end
