require "spec"
require "../../src/generator"

describe Criss::Generator::Collections do
  it "reads files" do
    site = Criss::Site.new("spec/fixtures/simple-site")
    generator = Criss::Generator::Collections.new(site, ["_posts"])
    generator.generate

    resource = site.collections["posts"].resources.first
    resource.slug.should eq "2017-07-16-my-first-post.html"
    # resource.output_path("/").should eq "/2017-07-16-my-first-post.html"
    resource.output_path("/").should eq "/posts/2017-07-16-my-first-post/index.html"
    resource.directory.should eq "_posts"
    resource.generator.should eq generator
    resource.content.should eq "\n<p>Hello World!</p>\n"
    resource.title.should eq "My first post"
    resource["author"].should eq "straight-shoota"
  end

  it "applies defaults" do
    config = Criss::Config.new
    config.site_dir = "spec/fixtures/simple-site"
    config.defaults = [Criss::Config::Defaults.new(Criss::Config::Scope.new(type: "posts"), Criss::Frontmatter{"defaults_applied" => true})]

    site = Criss::Site.new(config)
    generator = Criss::Generator::Collections.new(site, ["_posts"])
    generator.generate

    site.collections["posts"].resources.first["defaults_applied"].should be_true
  end
end
