require "crinja"
require "crinja/liquid"
require "../processor"
require "../crinja_lib"

class Criss::Processor::Layout < Criss::Processor
  alias Template = ::Crinja::Template

  transforms "*": "output"

  getter crinja : ::Crinja

  getter layouts_path : String

  getter layouts : Hash(String, {Template, Frontmatter})

  def initialize(@site : Site = Site.new, layouts_path : String? = nil, includes_path : String? = nil)
    @layouts_path = layouts_path || File.join(site.config.source, site.config.layouts_dir)
    includes_path ||= File.join(site.config.source, site.config.includes_dir)

    @layouts = Hash(String, {Template, Frontmatter}).new do |hash, key|
      hash[key] = load_layout(key)
    end

    @crinja = ::Crinja.liquid_support
    @crinja.loader = ::Crinja::Loader::FileSystemLoader.new(File.expand_path(includes_path, site.site_dir))
  end

  def process(resource : Resource, input : IO, output : IO) : Bool
    layout_name = resource["layout"]?.try &.as_s?

    if !layout_name || layout_name == "none"
      return false
    end

    content = input.gets_to_end

    while true
      layout_template, frontmatter = layouts[layout_name.to_s]

      variables = {
        "content" => ::Crinja::SafeString.new(content),
        "layout"  => ::Crinja.variables(frontmatter),
        "post"    => resource,
        "page"    => resource,
        "site"    => @site
      }

      layout_name = frontmatter["layout"]?

      if layout_name && layout_name != "none"
        content = layout_template.render(variables)
      else
        layout_template.render(output, variables)

        # Add a trailing newline
        output.puts
        break
      end
    end

    true
  end

  def load_layout(layout_name : String) : {Template, Frontmatter}
    file_pattern = File.join(File.expand_path(layouts_path, @site.site_dir), "#{layout_name}.*")
    file_path = Dir[file_pattern].first?

    raise "Layout not found: #{layout_name.inspect} (layouts_path: #{layouts_path}) at #{file_pattern}" unless file_path

    File.open(file_path) do |file|
      frontmatter = Frontmatter.read_frontmatter(file) || Frontmatter.new
      content = file.gets_to_end

      template = Template.new(content, crinja, layout_name, file_path)

      return template, frontmatter
    end
  end
end
