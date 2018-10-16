require "crinja"
require "../processor"

class Criss::Processor::Crinja < Criss::Processor
  transforms "crinja": "*", "jinja": "*", "liquid": "*"

  getter crinja = ::Crinja.new

  def initialize(site = nil)
  end

  def process(resource : Resource, input : IO, output : IO) : Bool
    template = ::Crinja::Template.new(input.gets_to_end, crinja, resource.name || "", resource.slug || "")
    vars = ::Crinja.variables({
      "page" => resource
    })

    template.render(output, vars)

    true
  end
end
