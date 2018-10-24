class Criss::Paginator
  include Crinja::Object::Auto

  getter items : Array(Resource)

  getter index : Int32

  getter pages : Array(Resource)

  property! next : Resource

  property! previous : Resource

  property! first : Resource

  property! last : Resource

  def initialize(@items : Array(Resource), @index : Int, @pages : Array(Resource))
  end
end
