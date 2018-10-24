require "spec"
require "../../src/processor/crinja"

private def run_processor(resource, template)
  processor = Criss::Processor::Crinja.new

  String.build do |io|
    processor.process(resource, IO::Memory.new(template), io)
  end
end

describe Criss::Processor::Crinja do
  it "renders crinja template" do
    site = Criss::Site.new
    resource = Criss::Resource.new(site, "foo.md")

    run_processor(resource, "Foo {{ page.name }}").should eq "Foo foo.md"
  end

  it "exposes frontmatter to template" do
    site = Criss::Site.new
    resource = Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"foo" => "Bar"})

    run_processor(resource, "Foo {{ page.foo }}").should eq "Foo Bar"
  end

  it "exposes site to template" do
    site = Criss::Site.new
    site.config["title"] = "Foo Site"
    resource = Criss::Resource.new(site, "foo.md")
    site.files << resource

    run_processor(resource, "{{ site.destination }}").should eq "_site"
    run_processor(resource, "{{ site.title }}").should eq "Foo Site"
    run_processor(resource, "{{ site.files[0].slug }}").should eq "foo.md"
  end

  it "expose categories" do
    site = Criss::Site.new

    run_processor(Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"categories" => "Foo"}), "{{ page.categories }}").should eq "['Foo']"
    run_processor(Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"categories" => [YAML::Any.new("Foo")]}), "{{ page.categories }}").should eq "['Foo']"
    run_processor(Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"category" => "Foo"}), "{{ page.categories }}").should eq "['Foo']"
    run_processor(Criss::Resource.new(site, "foo.md"), "{{ page.categories }}").should eq "[]"
  end
end
