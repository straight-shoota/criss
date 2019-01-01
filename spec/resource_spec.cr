require "spec"
require "../src/resource"

def test_resource(slug, frontmatter = nil, site = Criss::Site.new, output_ext = nil)
  resource = Criss::Resource.new(site, slug, frontmatter: frontmatter)
  if output_ext
    resource.output_ext = output_ext
  end
  resource
end

describe Criss::Resource do
  describe ".new" do
    it do
      resource = Criss::Resource.new(nil, "foo/bar.html")

      resource.slug.should eq "foo/bar.html"

      resource.name.should eq "bar.html"
      resource.basename.should eq "bar"
      resource.extname.should eq ".html"
      resource.has_frontmatter?.should be_true
    end
  end

  describe "#url" do
    it do
      test_resource("foo/bar.html").url.to_s.should eq "/foo/bar"
    end
  end

  describe ".url_for" do
    it do
      Criss::Resource.url_for(test_resource("foo.md", output_ext: ".html")).to_s.should eq "/foo"
      Criss::Resource.url_for(test_resource("foo/bar.html")).to_s.should eq "/foo/bar"
    end
  end

  describe "#permalink" do
    it do
      test_resource("foo/bar.html").permalink.should eq "/foo/bar.html"
      test_resource("foo/bar.html", frontmatter: Criss::Frontmatter{"permalink" => "baz.html"}).permalink.should eq "/baz.html"
    end
  end

  describe "#output_path" do
    it do
      test_resource("foo/bar.html").output_path.should eq "/foo/bar.html"
      test_resource("foo/bar.html", frontmatter: Criss::Frontmatter{"domain" => "baz.com"}).output_path.should eq "/baz.com/foo/bar.html"
    end
  end

  it "#has_frontmatter" do
    site = Criss::Site.new
    resource = Criss::Resource.new(site, "foo/bar.html", frontmatter: nil)

    resource.has_frontmatter?.should be_false
  end

  it "#permalink" do
    test_resource("bar.sass", frontmatter: Criss::Frontmatter.new).permalink.should eq "/bar.css"
    test_resource("bar.scss", frontmatter: Criss::Frontmatter.new).permalink.should eq "/bar.css"
  end

  it "#expand_permalink" do
    test_resource("2018-10-23-test.md", frontmatter: Criss::Frontmatter{"categories" => "foo bar"}).expand_permalink("pretty").should eq "/foo/bar/2018/10/23/test/"
  end

  describe "#[]" do
    it "raises" do
      site = Criss::Site.new
      resource = Criss::Resource.new(site, "foo.md")

      expect_raises(KeyError, %(Missing resource frontmatter key: "foo")) do
        resource["foo"]
      end
    end

    it "falls back to defaults" do
      site = Criss::Site.new

      defaults = Criss::Frontmatter {
        "foo" => "bar",
        "baz" => "not-baz"
      }

      resource = Criss::Resource.new(site, "foo.md", frontmatter: Criss::Frontmatter{"baz" => "baz"}, defaults: defaults)
      resource["foo"].should eq "bar"
      resource["baz"].should eq "baz"
    end
  end
end
