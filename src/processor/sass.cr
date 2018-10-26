require "sass"
require "../processor"

class Criss::Processor::Sass < Criss::Processor
  transforms "sass": "css", "scss": "css"

  getter include_path : String

  def self.new(site : Site)
    new(File.join(site.config.source, "_sass"), site.site_dir)
  end

  def initialize(@include_path : String = "_sass", @site_dir : String = ".")
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

    rendered = ::Sass.compile(input.gets_to_end, include_path: File.join(@site_dir, include_path), is_indented_syntax_src: indented_syntax)
    output << rendered

    true
  end
end
