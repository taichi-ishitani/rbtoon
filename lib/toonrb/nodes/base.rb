# frozen_string_literal: true

module Toonrb
  module Nodes
    class Base
      include RaiseParseError

      def initialize(position)
        @position = position
      end

      attr_reader :position

      def validate(strict: true, path_expansion: false)
      end
    end
  end
end
