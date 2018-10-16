require "spec"
require "../../src/generator"

describe Criss::Generator::Files do
  it "reads files" do
    site = Criss::Site.new("spec/fixtures")
    generator = Criss::Generator::Files.new(site)
    generator.generate
    file = site.files.first
    file.slug.should eq "index.md"
    file.generator.should eq generator
    file.content.should eq "Index\n"
    file.title.should eq "Homepage"
  end
end
