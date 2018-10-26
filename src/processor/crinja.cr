require "crinja"
require "crinja/liquid"
require "../processor"
require "../crinja_lib"

class Criss::Processor::Crinja < Criss::Processor
  transforms "crinja": "*", "jinja": "*", "liquid": "*"

  getter crinja : ::Crinja

  def self.new(site : Site)
    new(
      File.join(site.config.source, site.config.includes_dir),
      site.site_dir)
  end

  def initialize(includes_dir : String = "_includes", site_dir : String = ".")
    @crinja = ::Crinja.liquid_support
    @crinja.loader = ::Crinja::Loader::FileSystemLoader.new(File.join(site_dir, includes_dir))
  end

  def process(resource : Resource, input : IO, output : IO) : Bool
    template = ::Crinja::Template.new(input.gets_to_end, crinja, resource.name || "", resource.slug || "")
    vars = ::Crinja.variables({
      "page" => resource,
      "site" => resource.site,
      "paginator" => resource.paginator,
    })

    template.render(output, vars)

    true
  end
end
