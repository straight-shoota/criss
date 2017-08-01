class Criss::PostGenerator
  include Generator::Base
  include Generator::Crinjad

  CONTENT_FILE_EXTENSIONS = {".md", ".html", ".htm"}

  def file_name(path)
    name = path.lchop("posts/").rchop('/').rchop(".html")
    file_glob = "_posts/#{name}.*"

    Dir[context.root_path file_glob].each do |file|
      return file.lchop(context.root_path) if File.file?(file) && CONTENT_FILE_EXTENSIONS.includes? File.extname(file)
    end
  end

  def matches?(path)
    if path.starts_with?("posts/")
      file_name(path)
    end
  end

  def_generate do
    vars["post"] = frontmatter
  end

  def content_type(path, file_path)
    "text/html"
  end

  def default_frontmatter(path)
    {
      "url" => context.url_for(path),
      "path" => path,
      "layout" => "post",
    } of Crinja::Type => Crinja::Type
  end
end
