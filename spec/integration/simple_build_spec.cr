require "spec"
require "tempfile"
require "../../src/site"
require "../../src/builder"

describe "simple build spec" do
  it "builds" do
    site = Criss::Site.new("spec/fixtures")

    site.run_generators

    output_path = Tempfile.tempname
    Dir.mkdir(output_path)

    builder = Criss::Builder.new(output_path)
    builder.build(site)

    Process.run("diff", ["spec/fixtures/_build", output_path], output: STDOUT, error: STDERR).success?.should be_true
  end
end
