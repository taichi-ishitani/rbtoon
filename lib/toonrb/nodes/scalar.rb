# frozen_string_literal: true

module Toonrb
  module Nodes
    class Scalar < Base
      def initialize(token)
        super(token.position)
        @token = token
      end

      attr_reader :token
    end

    class QuotedString < Scalar
      def to_ruby
        token.text[1..-2]
      end

      def kind
        :quoted_string
      end
    end

    class UnquotedString < Scalar
      def concat(other_token)
        token.text.concat(other_token.text)
      end

      def to_ruby
        token.text.strip
      end

      def kind
        :unquoted_string
      end
    end

    class Boolean < Scalar
      def to_ruby
        token.text.strip == 'true'
      end

      def kind
        :boolean
      end
    end

    class Null < Scalar
      def to_ruby
        nil
      end

      def kind
        :null
      end
    end

    class Number < Scalar
      def to_ruby
        text = token.text.strip
        if text.match?(/[.e]/i)
          value_f = text.to_f
          value_i = value_f.to_i
          value_f == value_i ? value_i : value_f
        else
          text.to_i
        end
      end

      def kind
        :number
      end
    end
  end
end
