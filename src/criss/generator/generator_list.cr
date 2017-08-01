class Criss::Generator::List
  include Generator

  getter generators : Array(Generator)

  def initialize(context, @generators)
    super(context)
  end

  def generate(io, path)
    @generators.each do |generator|
      result = generator.generate(io, path)
      return result if result
    end
  end
end
