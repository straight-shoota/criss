class Criss::Entry
  getter request_path : String
  getter file_path : String
  property frontmatter = Frontmatter.new
  getter slug : String

  def initialize(@request_path, @file_path)
    @slug = File.basename(file_path, File.extname(file_path))
  end

  def default_variables(context)
    Crinja::Variables.new
  end

  def content_type
    "text/html"
  end

  def default_frontmatter(context)
    Frontmatter{
      "url" => context.url_for(request_path),
      "path" => request_path,
    }
  end
end

require "./page"
require "./post"
