require "spec"
require "../src/site"

def build_site(vars = Crinja::Variables.new)
  Criss::Site.new(Criss::Config.new(File.join(__DIR__, "fixtures"), vars))
end
