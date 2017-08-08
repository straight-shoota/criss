module Criss::Generator
  getter context : Context
  def initialize(@context)
  end

  abstract def generate(io : IO, path) : String?

  def generate(path)
    content_type = nil
    body = String.build do |io|
      content_type = generate(io, path)
    end

    Result.new path, body, content_type
  end

  record Result, path : String, body : String, content_type : String?

  module Base
    include Generator

    def initialize(@context)
    end

    def generate(io, path)
      match_result = matches?(path)
      return nil unless match_result

      if match_result.is_a?(Entry)
        entry = match_result
      else
        entry = create_entry(path, match_result)
      end

      generate(io, entry)

      entry.content_type
    end

    protected def create_entry(path, match_result)
      Entry.new(path, match_result)
    end

    protected abstract def matches?(path)

    def generate(io, entry : Entry)
      context.logger.debug "Rendering file_path #{entry.file_path}"

      file = File.open(context.root_path(entry.file_path))
      processor.process(entry, file, io)
    end

    protected abstract def processor : Processor
  end
end

require "./generator/*"
