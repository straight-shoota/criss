require "http/server"

class Criss::Server
  getter site : Site

  def initialize(@site : Site)
  end

  def handle(context : HTTP::Server::Context)
    path = context.request.path

    p! path
    resource = site.find(path)
    p! resource

    unless resource
      context.response.respond_with_error "Not Found", code: 404
      context.response.close
      return
    end

    site.run_processor(context.response, resource)
  end
end
