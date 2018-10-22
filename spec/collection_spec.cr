require "spec"
require "../src/collection"

describe Criss::Collection do
  it ".new" do
    collection = Criss::Collection.new("foo")

    collection.name.should eq "foo"
    collection.resources.should eq [] of Criss::Resource
  end

  it ".new with config" do
    config = Criss::Config::Collection.new
    collection = Criss::Collection.new("foo", config)

    collection.name.should eq "foo"
    collection.resources.should eq [] of Criss::Resource
    collection.defaults.should eq config
  end
end
