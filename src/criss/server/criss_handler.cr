require "http"

class Criss::Server::CrissHandler # < Criss::Generator::List
  include HTTP::Handler

  def call(context)
    path = context.request.path.lchop

    #content_type = generate(context.response, path)

    #if content_type
    #  context.response.content_type = content_type
    #else
      call_next(context)
    #end
  end
end
