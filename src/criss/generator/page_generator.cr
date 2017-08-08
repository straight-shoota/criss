class Criss::PageGenerator
  include Generator::Base

  HTML_FILE_EXTENSIONS = {".html", ".htm"}
  CONTENT_FILE_EXTENSIONS = Processor::Markdown::FILE_EXTENSIONS + HTML_FILE_EXTENSIONS

  @processor : Processor?
  def processor
    processor = @processor
    processor || (@processor = Processor.build_chain([
        Processor::Crinja.new(context),
        Processor::Markdown.new(context),
        Processor::Frontmatter.new(context),
      ]))
  end

  def file_path(path)
    if file?(path)
      if CONTENT_FILE_EXTENSIONS.includes? File.extname(path)
        return path
      end

      context.logger.debug "File #{path} is served as static file"

      return nil
    end

    index_path = path.rchop('/')
    index_path += '/' unless path.empty?
    index_path += "index"
    ext_path = test_file_path_extensions(index_path)
    return ext_path if ext_path

    extname = File.extname(path)
    path =  path.rchop(extname) if HTML_FILE_EXTENSIONS.includes?(extname)

    ext_path = test_file_path_extensions(path.rchop('/'))
    return ext_path if ext_path

    context.logger.debug "No file for #{path}"

    nil
  end

  protected def create_entry(path, match_result)
    Page.new(path, match_result)
  end

  private def test_file_path_extensions(path)
    CONTENT_FILE_EXTENSIONS.each do |ext|
      ext_path = path + ext
      return ext_path if file?(ext_path)
    end
  end

  private def file?(file)
    File.file?(context.root_path(file))
  end

  def matches?(path)
    file_path(path)
  end
end
