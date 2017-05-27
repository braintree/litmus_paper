module LitmusPaper
  module Dependency
    class Base
      attr_reader :available

      def available?
        @available = _available?
      end

      def result
        available ? 'OK' : 'FAIL'
      end

      def _available?
        raise NotImplementedError
      end
    end
  end
end
