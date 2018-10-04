abstract class Criss::Entry
  include ::Crinja::PyObject
  include Comparable(Entry)

  property site : Site
  getter path : String
  property content_type : String? = nil
  property frontmatter : Frontmatter

  private def initialize(@site, @path, frontmatter)
    @frontmatter = default_frontmatter.merge(frontmatter)
  end

  def default_variables
    Crinja::Variables.new
  end

  delegate :[], :[]?, to: @frontmatter

  def default_frontmatter
    Frontmatter{
      "url"  => site.url_for(@path),
      "path" => @path,
      "dir"  => dir,
    }
  end

  def dir
    if @path.ends_with?('/')
      @path
    else
      target_dir = File.dirname(@path)
      target_dir.ends_with?('/') ? target_dir : target_dir + '/'
    end
  end

  def <=>(other : Entry)
    @path <=> other.path
  end

  def to_s(io)
    io << self.class << "(" << @path << ", " << content_type << ")"
  end
end

require "./file_entry"
