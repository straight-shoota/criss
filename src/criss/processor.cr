module Criss::Processor
  getter context : Context
  property! next : Processor

  def initialize(@context)
  end

  abstract def process(entry, input, output)

  def process_next(entry, input, output)
    if next_processor = next?
      next_processor.process(entry, input, output)
    else
      # last processor
      IO.copy(input, output)
    end
  end

  def self.build_chain(processors)
    0.upto(processors.size - 2) { |i| processors[i].next = processors[i + 1] }
    processors.first
  end
end

require "./processor/*"
