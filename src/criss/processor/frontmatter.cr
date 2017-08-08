class Criss::Processor::Frontmatter
  include Processor
  def process(entry, input, output)
    entry.frontmatter = entry.default_frontmatter(context)

    frontmatter = input.gets "\n---"
    if frontmatter
      peek = input.peek
      if peek && peek.empty?
        # there is no frontmatter
        input = IO::Memory.new(frontmatter)
      else
        if peek && peek.size >= '\n'.bytesize
          if peek[0, '\n'.bytesize].to_a == '\n'.bytes
            input.read_char
          end
        end
        yaml = YAML.parse(frontmatter)
        if yaml.raw.is_a?(Hash)
          entry.frontmatter.merge!(::Crinja::Bindings.cast_bindings(yaml.as_h))
        end
      end
    else
      # empty input
    end

    process_next(entry, input, output)
  end

  def self.read_frontmatter(string)
    frontmatter, separator, content = string.partition "\n---\n"

    if separator.empty?
      content = frontmatter
    elsif !frontmatter.strip.empty?
      # doen't matter if content.starts_with? "---\n"

      yaml = YAML.parse(frontmatter)
      return yaml.as_h, content if yaml.raw.is_a?(Hash)
    end

    return Criss::Frontmatter.new, content
  end
end
