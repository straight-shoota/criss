module Util::DefAndEquals
  macro included
    def ==(other : {{ @type.id }})
      {% for field in @type.instance_vars %}
        return false unless @{{field.id}} == other.@{{field.id}}
      {% end %}
      true
    end

    def hash(hasher)
      {% for field in @type.instance_vars %}
        hasher = @{{field.id}}.hash(hasher)
      {% end %}
      hasher
    end
  end
end
