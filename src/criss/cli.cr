require "option_parser"
require "./server"

module Criss::CLI
  def self.display_help_and_exit(opts)
    puts "Crekyll [options]"
    puts
    puts "Options:"
    puts opts
    exit
  end

  def self.run(options = ARGV)
    server = Criss::Server.new

    OptionParser.parse(options) do |opts|
      path = Dir.current

      opts.on("--version", "") { puts Criss::VERSION; exit }
      opts.on("-v", "--verbose", "") { server.logger.level = Logger::Severity::DEBUG }
      opts.on("-q", "--quiet", "") { server.logger.level = Logger::Severity::WARN }
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
      server.handler.list_entries.each do |entry|
        puts entry.inspect
      end
    else
      puts "unrecognised command: #{command}"
    end
  end
end
