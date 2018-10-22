require "./site"
require "./builder"
require "option_parser"

class Criss::CLI
  getter logger : Logger
  getter output : IO
  getter error : IO
  getter source_path : String
  getter option_parser : OptionParser

  def self.run(options = ARGV)
    new.run(options)
  end

  def initialize(@output = STDOUT, @error = STDERR)
    @logger = Logger.new(@output)
    @source_path = "."

    @option_parser = OptionParser.new.tap do |opts|
      opts.on("--version", "") { display_version_and_exit }
      opts.on("-v", "--verbose", "") { logger.level = Logger::Severity::DEBUG }
      opts.on("-q", "--quiet", "") { logger.level = Logger::Severity::WARN }
      opts.on("-h", "--help", "") { display_help_and_exit }
      # opts.on("-b HOST", "--bind=HOST", "Bind to host (default: #{Server::DEFAULT_HOST})") do |host|
      #  server.host = host
      # end
      # opts.on("-p PORT", "--port=PORT", "Bind to port (default: #{Server::DEFAULT_PORT})") do |port|
      #  server.port = port.to_i
      # end
      opts.on("-e VAR", "--extra-vars=VAR", "Set variables as `key=value`") do |var|
        key, value = var.split('=')
        # server.config.crinja.context[key] = value
      end
      opts.on("-s DIR", "--source DIR", "Set root dir (default: `#{source_path}`)") do |dir|
        source_path = dir
      end
    end
  end

  def display_help_and_exit
    @output.puts <<-USAGE
      criss [command] [options]

      Commands:
          build                build site
          serve                serve site
          help, --help, -h     show this help
          version, --version   show version

      Options:
      USAGE

    @output.puts @option_parser

    exit
  end

  def exit
    ::exit
  end

  def run(options)
    @option_parser.parse(options)

    run_command options.shift?, options
  end

  def run_command(command : String?, options)
    case command
    when "serve"
      # server.start
    when "list"
      run_list
    when "help", Nil
      display_help_and_exit
    when "version"
      display_version_and_exit
    when "build"
      run_build
    else
      puts "unrecognised command: #{command}"
    end
  end

  def run_list
    site = Criss::Site.new(source_path)

    site.run_generators

    site.collections.each_value do |collection|
      @output.puts "# #{collection.name}"
      collection.resources.each do |resource|
        @output.puts resource.slug
      end
    end
  end

  def run_build
    site = create_site

    site.run_generators

    builder = Criss::Builder.new(site.config.destination)
    builder.build(site)
  end

  def create_site
    site = Criss::Site.new(source_path)

    site
  end

  private def display_version_and_exit
    #puts Criss::VERSION
    exit
  end
end
