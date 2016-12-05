module LitmusPaper
  module Dependency
    class Base
      attr_reader :available

      def available?
        return @available unless @available.nil?
        @available = yield
      end

      def result
        available ? 'OK' : 'FAIL'
      end
    end
  end
end
