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

      generate(io, path, match_result)
      content_type(path, match_result)
    end

    protected abstract def matches?(path)

    protected abstract def generate(io : IO, path, file_path)

    protected abstract def content_type(path, file_path) : String
  end
end

require "./generator/*"
