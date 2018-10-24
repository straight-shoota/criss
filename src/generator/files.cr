class Criss::Generator::Files < Criss::Generator
  def initialize(@site : Site)
  end

  def generate : Nil
    search_path = File.expand_path(site.config.source, site.site_dir)
    Files.load_files(File.join(search_path, "**/*"), search_path) do |slug, content, frontmatter|
      defaults = site.defaults_for(slug, "pages")
      resource = Criss::Resource.new(site, slug, content, frontmatter: frontmatter, defaults: defaults)
      resource.generator = self

      site.files << resource
    end
  end

  def self.load_files(glob, directory)
    Dir.glob(glob) do |full_path|
      next if File.directory?(full_path)

      slug = full_path.lchop(directory).lchop('/')

      next if slug.starts_with?('_')
      # TODO: Don't traverse hidden directories in the first place.
      next if slug.includes?("/_")

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
