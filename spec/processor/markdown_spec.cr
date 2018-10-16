require "spec"
require "../../src/processor/markdown"

describe Criss::Processor::Markdown do
  it "renders markdown" do
    site = Criss::Site.new
    processor = Criss::Processor::Markdown.new
    resource = Criss::Resource.new(site, "foo.md")

    String.build do |io|
      processor.process(resource, IO::Memory.new("Foo *bar*"), io)
    end.should eq "<p>Foo <em>bar</em></p>\n"
  end
end
