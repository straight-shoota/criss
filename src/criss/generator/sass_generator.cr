require "sass"

class Criss::SassGenerator
  include Generator::Base
  def initialize(context)
    super(context)
    @compiler = Sass::Compiler.new(include_path: context.root_path("_sass"))
  end

  def matches?(path)
    if File.extname(path) == ".css"
      file_path = context.root_path(path.rchop(".css") + ".scss")
      return file_path if File.file?(file_path)
    end
  end

  def generate(io, path, file_path)
    _frontmatter, scss_source = Criss.read_frontmatter(file_path)
    scss = @compiler.compile(scss_source)

    io << scss
  end

  def content_type(path, file_path)
    "text/css"
  end
end
