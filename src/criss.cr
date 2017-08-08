require "./criss/context"
require "./criss/entry"
require "./criss/processor"
require "./criss/generator"
require "./criss/version"
require "yaml"

module Criss
  alias Frontmatter = Hash(String, Crinja::Type)
end

module Crinja
  alias Variables = Hash(Crinja::Type, Crinja::Type)
end
