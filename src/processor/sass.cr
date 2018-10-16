require "sass"
require "../processor"

class Criss::Processor::Sass < Criss::Processor

  transforms "sass": "css", "scss": "css"

  getter include_path = "_sass"


  def initialize(site = nil)
  end

  def process(resource : Resource, input : IO, output : IO) : Bool
    case resource.extname
    when ".sass"
      indented_syntax = true
    when ".scss"
      indented_syntax = false
    else
      return false
    end

    rendered = ::Sass.compile(input.gets_to_end, include_path: include_path, is_indented_syntax_src: indented_syntax)
    output << rendered

    true
  end
end
