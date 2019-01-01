require "spec"
require "../src/builder"
require "./support/tempfile"
require "file_utils"

describe Criss::Builder do
  it "#build" do
    site = Criss::Site.new
    site.files << Criss::Resource.new(site, "sample.md", "Foo **{{ page.name }}**")

    with_tempfile("builder") do |output_path|
      builder = Criss::Builder.new(output_path)
      builder.build(site)
    end
  end
end
