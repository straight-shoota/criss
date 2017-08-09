abstract class Criss::Entry
  include ::Crinja::PyObject

  getter request_path : String
  property content_type : String
  property frontmatter = Frontmatter.new

  def initialize(@request_path, @content_type = "text/html")
  end

  def default_variables(context)
    Crinja::Variables.new
  end

  def default_frontmatter(context)
    Frontmatter{
      "url" => context.url_for(request_path),
      "path" => request_path,
    }
  end

  def to_s(io)
    io << self.class
    io << "("
    io << request_path
    io << ", "
    io << content_type
    io << ")"
  end

  macro inherited
    ::Crinja::PyObject.getattr
  end
end

require "./file_entry"
