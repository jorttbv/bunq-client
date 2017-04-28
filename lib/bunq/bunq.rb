require 'rest-client'
require_relative './client'
require_relative './signature'
require_relative 'paginated'

RestClient.add_before_execution_proc do |req, params|
  next unless params[:url].include?('bunq.com')
  req['X-Bunq-Client-Request-Id'] = params[:headers][:'X-Bunq-Client-Request-Id'] = SecureRandom.uuid

  # can't sign the creation of an installation
  # see https://doc.bunq.com/api/1/call/installation/method/post
  next if params[:url].end_with?('/installation') && req.method == 'POST'
  req['X-Bunq-Client-Signature'] = Bunq.signature.create(
    params[:method].upcase,
    req.path,
    params[:headers],
    params[:payload]
  )
end
