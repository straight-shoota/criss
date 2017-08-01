require "./spec_helper"
require "../src/criss/server"

private def make_request(server, url)
  io = IO::Memory.new
  request = HTTP::Request.new("GET", url)
  response = HTTP::Server::Response.new(io)
  context = HTTP::Server::Context.new(request, response)
  server.server.processor.handler.call(context)
  response.close
  io.rewind
  HTTP::Client::Response.from_io(io, decompress: false)
end

class HTTP::Server::RequestProcessor
  getter handler
end
class HTTP::Server
  getter processor
end

describe Criss::Server do
  it "serves" do
    server = Criss::Server.new
    server.setup
    response =  make_request(server, "/css/main.css")
  end
end
