module Criss::Generator
  getter context : Context
  def initialize(@context)
  end

  abstract def generate(io : IO, entry) : String?

  abstract def each_entry(&block : Entry -> )

  def list_entries
    entries = [] of Entry
    each_entry do |entry|
      entries << entry
    end
    entries
  end

  def generate(path)
    content_type = nil
    body = String.build do |io|
      content_type = generate(io, path)
    end

    Result.new path, body, content_type
  end

  record Result, path : String, body : String, content_type : String?

  module Base(T)
    include Generator

    def initialize(@context)
    end

    def generate(io, path : String)
      match_result = matches?(path)
      return nil unless match_result

      if match_result.is_a?(Entry)
        entry = match_result
      else
        entry = create_entry(path, match_result)
      end

      context.logger.debug "Using #{self} for #{entry}"

      generate(io, entry)

      entry.content_type
    end

    protected def create_entry(path, match_result)
      FileEntry.new(path, match_result, context)
    end

    protected abstract def matches?(path)

    def generate(io, entry : T)
      return nil unless generate_entry?(entry)
      context.logger.debug "Rendering file_path #{entry.file_path}"

      #file = File.open(site.source_path(entry.file_path))
      file = IO::Memory.new(entry.load)
      processor.process(entry, file, io)
    end

    def generate(io, entry)
      nil
    end

    private def generate_entry?(entry)
      true
    end

    protected abstract def processor : Processor

  end
end

#require "./generator/*"
