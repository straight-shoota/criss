class Criss::Page < Criss::Entry
  def default_variables(context)
    Crinja::Variables{"page" => Crinja.cast_hash(frontmatter)}
  end

  def content_type
    "text/html"
  end

  def default_frontmatter(context)
    super.merge Frontmatter{
      "layout" => "page",
      "title"  => slug
    }
  end
end
