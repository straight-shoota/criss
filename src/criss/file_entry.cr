abstract class Criss::FileEntry < Criss::Entry
  getter source_path : String
  getter slug : String
  getter file_size : UInt64
  getter file_mtime : Time
  getter content : String
  getter source_extension : String

  def initialize(@site : Site, @source_path : String, @content : String, @file_mtime : Time, @file_size : UInt64, @frontmatter : Frontmatter = Frontmatter.new)
    @source_extension = File.extname(source_path)
    @slug = File.basename(source_path, @source_extension)
    @path = target_path { source_path }
    @frontmatter = default_frontmatter.merge(@frontmatter) # this is needed to allow `default_frontmatter` access to file frontmatter
  end

  def self.new(site : Site, source_path : String, content : String? = nil)
    file_path = site.source_path(source_path)

    unless File.exists?(file_path)
      raise "File not found (#{source_path})"
    end

    File.open(file_path, "r") do |file|
      frontmatter = FrontmatterReader.read_frontmatter(file) || Frontmatter.new
      content ||= file.gets_to_end

      frontmatter = Crinja.cast_variables(frontmatter)

      new(site, source_path, content, frontmatter)
    end
  end

  def self.new(site : Site, source_path : String, content : String, frontmatter : Frontmatter)
    file_path = site.source_path(source_path)
    stat = File.stat(file_path) rescue raise "File not found #{source_path} (#{file_path})"
    file_mtime = stat.mtime
    file_size = stat.size

    new(site, source_path, content, file_mtime, file_size, frontmatter)
  end

  def target_path(&default_value : -> String)
    if permalink = frontmatter["permalink"]?
      permalink.to_s
    else
      yield
    end
  end

  def default_frontmatter
    super.merge Frontmatter{
      "date" => date,
      "file_size" => file_size.to_i64,
      "file_mtime" => file_mtime,
      "source_path" => source_path,
      "content" => content,
      "slug"    => slug,
      "name"    => File.basename(source_path),
    }
  end

  def to_s(io)
    io << self.class
    io << "("
    io << path
    io << ", "
    io << source_path
    io << ")"
  end

  def date
    file_mtime
  end
end

require "./page"
require "./static_page"
require "./post"
require "./sass_file"
