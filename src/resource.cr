require "./site"
require "uri"
require "crinja"
require "./generator"
require "./frontmatter"
require "./paginator"

@[::Crinja::Attributes(expose: [slug, directory, content, paginator, categories])]
class Criss::Resource
  include ::Crinja::Object::Auto
  include Comparable(Resource)

  getter site : Site
  getter slug : String
  getter directory : String?
  getter content : String?
  getter frontmatter : Frontmatter
  getter defaults : Frontmatter
  getter? has_frontmatter : Bool
  property updated_at : Time? = nil
  property? created_at : Time? = nil
  property generator : Generator? = nil
  property collection : Collection? = nil
  property paginator : Paginator? = nil

  def initialize(@site : Site, @slug : String, @content : String? = nil, @directory : String? = nil,
                 frontmatter : Frontmatter? = Frontmatter.new, @defaults : Frontmatter = Frontmatter.new)

    @has_frontmatter = !frontmatter.nil?
    @frontmatter = frontmatter || Frontmatter.new
  end

  def [](key : String) : YAML::Any
    @frontmatter.fetch(key) do
      defaults[key]? || @collection.try(&.defaults[key]?) || raise KeyError.new "Missing resource frontmatter key: #{key.inspect}"
    end
  end

  def []?(key : String) : YAML::Any?
    @frontmatter.fetch(key) do
      defaults[key]? || @collection.try(&.defaults[key]?)
    end
  end

  def has_key?(key : String) : Bool
    @frontmatter.has_key?(key) || defaults.has_key?(key) || @collection.try(&.defaults.has_key?(key)) || false
  end

  @[Crinja::Attribute]
  def title : String?
    self["title"]?.try &.to_s
  end

  @[Crinja::Attribute]
  def name : String?
    if slug = @slug
      File.basename(slug)
    end
  end

  @[Crinja::Attribute]
  def basename : String?
    if slug = @slug
      File.basename(slug, File.extname(slug))
    end
  end

  @[Crinja::Attribute]
  def extname : String?
    if slug = @slug
      File.extname(slug)
    end
  end

  @[Crinja::Attribute]
  getter date : Time do
    if date = self["date"]?
      date.raw.as(Time)
    elsif date = date_and_shortname_from_slug.first
      date
      # elsif @slug && File.exists?(@slug)
      #   File.mtime(@slug)
    else
      Time.now.at_beginning_of_day
    end
  end

  getter url : URI do
    permalink = self["permalink"]?
    if permalink
      path = expand_permalink(permalink.as_s)
    else
      path = String.build do |io|
        io << '/'
        if slug = @slug
          io << File.dirname(slug)
          io << '/'
        end

        if basename != "index"
          io << basename
          if output_ext != ".html"
            io << output_ext
          end
        end
      end
    end

    base = @site.url
    # scheme = self["scheme"]
    # domain = self["domain"]

    # @url = if domain && base.host == @site.config["host"] && base.port == @site.config["port"]
    #   base.merge("/" + domain + path).to_s
    if base.relative?
      URI.parse(path)
    else
      # base.hostname = domain unless domain.nil?
      # base.scheme   = scheme unless scheme.nil?
      # base.merge(path)
      URI.parse(path)
    end
  end

  @[Crinja::Attribute]
  def permalink : String
    if permalink = self["permalink"]?
      permalink = permalink.as_s
      unless permalink.starts_with?('/')
        permalink = "/#{permalink}"
      end
      return permalink
    end

    dir = "/"
    if slug = self.slug
      dir = File.expand_path(File.dirname(slug), dir)
    end

    File.expand_path("#{basename}#{output_ext}", dir)
  end

  def crinja_attribute(value : Crinja::Value) : Crinja::Value
    case value.to_string
    when "url"
      return Crinja::Value.new(url.to_s)
    when "date"
      return Crinja::Value.new(date)
    end

    result = super

    if result.undefined?
      key = value.to_string
      if @frontmatter.has_key?(key)
        return Crinja::Value.new @frontmatter.fetch(key)
      end
    end

    result
  end

  getter categories : Array(String) do
    if (categories = self["categories"]?) && (categories = categories.raw)
      if categories.is_a?(Array)
        return categories.map(&.to_s).reject(&.empty?)
      elsif categories.is_a?(String)
        return categories.split(' ', remove_empty: true)
      end
    end
    if (category = self["category"]?) && (category = category.raw)
      if category.is_a?(String) && !category.empty?
        return [category]
      end
    end

    return [] of String
  end

  def output_path(output_dir : String) : String
    output_path = expand_permalink(permalink)
    if output_path.ends_with?('/')
      output_path = "#{output_path}/index#{output_ext || ".html"}"
    elsif File.extname(output_path).empty? && has_key?("permalink") && (output_ext = self.output_ext)
      output_path += output_ext
    end

    File.expand_path(output_path.byte_slice(1, output_path.bytesize), File.join(output_dir, self["domain"]?.to_s))
  end

  def output_ext : String?
    extname = self.extname

    if extname && has_frontmatter?
      site.pipeline_builder.output_ext(extname) || extname
    else
      extname
    end
  end

  def <=>(other : Resource)
    if (date = self.date) && (other_date = other.date)
      ret = other_date <=> date
      return ret unless ret == 0
    end

    slug <=> other.slug
  end

  def to_s(io)
    # io << self.class << "(" << @slug << ", " << content_type << ")"
    io << @slug
  end

  def date_and_shortname_from_slug : {Time?, String?}
    basename = self.basename

    if basename && (data = basename.match /^(?:(\d{2}\d{2}?)-(\d{1,2})-(\d{1,2})-)?(.+)$/)
      if data[1]?
        date = Time.new(data[1].to_i, data[2].to_i, data[3].to_i)
      end
      name = data[4]
    end

    {date, name}
  end

  def expand_permalink(permalink : String)
    date, shortname = date_and_shortname_from_slug
    date ||= self.date

    permalink.gsub(/\{:(\w+)\}|:(\w+)/) do |string, match|
      variable = match[1]? || match[2]
      case variable
      # when "title"         then !has_frontmatter? ? name : data["slug"] || Util.slugify(date_and_basename_without_ext.last, preserve_case: true)
      when "title"      then shortname.to_s
      when "slug"       then shortname.to_s.downcase
      when "name"       then name
      when "basename"   then basename
      when "collection" then collection
      when "output_ext" then output_ext
        # when "num"           then data["paginator"].index

        # when "digest"        then Digest::MD5.hexdigest(output) rescue ""

      when "year"        then date.to_s("%Y")
      when "month"       then date.to_s("%m")
      when "day"         then date.to_s("%d")
      when "hour"        then date.to_s("%H")
      when "minute"      then date.to_s("%M")
      when "second"      then date.to_s("%S")
      when "i_day"       then date.to_s("%-d")
      when "i_month"     then date.to_s("%-m")
      when "short_month" then date.to_s("%b")
      when "short_year"  then date.to_s("%y")
      when "y_day"       then date.to_s("%j")
        # when "categories" then
        #   items = data["categories"].to_s
        #   items = items.split(" ") if items.is_a?(String)
        #   items.map { |category| Util.slugify(category) }.join("/")

      when "path"
        path = File.dirname(@slug)
        # if path.start_with?("/")
        #   path = Util.relative_path(path, File.expand_path(data["base_dir"] || ".", directory))
        # end
        path == "." ? "" : path
      else
        raise "Unknown permalink variable #{variable.dump}"
      end
    end
  end
end
