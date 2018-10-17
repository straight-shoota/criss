require "./resource"
require "./pipeline"
require "./config"
require "yaml"

alias Criss::Collection = Array(Resource)

class Criss::Site
  getter config : Config

  getter site_dir : String

  getter files : Array(Resource) = [] of Resource
  getter collections = {} of String => Array(Resource)

  getter generators : Array(Generator) = [] of Generator

  getter pipeline_builder : Pipeline::Builder

  def initialize(@config : Config = Config.new)
    @site_dir = File.expand_path(config.site_dir)

    @pipeline_builder = uninitialized Pipeline::Builder
    @pipeline_builder = Pipeline::Builder.new(self)
  end

  def self.new(site_dir : String)
    new Config.load(site_dir)
  end

  def url : URI
    URI.new("http://example.com")
  end

  def run_generators
    @generators << Generator::Collections.new(self)
    @generators << Generator::Files.new(self)

    @generators.each do |generator|
      generator.generate
    end
  end

  def run_processor(io : IO, resource : Resource)
    pipeline = @pipeline_builder.pipeline_for(resource)

    pipeline.pipe(io, resource)
  end
end
