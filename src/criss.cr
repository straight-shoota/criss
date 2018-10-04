require "./criss/config"
require "./criss/site"
require "./criss/entry"
require "./criss/processor"
require "./criss/generator"
require "./criss/version"
require "yaml"

module Criss
  alias Frontmatter = Crinja::Variables
end
