require "spec"
require "../support/tempfile"
require "../../src/site"
require "../../src/builder"

describe "jekyll test-site spec" do
  pending "builds similar to Jekyll" do
    site = Criss::Site.new("spec/fixtures/jekyll-test-site")

    site.run_generators

    with_tempfile("jekyll_test_site") do |output_path|
      builder = Criss::Builder.new(output_path)
      builder.build(site)

      Process.run("diff", ["-r", "spec/fixtures/jekyll-test-site/_site", output_path], output: STDOUT, error: STDERR).success?.should be_true
    end
  end
end
