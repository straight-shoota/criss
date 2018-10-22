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
end
