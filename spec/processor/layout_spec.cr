require "spec"
require "../../src/processor/layout"

describe Criss::Processor::Layout do
  it "renders layouts" do
    site = Criss::Site.new
    processor = Criss::Processor::Layout.new
    processor.layouts["page"] = {
      Crinja::Template.new("<page>{{ content }}</page>"),
      Criss::Frontmatter{"layout" => "base"},
    }
    processor.layouts["base"] = {
      Crinja::Template.new("<base>{{ content }}</base>"),
      Criss::Frontmatter.new,
    }
    resource = Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"layout" => "page"})

    processor.process(resource, "Laus deo semper").should eq "<base><page>Laus deo semper</page></base>\n"
  end

  it "none layout" do
    site = Criss::Site.new
    processor = Criss::Processor::Layout.new

    processor.process(Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"layout" => "none"}), "Laus deo semper").should be_nil

    processor.process(Criss::Resource.new(site, "foo.md"), "Laus deo semper").should be_nil
  end

  it "template loader" do
    site = Criss::Site.new
    processor = Criss::Processor::Layout.new(layouts_path: "spec/fixtures/simple-site/_layouts")
    resource = Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"layout" => "simple"})

    processor.process(resource,"Laus deo semper").should eq <<-'HTML'
      <html>
        <body>
          Laus deo semper
        </body>
      </html>

      HTML
  end

  it "loads from includes dir" do
    site = Criss::Site.new
    resource = Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"layout" => "include"})
    processor = Criss::Processor::Layout.new(layouts_path: "spec/fixtures/simple-site/_layouts", includes_path: "spec/fixtures/simple-site/_includes")

    processor.process(resource, "content").should eq "FOO included\n\ncontent\n"
  end
end
