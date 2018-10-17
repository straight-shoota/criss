require "spec"
require "../src/pipeline"

describe Criss::Pipeline do
  it "#pipe" do
    site = Criss::Site.new
    processors = [
      Criss::Processor::Crinja.new(site),
      Criss::Processor::Markdown.new(site),
    ]
    pipeline = Criss::Pipeline.new processors

    resource = Criss::Resource.new(site, "sample.md", "Foo **{{ page }}**")
    pipeline.pipe(resource).should eq "<p>Foo <strong>sample.md</strong></p>\n"
  end
end

describe Criss::Pipeline::Builder do
  it "init" do
    site = Criss::Site.new
    builder = Criss::Pipeline::Builder.new(site)
  end

  it "#create_pipeline" do
    site = Criss::Site.new
    builder = Criss::Pipeline::Builder.new(site)

    builder.create_pipeline("markdown").processors.map(&.class).should eq [
      Criss::Processor::Markdown,
      Criss::Processor::Layout,
    ]
    builder.create_pipeline("jinja.markdown").processors.map(&.class).should eq [
      Criss::Processor::Crinja,
      Criss::Processor::Markdown,
      Criss::Processor::Layout,
    ]
    builder.create_pipeline("sass").processors.map(&.class).should eq [
      Criss::Processor::Sass,
      Criss::Processor::Layout,
    ]
    builder.create_pipeline("jinja.html").processors.map(&.class).should eq [
      Criss::Processor::Crinja,
      Criss::Processor::Layout,
    ]
  end

  it "#format_for" do
    site = Criss::Site.new
    builder = Criss::Pipeline::Builder.new(site)

    resource = Criss::Resource.new(site, "sample.md", "Foo **{{ page }}**")
    builder.format_for(resource).should eq "crinja.markdown"
  end

  it "#format_for_filename" do
    site = Criss::Site.new
    builder = Criss::Pipeline::Builder.new(site)
    builder.format_for_filename("foo.md").should eq "markdown"
  end

  it "#output_ext" do
    site = Criss::Site.new
    builder = Criss::Pipeline::Builder.new(site)

    builder.output_ext(".scss").should eq ".css"
    builder.output_ext(".sass").should eq ".css"
    builder.output_ext(".css").should eq nil
    builder.output_ext(".html").should eq nil
    builder.output_ext(".md").should eq ".html"
    builder.output_ext(".markdown").should eq ".html"
    builder.output_ext(".jpg").should eq nil
  end
end
