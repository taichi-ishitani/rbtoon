# frozen_string_literal: true

module Toonrb
  module Nodes
    class Root < Node
      def initialize
        @items = []
        super(nil)
      end

      attr_reader :items

      def to_ruby
        @items.first&.to_ruby
      end
    end
  end
end
