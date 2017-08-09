class Criss::FileEntry < Criss::Entry
  getter file_path : String
  getter slug : String
  getter file_size : UInt64
  getter file_mtime : Time

  def initialize(request_path, @file_path, @file_mtime, @file_size, content_type = "text/html")
    super(request_path)
    @slug = ::File.basename(file_path, ::File.extname(file_path))
  end

  def self.new(request_path, file_path, context : Context, content_type = "text/html")
    stat = ::File.stat(context.root_path(file_path))
    file_mtime = stat.mtime
    file_size = stat.size
    new(request_path, file_path, file_mtime, file_size, content_type)
  end
end

require "./page"
require "./post"
