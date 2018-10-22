Crinja.filter(:date_to_string) do
  value = target.raw
  if value.is_a?(Time)
    value.to_s "%d %b %Y"
  else
    value
  end
end

Crinja.filter(:markdownify) do
  Crinja::SafeString.new(Markd.to_html(target.to_s))
end

# TODO: Implement
Crinja.filter(:relative_path) do
  target
end

class Crinja::Tag::Unless < Crinja::Tag::If
  name "unless", "endunless"

  private def interpret(io : IO, renderer : Crinja::Renderer, tag_node : TagNode)
    env = renderer.env
    current_branch_active = !evaluate_node(tag_node, env)

    tag_node.block.children.each do |node|
      if (tnode = node).is_a?(TagNode) && tnode.name == "else"
        break if current_branch_active

        current_branch_active = true
      else
        renderer.render(node).value(io) if current_branch_active
      end
    end
  end
end

Crinja::Tag::Library::TAGS << Crinja::Tag::Unless

class Crinja::Tag::Assign < Crinja::Tag::Set
  name "assign"
end

Crinja::Tag::Library::TAGS << Crinja::Tag::Assign
