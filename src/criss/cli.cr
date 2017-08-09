require "option_parser"
require "./server"
require "./site_generator"

module Criss::CLI
  def self.display_help_and_exit(opts)
    puts "Crekyll [options]"
    puts
    puts "Options:"
    puts opts
    exit
  end

  def self.run(options = ARGV)
    context = Context.new
    server = Criss::Server.new(context)

    OptionParser.parse(options) do |opts|
      path = Dir.current

      opts.on("--version", "") { puts Criss::VERSION; exit }
      opts.on("-v", "--verbose", "") { context.logger.level = Logger::Severity::DEBUG }
      opts.on("-q", "--quiet", "") { context.logger.level = Logger::Severity::WARN }
      opts.on("-h", "--help", "") { self.display_help_and_exit(opts) }
      opts.on("-b HOST", "--bind=HOST", "Bind to host (default: #{Server::DEFAULT_HOST}") do |host|
        server.host = host
      end
      opts.on("-p PORT", "--port=PORT", "Bind to port (default #{Server::DEFAULT_PORT}") do |port|
        server.port = port.to_i
      end
      opts.on("-e VAR", "--extra-vars=VAR", "Set variables as `key=value`") do |var|
        key, value = var.split('=')
        server.context.crinja.context[key] = value
      end
    end

    case command = options.shift?
    when "serve", nil
      server.start
    when "list"
      server.handler.each_entry do |entry|
        puts entry
      end
    when "build"
      generator = SiteGenerator.new
      generator.generate_all
    else
      puts "unrecognised command: #{command}"
    end
  end
end
