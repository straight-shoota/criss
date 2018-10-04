class Criss::SassGenerator
  include Generator::Base(FileEntry)

  FILE_EXTENSIONS = Processor::Sass::FILE_EXTENSIONS + [".css"]

  @processor : Processor?
  def processor
    processor = @processor
    processor || (@processor = Processor.build_chain([
        Processor::Sass.new(context),
        Processor::Crinja.new(context),
      ]))
  end

  def each_entry
    file_glob = "/**/*"

    Dir[site.source_path file_glob].each do |file|
      if(file_name_matches?(file))
        file = file.lchop(site.source_path)
        yield create_entry(path_for(file), file)
      end
    end
  end

  def path_for(file)
    file.sub(".sass", ".css").sub(".scss", ".css")
  end

  private def file_name_matches?(file)
    File.file?(file) \
      && FILE_EXTENSIONS.includes?(File.extname(file)) \
      && file[0] != '_' \
      && file.index("/_") == nil
  end

  def matches?(path)
    if File.extname(path) == ".css"
      file_path = path.rchop(".css") + ".scss"
      return file_path if File.file?(site.source_path(file_path))

      context.logger.debug("extension matches #{self} but file #{file_path} does not exist")
    end
    nil
  end

  private def generate_entry?(entry)
    entry.content_type == "text/css"
  end

  def create_entry(path, file_path)
    FileEntry.new(context, path, file_path, content_type: "text/css")
  end
end
