require "crinja"

class Criss::Context
  include Crinja::PyObject

  property root_path : String
  property crinja : Environment
  property logger : Logger = Logger.new(STDOUT)
  property generators : Array(Generator) = [] of Generator

  def initialize(@root_path = ".", @crinja = Crinja::Environment.new)
    @crinja.config.liquid_compatibility_mode = true

    @crinja.loader = Crinja::Loader::FileSystemLoader.new(root_path("_includes"))
  end

  def root_path(path)
    File.join(@root_path, path)
  end

  def default_variables
    {
      "crinja" => {
        "version" => Crinja::VERSION,
        "server"  => self,
      },
      "site" => site_config
    }
  end

  def site_config
    config = default_site_config
    config_file = root_path("_config.yml")
    if File.readable?(config_file)
      yaml = YAML.parse(File.read(config_file))

      config.merge! Crinja.cast_hash(yaml)
    end
    config
  end

  def default_site_config
    {
      "time" => Time.now
      } of Crinja::Type => Crinja::Type
  end

  def url_for(path)
    path
  end
end
