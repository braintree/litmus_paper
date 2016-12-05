module LitmusPaper
  module Dependency
    class Base
      attr_reader :available

      def available?
        @available = yield
      end

      def result
        available ? 'OK' : 'FAIL'
      end
    end
  end
end
