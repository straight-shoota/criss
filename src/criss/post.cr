class Criss::Post < Criss::FileEntry
  def default_variables
    Crinja::Variables{
      "post" => Crinja.cast_dictionary(frontmatter),
      "page" => Crinja.cast_dictionary(frontmatter),
    }
  end

  def target_extension
    ".html"
  end

  def content_type
    "text/html"
  end

  def default_frontmatter
    super.merge Frontmatter{
      "layout" => "post",
      "excerpt" => "TODO"
    }
  end

  def date
    frontmatter["date"]? || file_mtime
  end

  #::Crinja::PyObject.getattr

  def getattr(attr : Crinja::Value)
    val = previous_def
    if val.is_a?(Crinja::Undefined)
      frontmatter[attr]? || Crinja::Undefined.new(attr.to_s)
    else
      val
    end
  end

  def target_path(&default_value : -> String)
    super do
      "posts/#{slug}.html"
    end
  end
end
