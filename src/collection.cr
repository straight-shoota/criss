require "./config"
require "./resource"

class Criss::Collection
  getter name : String
  getter defaults : Config::Collection
  getter resources : Array(Resource) = [] of Resource

  def initialize(@name : String, @defaults : Config::Collection = Config::Collection.new)
  end
end
