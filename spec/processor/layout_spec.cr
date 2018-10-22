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

    String.build do |io|
      processor.process(resource, IO::Memory.new("Laus deo semper"), io).should be_true
    end.should eq "<base><page>Laus deo semper</page></base>\n"
  end

  it "none layout" do
    site = Criss::Site.new
    processor = Criss::Processor::Layout.new

    String.build do |io|
      processor.process(Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"layout" => "none"}), IO::Memory.new("Laus deo semper"), io).should be_false
    end.should eq ""

    String.build do |io|
      processor.process(Criss::Resource.new(site, "foo.md"), IO::Memory.new("Laus deo semper"), io).should be_false
    end.should eq ""
  end

  it "template loader" do
    site = Criss::Site.new
    processor = Criss::Processor::Layout.new(layouts_path: "spec/fixtures/simple-site/_layouts")
    resource = Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"layout" => "simple"})

    String.build do |io|
      processor.process(resource, IO::Memory.new("Laus deo semper"), io).should be_true
    end.should eq <<-'HTML'
      <html>
        <body>
          Laus deo semper
        </body>
      </html>

      HTML
  end
end
