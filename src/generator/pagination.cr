class Criss::Generator::Pagination < Criss::Generator
  getter priority : Priority = Priority::LOW

  def initialize(site : Site)
    super(site)
  end

  def generate : Nil
    paginator_resources = [] of Resource
    site.files.each do |resource|
      if config = resource["paginate"]?
        paginate_resource(resource, config, paginator_resources)
      end
    end
    site.files.concat paginator_resources

    site.collections.each_value do |collection|
      paginator_resources = [] of Resource
      collection.resources.each do |resource|
        if config = resource["paginate"]?
          paginate_resource(resource, config, paginator_resources)
        end
      end
      collection.resources.concat paginator_resources
    end
  end

  def paginate_resource(resource : Resource, config : YAML::Any, paginator_resources : Array(Resource))
    per_page = config["per_page"]?.try(&.as_i) || 25
    permalink = config["permalink"]?.try(&.as_s)

    items = [] of Resource

    if key = config["collection"]?
      items = site.collections[key].resources
      permalink ||= "/#{key}/page/:num/"
    elsif key = config["data"]?
      raise "not implemented"
    end

    #if sort_property = config["sort_property"]?
    if config["sort"]?
      items.sort!
    end

    if config["sort_descending"]?
      items.reverse!
    end

    chunks = items.each_slice(per_page)
    pages = [] of Resource

    chunks.each_with_index do |chunk_items, i|
      paginator = Paginator.new(chunk_items, i + 1, pages)
      if i.zero?
        resource.paginator = paginator
        pages << resource
      else
        clone = Criss::Resource.new(site, resource.slug, resource.content, frontmatter: resource.frontmatter.clone, defaults: resource.defaults)
        clone.frontmatter.merge!(Frontmatter{"permalink" => permalink })
        clone.paginator = paginator
        pages << clone
        paginator_resources << clone
      end
    end

    pages.each_cons(2) do |cons|
      if paginator = cons[0].paginator
        paginator.next = cons[1]
        paginator.last = pages.last
      end
      if paginator = cons[1].paginator
        paginator.previous = cons[0]
        paginator.first = pages.first
      end
    end
  end
end
