require "spec"
require "../../src/generator"

describe Criss::Generator::Files do
  it "reads files" do
    site = Criss::Site.new("spec/fixtures")
    generator = Criss::Generator::Files.new(site)
    generator.generate

    site.files.map(&.slug).should eq ["index.md", "simple.scss"]

    file = site.files[0]
    file.slug.should eq "index.md"
    file.generator.should eq generator
    file.content.should eq "Index\n"
    file.title.should eq "Homepage"
    file.has_frontmatter?.should be_true

    file = site.files[1]
    file.slug.should eq "simple.scss"
    file.generator.should eq generator
    file.has_frontmatter?.should be_true
  end
end
