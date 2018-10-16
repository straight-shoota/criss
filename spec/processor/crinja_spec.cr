require "spec"
require "../../src/processor/crinja"

describe Criss::Processor::Crinja do
  it "renders crinja template" do
    site = Criss::Site.new
    processor = Criss::Processor::Crinja.new
    resource = Criss::Resource.new(site, "foo.md")

    String.build do |io|
      processor.process(resource, IO::Memory.new("Foo {{ page.name }}"), io)
    end.should eq "Foo foo.md"
  end

  it "exposes frontmatter to template" do
    site = Criss::Site.new
    processor = Criss::Processor::Crinja.new
    resource = Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter { "foo" => "Bar" })

    String.build do |io|
      processor.process(resource, IO::Memory.new("Foo {{ page.foo }}"), io)
    end.should eq "Foo Bar"
  end
end
