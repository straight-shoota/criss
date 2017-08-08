require "sass"

class Criss::Processor::Sass
  include Processor

  FILE_EXTENSIONS = [".sass", ".scss"]

  def initialize(context)
    super(context)
    @compiler = ::Sass::Compiler.new(include_path: context.root_path("_sass"))
  end

  def process(entry, input, output)
    source = String.build do |io|
      process_next(entry, input, io)
    end

    rendered = @compiler.compile(source)
    output << rendered
  end
end
