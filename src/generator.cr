require "./site"
require "./priority"

abstract class Criss::Generator
  getter site : Site

  def initialize(@site : Site)
  end

  abstract def generate : Nil

  abstract def priority : Priority
end

require "./generator/*"
