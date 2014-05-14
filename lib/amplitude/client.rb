module Amplitude
  class Client
    include HTTParty

    attr_accessor :session_id

    SESSION_HEADER = 'x-transmission-session-id'

    def initialize(opts)
      self.class.base_uri opts[:url]
      self.class.debug_output if opts[:debug]
      self.class.basic_auth opts[:username], opts[:password] if opts[:username]
      @session_id = ''
    end

    def action(method, args = {})
      response = self.class.post(
        '/',
        body: {
          method: method,
          arguments: args
        }.to_json,
        headers: { SESSION_HEADER => session_id }
      )

      case response.code
      when 200
        response['arguments'] ? response['arguments'] : response
      when 409
        @session_id = response.headers[SESSION_HEADER]
        action method, args
      when 401
        fail AuthenticationError.new('Unauthorized', response.code)
      when 500..599
        fail ActionError.new(response.body, response.code)
      end
    end
  end
end
