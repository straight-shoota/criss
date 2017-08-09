class Criss::SiteGenerator
  getter context : Context
  getter generator

  def initialize(@context = Context.new)
    @generator = Generator::List.new(context)
  end

  def generate_all
    @generator.list_entries.each do |entry|
      generate(entry)
    end
  end

  private def generate(entry)
    build_file = context.build_path(entry.request_path)

    context.logger.info "Generating #{entry} into #{build_file}"
    FileUtils.mkdir_p File.dirname(build_file)
    File.open(build_file, "w") do |io|
      @generator.generate(io, entry)
    end
  end
end
