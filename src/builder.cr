require "./site"
require "file_utils"

class Criss::Builder
  def initialize(@output_dir : String)
  end

  def build(site : Site)
    run_processors(site, site.files)

    site.collections.each_value do |collection|
      begin
        run_processors(site, collection.resources)
      rescue exc
        raise Exception.new("Error running processors for collection #{collection.name}", cause: exc)
      end
    end
  end

  def run_processors(site : Site, resources : Array(Resource))
    resources.each do |resource|
      output_relative_path = resource.output_path
      output_path = File.join(@output_dir, output_relative_path)

      FileUtils.mkdir_p(File.dirname(output_path))

      File.open(output_path, "w") do |file|
        begin
          site.run_processor(file, resource)
        rescue exc
          raise Exception.new("Error running processor for #{resource.slug}", cause: exc)
        end
      end
    end
  end
end
