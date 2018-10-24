require "spec"
require "../../src/generator"

describe Criss::Generator::Pagination do
  it "adds paginator" do
    site = Criss::Site.new
    site.posts << Criss::Resource.new(site, "baz.md")
    site.posts << Criss::Resource.new(site, "bar.md")

    index = Criss::Resource.new(site, "index.html", frontmatter: Criss::Frontmatter{
      "paginate" => Hash(YAML::Any, YAML::Any){
        YAML::Any.new("collection") => YAML::Any.new("posts")
      }
    })
    site.files << index

    generator = Criss::Generator::Pagination.new(site)
    generator.generate

    index.paginator.not_nil!.items.map(&.slug).should eq ["baz.md", "bar.md"]
  end

  it "sorts" do
    site = Criss::Site.new
    site.posts << Criss::Resource.new(site, "baz.md")
    site.posts << Criss::Resource.new(site, "bar.md")

    index = Criss::Resource.new(site, "index.html", frontmatter: Criss::Frontmatter{
      "paginate" => Hash(YAML::Any, YAML::Any){
        YAML::Any.new("collection") => YAML::Any.new("posts"),
        YAML::Any.new("sort") => YAML::Any.new(true)
      }
    })
    site.files << index

    generator = Criss::Generator::Pagination.new(site)
    generator.generate

    index.paginator.not_nil!.items.map(&.slug).should eq ["bar.md", "baz.md"]
  end

  it "adds pages" do
    site = Criss::Site.new
    site.posts << Criss::Resource.new(site, "baz.md")
    site.posts << Criss::Resource.new(site, "bar.md")
    site.posts << Criss::Resource.new(site, "qux.md")

    index = Criss::Resource.new(site, "index.html", frontmatter: Criss::Frontmatter{
      "paginate" => Hash(YAML::Any, YAML::Any){
        YAML::Any.new("collection") => YAML::Any.new("posts"),
        YAML::Any.new("per_page") => YAML::Any.new(2_i64)
      }
    })
    site.files << index

    generator = Criss::Generator::Pagination.new(site)
    generator.generate

    index.paginator.not_nil!.items.map(&.slug).should eq ["baz.md", "bar.md"]
  end
end
