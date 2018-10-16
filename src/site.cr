require "./resource"
require "./pipeline"
require "yaml"

alias Criss::Collection = Array(Resource)

class Criss::Site
  getter source_path : String

  getter files : Array(Resource) = [] of Resource
  getter collections = {} of String => Array(Resource)

  getter generators : Array(Generator) = [] of Generator

  getter pipeline_builder : Pipeline::Builder

  def initialize(source_path = Dir.current)
    @source_path = File.expand_path(source_path)

    @pipeline_builder = uninitialized Pipeline::Builder
    @pipeline_builder = Pipeline::Builder.new(self)
  end

  property output_path = "_build"

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
