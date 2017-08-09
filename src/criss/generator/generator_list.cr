class Criss::Generator::List
  include Generator

  getter generators : Array(Generator)

  def self.new(context)
    new(context, context.generators)
  end

  def initialize(context, @generators)
    super(context)
  end

  delegate generators, to: context

  def generate(io, entry)
    @generators.each do |generator|
      result = generator.generate(io, entry)
      return result if result
    end
  end

  def each_entry(&block : Entry ->)
    # block needs to be captured to avoid infinite inlining
    @generators.each do |generator|
      generator.each_entry(&block)
    end
  end
end
