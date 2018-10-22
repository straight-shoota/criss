require "spec"
require "../src/config.cr"

describe Criss::Config do
  # File.open("spec/fixtures/_config.default.yml", "w") do |io|
  #   Criss::Config.new.to_yaml(io)
  # end

  it ".from_yaml" do
    File.open("spec/fixtures/_config.default.yml", "r") do |io|
      Criss::Config.from_yaml(io)
    end.should eq Criss::Config.new
  end

  it ".load_file" do
    Criss::Config.load_file("spec/fixtures/_config.default.yml").should eq Criss::Config.new
  end

  it ".load" do
    Criss::Config.load("spec/fixtures/simple-site/").should eq Criss::Config.new(site_dir: "spec/fixtures/simple-site/")
  end
end
