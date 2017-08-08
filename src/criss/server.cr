require "crinja"
require "crinja/server"
require "yaml"

class Criss::Server
  DEFAULT_HOST = "0.0.0.0"
  DEFAULT_PORT = 3000

  property host : String = DEFAULT_HOST
  property port : Int32 = DEFAULT_PORT
  property logger : Logger = Logger.new(STDERR)

  getter! server : HTTP::Server
  getter! loader : Crinja::Loader
  getter context : Context
  getter! generators : Array(Generator)

  include Crinja::PyObject
  getattr host, port

  def initialize(@root_path = ".")
    @context = Context.new
    @context.generators = [
      SassGenerator.new(@context),
      PageGenerator.new(@context),
      PostGenerator.new(@context),
    ] of Generator
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

    handlers = [
      HTTP::ErrorHandler.new,
      HTTP::LogHandler.new,
      HTTP::StaticFileHandler.new(context.root_path, directory_listing: false),
      CrissHandler.new(context),
    ]

    @server = HTTP::Server.new(host, port, handlers)
  end
end

require "./server/criss_handler"
