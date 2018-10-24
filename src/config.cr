require "yaml"
require "./frontmatter"

class Criss::Config
  class Collection
    include YAML::Serializable
    include YAML::Serializable::Unmapped

    property? output : Bool = true

    def initialize
    end

    def [](key : String) : YAML::Any
      yaml_unmapped[key]
    end

    def []?(key : String) : YAML::Any?
      yaml_unmapped[key]?
    end

    def []=(key : String, value : YAML::Any) : YAML::Any
      yaml_unmapped[key] = value
    end

    def []=(key : String, value : YAML::Any::Type) : YAML::Any
      self[key] = YAML::Any.new(value)
    end

    def has_key?(key : String) : Bool
      yaml_unmapped.has_key?(key)
    end

    def ==(other : Collection)
      {% for field in @type.instance_vars %}
        return false unless @{{field.id}} == other.@{{field.id}}
      {% end %}
      true
    end

    def hash(hasher)
      {% for field in @type.instance_vars %}
        hasher = @{{field.id}}.hash(hasher)
      {% end %}
      hasher
    end
  end

  class Defaults
    include YAML::Serializable

    property scope : Scope = Criss::Config::Scope.new

    property values : Criss::Frontmatter = Criss::Frontmatter.new

    def initialize(@scope : Scope = Scope.new, @values : Criss::Frontmatter = Criss::Frontmatter.new)
    end

    def ==(other : Collection)
      {% for field in @type.instance_vars %}
        return false unless @{{field.id}} == other.@{{field.id}}
      {% end %}
      true
    end

    def hash(hasher)
      {% for field in @type.instance_vars %}
        hasher = @{{field.id}}.hash(hasher)
      {% end %}
      hasher
    end
  end

  struct Scope
    include YAML::Serializable

    getter path : String? = nil

    getter type : String? = nil

    def initialize(@path : String? = nil, @type : String? = nil)
    end
  end

  def initialize(@site_dir : String = ".")
    merge_defaults
  end

  include YAML::Serializable
  include YAML::Serializable::Unmapped

  property site_dir : String = "."
  property source : String = "."
  property destination : String = "_site"
  property collections_dir : String = "."

  # property plugins_dir : String = "_plugins"
  property layouts_dir : String = "_layouts"
  property data_dir : String = "_data"
  property includes_dir : String = "_includes"

  # TODO: Add support for Array(String)
  property collections : Hash(String, ::Criss::Config::Collection) = {} of String => ::Criss::Config::Collection

  # Handling Reading
  # property? safe : Bool = false
  property include : Array(String) = [".htaccess"]
  property exclude : Array(String) = %w(
    Gemfile Gemfile.lock node_modules vendor/bundle/ vendor/cache/ vendor/gems/
    vendor/ruby/
  )
  property keep_files : Array(String) = [".git", ".svn"]
  property encoding : String = "utf-8"
  property markdown_ext : String = "markdown,mkdown,mkdn,mkd,md"
  # property? strict_front_matter : Bool = false

  # Filtering Content
  # property show_drafts : Nil = nil
  # property limit_posts : Int32 = 0
  property? future : Bool = false
  property? unpublished : Bool = false

  # Plugins
  # property whitelist : Array(String) = [] of String
  # property plugins : Array(String) = [] of String

  # Conversion
  # property markdown : String = "kramdown"
  # property highlighter : String = "rouge"
  # property lsi : Bool = false
  property excerpt_separator : String = "\n\n"
  # property icremental : Bool = false

  # Serving
  property? detach : Bool = false # default to not detaching the server
  property port : Int32 = 4000
  property host : String = "127.0.0.1"
  property baseurl : String = ""
  property? show_dir_listing : Bool = true

  property? livereload : Bool = true
  property livereload_port : Int32 = 35729

  # Output Configuration
  property permalink : String = "date"
  property paginate_path : String = "/page:num"
  property timezone : String? = nil # use the local timezone

  property? quiet : Bool = false
  property? verbose : Bool = false
  property defaults : Array(Criss::Config::Defaults) = [] of Criss::Config::Defaults

  # property liquid
  #   property error_mode : String = "warn"
  #   property strict_filters : Bool = false
  #   property strict_variables : Bool = false
  # },

  # "kramdown"            => {
  #   property auto_ids : Bool = true
  #   property toc_levels : String = "1..6"
  #   property entity_output : String = "as_char"
  #   property smart_quotes : String = "lsquo,rsquo,ldquo,rdquo"
  #   property input : Bool = "GFM"
  #   property hard_wrap : Bool = false
  #   property footnote_nr : String = 1
  #   property show_warnings : Bool = false

  def ==(other : Config)
    {% for field in @type.instance_vars %}
      return false unless @{{field.id}} == other.@{{field.id}}
    {% end %}
    true
  end

  def hash(hasher)
    {% for field in @type.instance_vars %}
      hasher = @{{field.id}}.hash(hasher)
    {% end %}
    hasher
  end

  def merge_defaults
    posts = collections["posts"] ||= Config::Collection.new
    posts["permalink"] ||= "/posts/:year-:month-:day-:title/"
    posts["layout"] ||= "post"
  end

  def self.load_file(filename : String) : Config
    File.open(filename, "r") do |io|
      from_yaml(io).tap do |config|
        config.merge_defaults
      end
    end
  end

  def self.load(site_dir : String, alternatives : Enumerable = {"_config.yml", ".criss/config.yml"})
    alternatives.each do |filename|
      full_path = File.join(site_dir, filename)
      if File.exists?(full_path)
        return load_file(full_path).tap do |config|
          config.site_dir = site_dir
        end
      end
    end

    raise "Could not find CRISS config file in #{site_dir} (looking for #{alternatives.join(", ")})"
  end
end
