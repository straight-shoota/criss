require "markd"
require "../processor"

class Criss::Processor::Markdown < Criss::Processor
  transforms "markdown": "html"

  file_extensions "markdown": {".md", ".markdown"}

  getter options = Markd::Options.new

  def initialize(site = nil)
  end

  def process(resource : Resource, input : IO, output : IO) : Bool
    rendered = Markd.to_html(input.gets_to_end, options)
    output << rendered

    true
  end
end
