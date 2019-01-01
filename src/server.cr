require "http/server"

class Criss::Server
  getter site : Site

  def self.new(site)
    uri = URI.new("tcp", site.config.host, site.config.port, site.config.baseurl)

    new(site, uri)
  end

  def initialize(@site : Site, @uri : String | URI)
    @server = HTTP::Server.new [
      HTTP::ErrorHandler.new,
      Handler.new(@site)
    ]
  end

  def start
    address = @server.bind @uri

    puts "Listening on #{address}"

    @server.listen
  end

  class Handler
    include HTTP::Handler

    def initialize(@site : Site)
    end

    def call(context : HTTP::Server::Context)
      path = context.request.path

      # if path.ends_with?('/')
      #   path = path + "index.html"
      # end

      resource = @site.find(path)

      unless resource
        context.response.respond_with_error "Not Found", code: 404
        context.response.close
        return
      end

      @site.run_processor(context.response, resource)
    end
  end


  # DEFAULT_HOST = "0.0.0.0"
  # DEFAULT_PORT = 3000

  # property host : String = DEFAULT_HOST
  # property port : Int32 = DEFAULT_PORT

  # getter! server : HTTP::Server
  # getter site : Site
  # getter! handler : CrissHandler

  # getattr host, port

  # def initialize(@site)
  # end

  # def start
  #   setup

  #   url = "http://#{host}:#{port}".colorize(:cyan)

  #   begin
  #     server.bind
  #   rescue e : Errno
  #     STDERR.puts "Criss server could not bind to #{url}"
  #     raise e
  #   end

  #   puts "Criss server is listening on #{url}"

  #   server.listen
  # end

  # def setup
  #   return unless @server.nil?

  #   @handler = CrissHandler.new

  #   handlers = [
  #     HTTP::ErrorHandler.new,
  #     LogPrettyHandler.new(STDOUT, colors: site.config.use_colors?),
  #     # HTTP::StaticFileHandler.new(site.source_path, directory_listing: false),
  #     handler,
  #   ]

  #   @server = HTTP::Server.new(host, port, handlers)
  # end
end
