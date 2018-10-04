require "markd"

class Criss::Processor::Markdown
  include Processor
  FILE_EXTENSIONS = {".md", ".markdown"}

  def process(entry, input, output)
    unless FILE_EXTENSIONS.includes? File.extname(entry.source_path)
      return process_next(entry, input, output)
    end

    source = String.build do |io|
      process_next(entry, input, io)
    end

    rendered = Markd.to_html(source)
    output << rendered
  end
end
