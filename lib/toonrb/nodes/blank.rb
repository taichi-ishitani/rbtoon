# frozen_string_literal: true

module Toonrb # :nodoc: all
  module Nodes
    class Blank < Base
      def initialize(token)
        super(token.position)
      end

      def kind
        :blank
      end
    end
  end
end
