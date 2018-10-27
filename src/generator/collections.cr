require "./files"

class Criss::Generator::Collections < Criss::Generator::Files
  def self.new(site : Site)
    collections_dir = File.join(site.config.source, site.config.collections_dir)
    paths = [] of String
    site.collections.each_key do |collection_name|
      directory = File.join(collections_dir, "_#{collection_name}")
      full_path = File.expand_path(directory, site.site_dir)

      if File.exists?(full_path)
        paths << directory
      elsif collections_dir != "."
        directory = File.join(collections_dir, collection_name)
        full_path = File.expand_path(directory, site.site_dir)

        if File.exists?(full_path)
          paths << directory
        end
      end
    end

    new(site, paths)
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
      collection_name = File.basename(collection_path).lchop('_')
      collection = site.collections.fetch(collection_name) do
        site.collections[collection_name] = Collection.new(collection_name)
      end

      real_path = File.expand_path(collection_path, site.site_dir)
      Files.load_files(File.join(real_path, "*"), real_path) do |slug, content, frontmatter|
        defaults = site.defaults_for(slug, collection_name)
        resource = Criss::Resource.new(site, slug, content, collection_path, frontmatter, defaults: defaults)
        resource.collection = collection
        collection.resources << resource
      end
    end
  end
end
