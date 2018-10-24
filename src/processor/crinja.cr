require "crinja"
require "../processor"
require "../crinja_lib"

class Criss::Processor::Crinja < Criss::Processor
  transforms "crinja": "*", "jinja": "*", "liquid": "*"

  getter crinja : ::Crinja

  def initialize(site = nil)
    @crinja = ::Crinja.new
    @crinja.config.liquid_compatibility_mode = true
  end

  def process(resource : Resource, input : IO, output : IO) : Bool
    template = ::Crinja::Template.new(input.gets_to_end, crinja, resource.name || "", resource.slug || "")
    vars = ::Crinja.variables({
      "page" => resource,
      "site" => resource.site,
    })

    template.render(output, vars)

    true
  end
end
