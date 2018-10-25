require "./site"
require "./priority"

abstract class Criss::Processor
  record Transformation, processor : Processor, from : String, to : String do
    include Comparable(Transformation)

    def <=>(other : Transformation)
      return 1 if from_wildcard? && !other.from_wildcard?
      return -1 if other.from_wildcard?

      prio_diff = processor.priority <=> other.processor.priority

      if prio_diff == 0
        return 1 if (from_first != to_first) && (other.from_first == other.to_first)
      end

      prio_diff
    end

    def to_s(io : IO)
      io << processor.class
      io << ": "
      io << from << " => " << to
    end

    def from_wildcard?
      @from == "*"
    end

    def to_wildcard?
      @to == "*"
    end

    def from_first
      from.partition('.').first
    end

    def to_first
      to.partition('.').first
    end
  end

  def initialize(site : Site)
  end

  # Processes the given resource. Current content is read from `input` and the
  # result written to `output`.
  #
  # Returns `false` if processing is skipped for this resource.
  abstract def process(resource : Resource, input : IO, output : IO) : Bool

  def process(resource : Resource, input : String) : String?
    String.build do |io|
      unless process(resource, IO::Memory.new(input), io)
        return nil
      end
    end
  end

  # @@transforms = [] of Nil

  # def transformations : Array(Transformation)
  #   array = [] of Transformation
  #   @@transformations.each do |from, to|
  #     array << Transformation.new(self, from, to)
  #   end
  #   array
  # end
  abstract def transformations : Array(Transformation)
  abstract def priority : Priority

  macro inherited
    macro transforms(priority = :NORMAL, **mappings)
      def priority : Priority
        Priority::\{{ priority.id }}
      end

      def transformations : Array(Transformation)
        [
          \{% for from, to in mappings %}
          Transformation.new(self, \{{ from.stringify }}, \{{ to }}),
          \{% end %}
        ] of Transformation
      end
    end

    macro file_extensions(**mappings)
      def file_extensions(format : String) : Iterable(String)
        case format
          \{% for format, extensions in mappings %}
            when \{{ format.stringify }}
              { \{{ extensions.map(&.id.gsub(/^./, "").stringify.stringify).join(", ").id }} }
          \{% end %}
        else
          Slice(String).empty
        end
      end
    end
  end

  macro all_implementations
    {{ @type.all_subclasses.map(&.name) }}
  end
end

require "./processor/*"
