require "./site"

abstract class Criss::Generator
  getter site : Site

  def initialize(@site : Site)
  end

  abstract def generate : Nil
end

require "./generator/*"
