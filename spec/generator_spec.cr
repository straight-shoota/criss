require "./spec_helper.cr"

private def generate(path)
  generators = Criss::Generator::List.new(context, [
    Criss::SassGenerator.new(context),
    Criss::PageGenerator.new(context)
  ] of Criss::Generator)

  generators.generate(path)
end

private def context
  Criss::Context.new(File.join(__DIR__, "fixtures"))
end

describe Criss::SassGenerator do
  it "generates file" do
    result = Criss::SassGenerator.new(context).generate "simple.css"
    result.body.should eq "html body {\n  color: red; }\n"
  end
  it "responds to non-existing scss file" do
    result = Criss::SassGenerator.new(context).generate "does-not-exist.css"
    result.content_type.should be_nil
  end
  it "does not return scss file directly" do
    result = Criss::SassGenerator.new(context).generate "simple.scss"
    result.content_type.should be_nil
  end
  it "lists entries" do
    entries = Criss::SassGenerator.new(context).list_entries
    entries.map { |entry| entry.as(Criss::FileEntry).file_path.should eq "/simple.scss" }
  end
end

describe Criss::PageGenerator do
  {"simple.html", "simple/", "simple"}.each do |path|
    it "generates file for path #{path}" do
      result = Criss::PageGenerator.new(context).generate path
      result.body.should eq "<html>\n  <title>\n    Hello World\n  </title>\n</html>"
    end
  end
  {"index.html", "/", ""}.each do |path|
    it "generates file for path #{path}" do
      result = Criss::PageGenerator.new(context).generate path
      result.body.should eq "<html>\n  <title>index</title>\n<p>Index</p>\n</html>"
    end
  end
  it "responds to non-existing html file" do
    result = Criss::PageGenerator.new(context).generate "does-not-exist.html"
    result.content_type.should be_nil
  end
  it "lists entries" do
    entries = Criss::PageGenerator.new(context).list_entries
    page_names = ["/index.md", "/simple.html"]
    entries.map { |entry| page_names.should contain(entry.as(Criss::Page).file_path) }
  end
end

describe Criss::PostGenerator do
  {"posts/2017-07-16-my-first-post.html", "posts/2017-07-16-my-first-post/", "posts/2017-07-16-my-first-post"}.each do |path|
    it "generates file for path #{path}" do
      result = Criss::PostGenerator.new(context).generate path
      result.body.should eq "<h1>My first post</h1>\n\n<p>Hello World!</p>\n<aside>by straight-shoota</aside>"
    end
  end
  {"posts/2017-08-07-markdown.html", "posts/2017-08-07-markdown/", "posts/2017-08-07-markdown"}.each do |path|
    it "generates file for path #{path}" do
      result = Criss::PostGenerator.new(context).generate path
      result.body.should eq %(<h1>Markdown Support</h1>\n<p>CRISS supports markdown via <a href="https://github.com/icyleaf/markd">icyleaf/markd</a>.</p>\n<aside>by straight-shoota</aside>)
    end
  end
  it "responds to non-existing html file" do
    result = Criss::PostGenerator.new(context).generate "posts/2017-05-03-does-not-exist.html"
    result.content_type.should be_nil
  end
  it "lists entries" do
    entries = Criss::PostGenerator.new(context).list_entries
    page_names = ["/_posts/2017-07-16-my-first-post.html", "/_posts/2017-08-07-markdown.md"]
    entries.map { |entry| page_names.should contain(entry.as(Criss::Post).file_path) }
  end
end

describe Criss::Generator do
  it "resolves sass path" do
    result = generate "simple.css"
    result.body.should eq "html body {\n  color: red; }\n"
  end
end
