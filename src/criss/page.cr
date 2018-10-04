class Criss::Page < Criss::FileEntry
  property excerpt : String?

  def default_variables
    Crinja::Variables{"page" => Crinja.cast_dictionary(frontmatter)}
  end

  def target_extension
    ".html"
  end

  def default_frontmatter
    super.merge Frontmatter{
      "layout"  => "page",
      "title"   => slug,
      "excerpt" => excerpt
    }
  end

  FILE_EXTENSIONS = {".html", ".htm", ".markdown", ".md"}

  def target_path(&default_value : -> String)
    super do
      default_path = yield
      FILE_EXTENSIONS.each do |ext|
        default_path = default_path.rchop(ext)
      end

      if File.basename(default_path) == "index"
        default_path = default_path[0...-5]
      end
      default_path + '/'
    end
  end
end
