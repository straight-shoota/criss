require "spec"
require "../src/site"

describe Criss::Site do
  describe "#defaults_for" do
    it "matches all" do
      config = Criss::Config.new

      frontmatter = Criss::Frontmatter{"match_all" => true}

      config.defaults = [Criss::Config::Defaults.new(Criss::Config::Scope.new, frontmatter)]

      site = Criss::Site.new(config)

      site.defaults_for("foo.md", "post").should eq frontmatter
    end

    it "scope path" do
      config = Criss::Config.new

      config.defaults = [
        Criss::Config::Defaults.new(Criss::Config::Scope.new, Criss::Frontmatter{"match_all" => true}),
        Criss::Config::Defaults.new(Criss::Config::Scope.new(path: "*.md"), Criss::Frontmatter{"path_md" => true})
      ]

      site = Criss::Site.new(config)

      site.defaults_for("foo.md", "post").should eq Criss::Frontmatter{
        "match_all" => true,
        "path_md" => true
      }
    end

    it "scope type" do
      config = Criss::Config.new

      config.defaults = [
        Criss::Config::Defaults.new(Criss::Config::Scope.new, Criss::Frontmatter{"match_all" => true}),
        Criss::Config::Defaults.new(Criss::Config::Scope.new(type: "post"), Criss::Frontmatter{"type_post" => true})
      ]

      site = Criss::Site.new(config)

      site.defaults_for("foo.md", "post").should eq Criss::Frontmatter{
        "match_all" => true,
        "type_post" => true
      }
    end

    it "scope type" do
      config = Criss::Config.new

      config.defaults = [
        Criss::Config::Defaults.new(Criss::Config::Scope.new, Criss::Frontmatter{"match_all" => true}),
        Criss::Config::Defaults.new(Criss::Config::Scope.new(type: "post"), Criss::Frontmatter{"type_post" => true}),
        Criss::Config::Defaults.new(Criss::Config::Scope.new(path: "*.md"), Criss::Frontmatter{"path_md" => true}),
        Criss::Config::Defaults.new(Criss::Config::Scope.new(type: "page"), Criss::Frontmatter{"type_page" => true}),
        Criss::Config::Defaults.new(Criss::Config::Scope.new(path: "*.html"), Criss::Frontmatter{"path_html" => true})
      ]

      site = Criss::Site.new(config)

      site.defaults_for("foo.md", "post").should eq Criss::Frontmatter{
        "match_all" => true,
        "type_post" => true,
        "path_md" => true
      }
    end

    it "scope override" do
      config = Criss::Config.new

      config.defaults = [
        Criss::Config::Defaults.new(Criss::Config::Scope.new, Criss::Frontmatter{"foo" => "bar"}),
        Criss::Config::Defaults.new(Criss::Config::Scope.new, Criss::Frontmatter{"foo" => "baz"})
      ]

      site = Criss::Site.new(config)

      site.defaults_for("foo.md", "post").should eq Criss::Frontmatter{
        "foo" => "baz",
      }
    end
  end
end
