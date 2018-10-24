struct Criss::Frontmatter
  def initialize(@data = {} of YAML::Any => YAML::Any)
  end

  def [](key : String) : YAML::Any
    @data[YAML::Any.new(key)]
  end

  def []?(key : String) : YAML::Any?
    @data[YAML::Any.new(key)]?
  end

  def fetch(key : String) : YAML::Any?
    @data.fetch(YAML::Any.new(key)) do
      yield
    end
  end

  def fetch(key : String) : YAML::Any
    @data.fetch(YAML::Any.new(key))
  end

  def fetch(key : String, default : YAML::Any) : YAML::Any
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
    return unless peek_frontmatter_delimiter(io)

    frontmatter_io = IO::Delimited.new(io, "\n---")

    frontmatter = parse(frontmatter_io)

    if rest_of_line = io.gets
      rest_of_line.each_char do |char|
        raise "invalid frontmatter" unless char == '-'
      end
    end

    frontmatter
  end

  def self.parse(source) : Frontmatter?
    yaml = YAML.parse(source)

    case raw = yaml.raw
    when Hash
      new(raw)
    when Nil
      new
    else
      raise "invalid frontmatter"
    end
  end

  # :nodoc:
  def self.new(context : YAML::ParseContext, node : YAML::Nodes::Node)
    new(Hash(YAML::Any, YAML::Any).new(context, node))
  end

  def merge!(other : Frontmatter)
    @data.merge!(other.@data)
  end

  private def self.peek_frontmatter_delimiter(io)
    peek = io.peek

    return false unless peek && peek.size >= 3

    dash_counter = 0
    expect_lf = false
    peek.each_with_index do |byte, index|
      case byte
      when '-'
        return false if expect_lf
        dash_counter += 1
      when '\r'
        expect_lf = true
      when '\n'
        return dash_counter == 3
      else
        return false
      end
    end

    false
  end
end
