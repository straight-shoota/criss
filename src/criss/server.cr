require "colorize"
require "./server/log_pretty_handler"

class Criss::Server
  DEFAULT_HOST = "0.0.0.0"
  DEFAULT_PORT = 3000

  property host : String = DEFAULT_HOST
  property port : Int32 = DEFAULT_PORT

  getter! server : HTTP::Server
  getter site : Site
  getter! handler : CrissHandler

  include Crinja::PyObject
  getattr host, port

  def initialize(@site)
  end

  def start
    setup

    url = "http://#{host}:#{port}".colorize(:cyan)

    begin
      server.bind
    rescue e : Errno
      STDERR.puts "Criss server could not bind to #{url}"
      raise e
    end

    puts "Criss server is listening on #{url}"

    server.listen
  end

  def setup
    return unless @server.nil?

    @handler = CrissHandler.new()

    handlers = [
      HTTP::ErrorHandler.new,
      LogPrettyHandler.new(STDOUT, colors: site.config.use_colors?),
      #HTTP::StaticFileHandler.new(site.source_path, directory_listing: false),
      handler,
    ]

    @server = HTTP::Server.new(host, port, handlers)
  end
end

require "./server/criss_handler"
