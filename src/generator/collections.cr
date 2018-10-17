require "./files"

class Criss::Generator::Collections < Criss::Generator::Files
  def self.new(site : Site)
    new(site, ["_posts"])
  end

  def self.new(site : Site, directory : String) : Collections
    collection_paths = [] of String
    Dir.new(directory).each_child do |name|
      path = File.join(directory, name)
      next unless File.directory?(path)
      collection_paths << path
    end

    new(site, collections_paths)
  end

  def initialize(site : Site, @collection_paths : Array(String))
    super(site)
  end

  def generate : Nil
    @collection_paths.each do |collection_path|
      name = File.basename(collection_path).lchop('_')
      collection = site.collections.fetch(name) do
        site.collections[name] = Collection.new
      end

      real_path = File.expand_path(collection_path, site.site_dir)
      Files.load_files(File.join(real_path, "*"), real_path) do |slug, content, frontmatter|
        resource = Criss::Resource.new(site, slug, content, collection_path, frontmatter)
        resource.collection = collection
        resource.generator = self
        collection << resource
      end
    end
  end
end
