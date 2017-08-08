require "crinja"

class Criss::Processor::Crinja
  include Processor
  delegate crinja, to: context

  def load_template(path)
    file_path = context.root_path(path)
    unless File.readable?(file_path)
      raise ::Crinja::TemplateNotFoundError.new(path)
    end
    file = File.read(file_path)
    frontmatter, content = Processor::Frontmatter.read_frontmatter(file)
    template = ::Crinja::Template.new(content, crinja, path, path)

    return frontmatter, template
  end

  def layout_path(path)
    File.join("_layouts", path)
  end

  def load_layout(name)
    file = layout_path(name + ".html")
    load_template(file)
  end

  def render_layout(io, layout_name, vars)
    if !layout_name || layout_name == "none"
      io << vars["content"]
      return
    end

    #context.logger.debug "using layout #{layout_name}"
    frontmatter, layout = load_layout(layout_name)

    if parent_layout = frontmatter["layout"]?
      vars["content"] = ::Crinja::SafeString.build do |io|
        layout.render(io, vars)
      end
      layout = render_layout(io, parent_layout.as(String), vars)
    else
      layout.render(io, vars)
    end
  end

  def process(entry, input, output)
    source = String.build do |io|
      process_next(entry, input, io)
    end

    template = ::Crinja::Template.new(source, crinja, entry.request_path, entry.file_path)
    vars = context.default_variables.merge(entry.default_variables(context))

    vars["content"] = render_template(template, vars)

    layout = entry.frontmatter["layout"]?.as(String?)
    render_layout(output, layout, vars)
  end

  private def render_template(template, vars)
    ::Crinja::SafeString.build do |io|
      template.render(io, vars)
    end
  end
end
