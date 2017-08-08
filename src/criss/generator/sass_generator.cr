class Criss::SassGenerator
  include Generator::Base

  @processor : Processor?
  def processor
    processor = @processor
    processor || (@processor = Processor.build_chain([
        Processor::Sass.new(context),
        Processor::Crinja.new(context),
        Processor::Frontmatter.new(context),
      ]))
  end

  def matches?(path)
    if File.extname(path) == ".css"
      file_path = path.rchop(".css") + ".scss"
      return file_path if File.file?(context.root_path(file_path))
    end
  end

  def content_type(entry)
    "text/css"
  end
end
