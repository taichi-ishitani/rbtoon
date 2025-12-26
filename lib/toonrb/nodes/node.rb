# frozen_string_literal: true

module Toonrb
  module Nodes
    class Node
      def initialize(head_token)
        @head_token = head_token
      end

      attr_reader :head_token
    end
  end
end
