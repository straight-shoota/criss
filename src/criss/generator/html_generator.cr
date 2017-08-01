class Criss::HTMLGenerator
  include Generator::Base
  include Generator::Crinjad

  CONTENT_FILE_EXTENSIONS = {".html", ".htm"}

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
    index_path += "index.html"
    return index_path if file?(index_path)

    html_path = path.rchop('/') + ".html"
    return html_path if file?(html_path)

    context.logger.debug "No file for #{path}"

    nil
  end

  private def file?(file)
    File.file?(context.root_path(file))
  end

  def matches?(path)
    file_path(path)
  end

  def_generate do
    vars["page"] = frontmatter
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
