abstract class Criss::Entry
  include ::Crinja::PyObject

  getter request_path : String
  property frontmatter = Frontmatter.new

  def initialize(@request_path)
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

  macro inherited
    ::Crinja::PyObject.getattr
  end
end

require "./file_entry"
