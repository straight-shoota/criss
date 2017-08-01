module Criss::Generator::Crinjad
  def load_template(path)
    frontmatter, content = Criss.read_frontmatter(context.root_path(path))
    template = Crinja::Template.new(content, context.crinja, path, path)

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
    if layout_name == "none"
      io << vars["content"]
      return
    end

    context.logger.debug "using layout #{layout_name}"
    frontmatter, layout = load_layout(layout_name)

    if parent_layout = frontmatter["layout"]?
      vars["content"] = Crinja::SafeString.build do |io|
        layout.render(io, vars)
      end
      layout = render_layout(io, parent_layout.as(String), vars)
    else
      layout.render(io, vars)
    end
  end

  macro def_generate
    def generate(io, path, file_path)
      context.logger.debug "Rendering file_path #{file_path}"

      frontmatter, template = load_template(file_path)
      context.logger.debug "frontmatter: #{frontmatter.inspect}"
      frontmatter = default_frontmatter(path).merge(Crinja.cast_hash(frontmatter))

      vars = context.default_variables.merge(default_variables(path))

      {{ yield }}

      vars["content"] = Crinja::SafeString.build do |io|
        template.render(io, vars)
      end

      render_layout(io, frontmatter["layout"].as(String), vars)
    end
  end

  abstract def default_frontmatter(path)

  def default_variables(path)
    {} of String => Type
  end
end
