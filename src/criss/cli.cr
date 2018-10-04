require "option_parser"
#require "./server"
require "./renderer"

module Criss::CLI
  def self.display_help_and_exit(opts)
    puts <<-USAGE
      criss [command] [options]

      Commands:
          build                build site
          serve                serve site
          help, --help, -h     show this help
          version, --version   show version

      Options:
      USAGE

    puts opts
    exit
  end

  def self.run(options = ARGV)
    logger = Logger.new(STDOUT)
    source_path = "."

    options_parser = OptionParser.parse(options) do |opts|
      path = Dir.current

      opts.on("--version", "") { display_version_and_exit }
      opts.on("-v", "--verbose", "") { logger.level = Logger::Severity::DEBUG }
      opts.on("-q", "--quiet", "") { logger.level = Logger::Severity::WARN }
      opts.on("-h", "--help", "") { self.display_help_and_exit(opts) }
      #opts.on("-b HOST", "--bind=HOST", "Bind to host (default: #{Server::DEFAULT_HOST})") do |host|
      #  server.host = host
      #end
      #opts.on("-p PORT", "--port=PORT", "Bind to port (default: #{Server::DEFAULT_PORT})") do |port|
      #  server.port = port.to_i
      #end
      opts.on("-e VAR", "--extra-vars=VAR", "Set variables as `key=value`") do |var|
        key, value = var.split('=')
        #server.config.crinja.context[key] = value
      end
      opts.on("-s DIR", "--source DIR", "Set root dir (default: `#{source_path}`)") do |dir|
        source_path = dir
      end
    end

    case command = options.shift?
    when "serve"
      #server.start
    when "list"
      config, site = create_site(source_path, logger)
      site.each_entry do |entry|
        puts entry
      end
    when "help", Nil
      display_help_and_exit(options_parser)
    when "version"
      display_version_and_exit
    when "build"
      config, site = create_site(source_path, logger)
      renderer = Criss::Renderer.new(site)

      renderer.render
    else
      puts "unrecognised command: #{command}"
    end
  end

  def self.create_site(source_path, logger)
    config = Config.new(source_path)
    config.logger = logger
    site = Site.new(config)

    return config, site
  end

  private def self.display_version_and_exit
    puts Criss::VERSION
    exit
  end
end
