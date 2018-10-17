struct Criss::Frontmatter
  def initialize(@data = {} of YAML::Any => YAML::Any)
  end

  def [](key : String)
    @data[YAML::Any.new(key)].raw
  end

  def []?(key : String)
    @data[YAML::Any.new(key)]?.try &.raw
  end

  def fetch(key : String)
    @data.fetch(YAML::Any.new(key)) do
      yield
    end
  end

  def fetch(key : String)
    @data.fetch(YAML::Any.new(key))
  end

  def fetch(key : String, default)
    @data.fetch(YAML::Any.new(key), default)
  end

  def []=(key : String, value)
    @data[YAML::Any.new(key)] = YAML::Any.new(value)
  end

  def []=(key : String, value : Frontmatter)
    self[key] = value.@data
  end

  def has_key?(key : String)
    @data.has_key?(YAML::Any.new(key))
  end

  def each
    @data.each do |key, value|
      yield key.as_s, value
    end
  end

  def self.read_frontmatter(io : IO)
    return unless peek_string(io, "---\n")

    frontmatter_io = IO::Delimited.new(io, "\n---\n")

    parse(frontmatter_io)
  end

  def self.parse(source) : Frontmatter?
    yaml = YAML.parse(source)

    case raw = yaml.raw
    when Hash
      Frontmatter.new(raw)
    when Nil
      Frontmatter.new
    else
      raise "invalid Frontmatter"
    end
  end

  # private def self.peek_string(io, string)
  #   peek = io.peek
  #   return false unless peek.try &.size > 0

  #   if peek.size < 4
  #     # peek was to small, need to peek again
  #     buffer = uninitialized UInt8[4]
  #     buffer.to_slice.copy_from(peek)
  #     next_peek = io.peek
  #     return false unless next_peek && next_peek.size + peek.size >= 4
  #     (buffer.to_slice + peek.size).copy_from(next_peek)
  #     peek = buffer.to_slice
  #   end

  #   peek[0, 4] == "---\n".to_slice
  # end

  private def self.peek_string(io, string)
    peek = io.peek
    return false unless peek.try &.size > 0

    peeked_bytes = Math.min(peek.size, string.bytesize)
    return false unless peek[0, peeked_bytes] == string.to_slice[0, peeked_bytes]

    if peeked_bytes < string.bytesize
      peek = io.peek
      return false unless peek.try &.size > 0

      # We couldn't read the entire string in two peeks, so it's probably no
      return false if peeked_bytes + peek.size < string.bytesize

      count = string.bytesize - peeked_bytes
      return peek[0, count] == string.to_slice[peeked_bytes, count]
    end

    true
  end
end
