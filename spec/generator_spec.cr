require "./spec_helper.cr"

private def generate(path)
  generators = Criss::Generator::List.new(context, [
    Criss::SassGenerator.new(context),
    Criss::HTMLGenerator.new(context)
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
end

describe Criss::HTMLGenerator do
  {"simple.html", "simple/", "simple"}.each do |path|
    it "generates file for path #{path}" do
      result = Criss::HTMLGenerator.new(context).generate path
      result.body.should eq "<html>\n  <title>\n    Hello World\n  </title>\n</html>"
    end
  end
  it "responds to non-existing html file" do
    result = Criss::HTMLGenerator.new(context).generate "does-not-exist.html"
    result.content_type.should be_nil
  end
end

describe Criss::PostGenerator do
  {"posts/2017-07-16-my-first-post.html", "posts/2017-07-16-my-first-post/", "posts/2017-07-16-my-first-post"}.each do |path|
    it "generates file for path #{path}" do
      result = Criss::PostGenerator.new(context).generate path
      result.body.should eq "<h1>My first post</h1>\n\n<p>Hello World!</p>\n<aside>by Johannes</aside>"
    end
  end
  it "responds to non-existing html file" do
    result = Criss::PostGenerator.new(context).generate "posts/2017-05-03-does-not-exist.html"
    result.content_type.should be_nil
  end
end

describe Criss::Generator do
  it "resolves sass path" do
    result = generate "simple.css"
    result.body.should eq "html body {\n  color: red; }\n"
  end
end
