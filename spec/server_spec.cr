require "./spec_helper"
require "../src/server"

private def send_request(server : Criss::Server, url : String) : HTTP::Client::Response
  request = HTTP::Request.new("GET", url)
  io = IO::Memory.new
  response = HTTP::Server::Response.new(io)
  context = HTTP::Server::Context.new(request, response)

  server.handle(context)
  response.close

  io.rewind
  HTTP::Client::Response.from_io(io)
end

describe Criss::Server do
  it do
    site = load_site("simple-site")

    server = Criss::Server.new(site)

    response = send_request(server, "/2017/08/07/markdown.html")
    response.success?.should be_true
    response.body.should eq File.read(File.join(site.site_dir, "/_build/2017/08/07/markdown.html"))
  end
end
