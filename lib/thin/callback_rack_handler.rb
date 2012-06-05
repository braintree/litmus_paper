module Thin
  class CallbackRackHandler
    def self.run(app, options)
      server = ::Thin::Server.new(options[:Host] || '0.0.0.0',
                                  options[:Port] || 8080,
                                  app,
                                  options)
      yield server if block_given?
      server.start
    end
  end
end

Rack::Handler.register 'thin-with-callbacks', Thin::CallbackRackHandler
