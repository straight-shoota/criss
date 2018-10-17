class Criss::Generator::Files < Criss::Generator
  def directory
    "_pages"
  end

  def generate : Nil
    search_path = File.join(site.site_dir, directory)
    Files.load_files(File.join(search_path, "**"), search_path) do |slug, content, frontmatter|
      resource = Criss::Resource.new(site, slug, content, frontmatter: frontmatter)
      resource.generator = self

      site.files << resource
    end
  end

  def self.load_files(glob, directory)
    Dir.glob(glob) do |full_path|
      slug = full_path.lchop(directory).lchop('/')
      frontmatter, content = load_content(full_path)

      yield slug, content, frontmatter
    end
  end

  def self.load_content(file_path) : {Frontmatter?, String}
    unless File.exists?(file_path)
      raise "File missing #{file_path}"
    end

    File.open(file_path, "r") do |file|
      frontmatter = Frontmatter.read_frontmatter(file)
      content = file.gets_to_end

      {frontmatter, content}
    end
  end
end
