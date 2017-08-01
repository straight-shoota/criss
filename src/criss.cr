require "./criss/context"
require "./criss/generator"
require "./criss/version"

module Criss
  def self.read_frontmatter(file)
    content = File.read(file)

    frontmatter, separator, content = content.partition "\n---\n"

    if separator.empty?
      content = frontmatter
    elsif !frontmatter.strip.empty?
      # doen't matter if content.starts_with? "---\n"

      yaml = YAML.parse(frontmatter)
      return yaml.as_h, content if yaml.raw.is_a?(Hash)
    end

    return {} of String => String, content
  end
end
