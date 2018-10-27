require "./processor"

struct Criss::Pipeline
  getter processors : Array(Processor)

  def initialize(@processors : Array(Processor))
  end

  def pipe(resource : Resource)
    unless resource.has_frontmatter?
      return resource.content
    end

    input = IO::Memory.new
    if content = resource.content
      input << content
      input.rewind
    end

    output = IO::Memory.new

    @processors.each do |processor|
      result = processor.process(resource, input, output)

      # `as(Bool)` ensures all implementations return Bool
      next unless result.as(Bool)

      input.clear
      output.rewind
      input, output = output, input
    end

    input.gets_to_end
  end

  def pipe(io : IO, resource : Resource)
    io << pipe(resource)
  end

  class Builder
    # TODO: Read processors
    def self.new(site)
      new(site, Processor.all_implementations)
    end

    def self.new(site, types : Array(Processor.class))
      transforms = [] of Processor::Transformation

      types.each do |klass|
        processor = klass.new(site)
        transforms += processor.transformations
      end

      new site, transforms
    end

    def initialize(@site : Site, @transforms : Array(Processor::Transformation))
      @transforms.sort!
      @register = Hash(String, Pipeline).new do |hash, key|
        hash[key] = create_pipeline(key)
      end
    end

    def transformation_for_extension(extension) : Processor::Transformation?
      extension = extension.lchop('.')

      @transforms.each do |transform|
        next if transform.from_wildcard? || transform.to_wildcard? || transform.from_first == transform.to_first

        processor = transform.processor
        if processor.responds_to? :file_extensions
          input_extensions = processor.file_extensions(transform.from)
        else
          input_extensions = {transform.from}
        end

        input_extensions.each do |input_ext|
          if extension == input_ext
            return transform
          end
        end
      end
    end

    def format_for_filename(filename : String) : String
      input_ext = File.extname(filename)
      transformation = transformation_for_extension(input_ext)

      transformation.try(&.from) || input_ext
    end

    def format_for(resource : Resource) : String
      ext = format_for_filename(resource.slug)

      "crinja.#{ext}"
    end

    def pipeline_for(resource : Resource) : Pipeline
      @register[format_for(resource)]
    end

    def output_ext(input_ext : String) : String?
      if transformation = transformation_for_extension(input_ext)
        ".#{transformation.to}"
      end
    end

    def output_ext_for(resource : Resource) : String?
      extname = resource.extname

      if extname && resource.has_frontmatter?
        output_ext(extname) || extname
      else
        extname
      end
    end

    def create_pipeline(format)
      segments = [] of Processor
      transformations = @transforms.dup

      while true
        format_first = format.partition('.').first
        transform = transformations.find do |transform|
          transform.from == format || transform.from == format_first ||
            (transform.from_wildcard? && transform.to_first != format_first)
        end

        break unless transform

        case {transform.from_wildcard?, transform.to_wildcard?}
        when {true, false}
          format = "#{transform.to}.#{format}"
        when {false, true}
          format = format.partition('.').last
        when {false, false}
          format = transform.to
        end

        #
        # #segments << transform.processor

        # if transform.from_first != transform.to_first
        #   processors, transformations = transformations.partition do |t|
        #     transform.from == t.from && transform.to == t.to
        #   end
        #   processors = processors.map &.processor
        # else
        #   transformations.delete(transform)
        #   processors = [transform.processor]
        # end

        segments << transform.processor
      end

      Pipeline.new segments
    end
  end
end
