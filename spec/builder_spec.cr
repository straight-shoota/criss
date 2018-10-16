require "spec"
require "../src/builder"
require "tempfile"
require "file_utils"

describe Criss::Builder do
  it "#build" do
    site = Criss::Site.new
    site.files << Criss::Resource.new(site, "sample.md", "Foo **{{ page.name }}**")

    output_path = Tempfile.tempname
    Dir.mkdir(output_path)
    builder = Criss::Builder.new(output_path)
    builder.build(site)
  ensure
    FileUtils.rm_r(output_path) if output_path
  end
end
