module Util::YAMLUnmapped
  def [](key : String) : YAML::Any
    @yaml_unmapped[key]
  end

  def []?(key : String) : YAML::Any?
    @yaml_unmapped[key]?
  end

  def []=(key : String, value : YAML::Any) : YAML::Any
    @yaml_unmapped[key] = value
  end

  def []=(key : String, value : YAML::Any::Type) : YAML::Any
    self[key] = YAML::Any.new(value)
  end

  def has_key?(key : String) : Bool
    @yaml_unmapped.has_key?(key)
  end
end
