require "spec"
require "../../src/processor/crinja"

private def run_processor(resource, template, site = Criss::Site.new)
  processor = Criss::Processor::Crinja.new(site)

  String.build do |io|
    processor.process(resource, IO::Memory.new(template), io)
  end
end

describe Criss::Processor::Crinja do
  it "renders crinja template" do
    resource = Criss::Resource.new(nil, "foo.md")

    run_processor(resource, "Foo {{ page.name }}").should eq "Foo foo.md"
  end

  it "exposes frontmatter to template" do
    resource = Criss::Resource.new(nil, "foo.md", frontmatter: Criss::Frontmatter{"foo" => "Bar"})

    run_processor(resource, "Foo {{ page.foo }}").should eq "Foo Bar"
  end

  it "exposes site to template" do
    site = Criss::Site.new
    site.config["title"] = "Foo Site"
    resource = Criss::Resource.new(nil, "foo.md")
    site.files << resource

    run_processor(resource, "{{ site.destination }}",site: site).should eq "_site"
    run_processor(resource, "{{ site.title }}",site: site).should eq "Foo Site"
    run_processor(resource, "{{ site.files[0].slug }}",site: site).should eq "foo.md"
  end

  it "expose categories" do
    run_processor(Criss::Resource.new(nil, "foo.md", frontmatter: Criss::Frontmatter{"categories" => "Foo"}), "{{ page.categories }}").should eq "['Foo']"
    run_processor(Criss::Resource.new(nil, "foo.md", frontmatter: Criss::Frontmatter{"categories" => [YAML::Any.new("Foo")]}), "{{ page.categories }}").should eq "['Foo']"
    run_processor(Criss::Resource.new(nil, "foo.md", frontmatter: Criss::Frontmatter{"category" => "Foo"}), "{{ page.categories }}").should eq "['Foo']"
    run_processor(Criss::Resource.new(nil, "foo.md"), "{{ page.categories }}").should eq "[]"
  end

  it "loads from includes dir" do
    processor = Criss::Processor::Crinja.new(site_dir: "spec/fixtures/simple-site")
    processor.process(Criss::Resource.new(nil, "foo.md"), "{% include foo.html %}").should eq "FOO included"
  end
end
