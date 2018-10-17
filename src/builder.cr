require "./site"
require "file_utils"

class Criss::Builder
  def initialize(@output_dir : String)
  end

  def build(site : Site)
    run_processors(site, site.files)

    site.collections.each_value do |collection|
      run_processors(site, collection.resources)
    end
  end

  def run_processors(site : Site, resources : Array(Resource))
    resources.each do |resource|
      output_path = resource.output_path(@output_dir)
      FileUtils.mkdir_p(File.dirname(output_path))

      File.open(output_path, "w") do |file|
        site.run_processor(file, resource)
      end
    end
  end
end
