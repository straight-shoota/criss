require "crinja"
require "../processor"

class Criss::Processor::Layout < Criss::Processor
  alias Template = ::Crinja::Template

  transforms "*": "output"

  getter crinja = ::Crinja.new

  getter layouts_path

  getter layouts : Hash(String, {Template, Frontmatter})

  def self.new(site : Site)
    new(File.expand_path("_layouts", site.source_path))
  end

  def initialize(@layouts_path : String = "_layouts")
    @layouts = Hash(String, {Template, Frontmatter}).new do |hash, key|
      hash[key] = load_layout(key)
    end
  end

  def process(resource : Resource, input : IO, output : IO) : Bool
    layout_name = resource["layout"]?
    if !layout_name || layout_name == "none"
      return false
    end

    content = input.gets_to_end

    while true
      layout_template, frontmatter = layouts[layout_name.to_s]

      variables = {
        "content" => ::Crinja::SafeString.new(content),
        "layout" => ::Crinja.variables(frontmatter),
        "post" => resource
      }

      layout_name = frontmatter["layout"]?

      if layout_name && layout_name != "none"
        content = layout_template.render(variables)
      else
        layout_template.render(output, variables)
        break
      end
    end

    true
  end

  def load_layout(layout_name : String) : {Template, Frontmatter}
    file_path = Dir[File.join(layouts_path, "#{layout_name}.*")].first?

    raise "Layout not found: #{layout_name}" unless file_path

    File.open(file_path) do |file|
      frontmatter = Frontmatter.read_frontmatter(file) || raise "empty frontmatter"
      content = file.gets_to_end

      template = Template.new(content, crinja, layout_name, file_path)

      return template, frontmatter
    end
  end
end
