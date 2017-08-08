class Criss::Post < Criss::FileEntry
  def default_variables(context)
    Crinja::Variables{
      "post" => Crinja.cast_hash(frontmatter)
    }
  end

  def content_type
    "text/html"
  end

  def default_frontmatter(context)
    super.merge Frontmatter{
      "layout" => "post",
    }
  end
end
