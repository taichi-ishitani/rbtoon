# frozen_string_literal: true

module Toonrb
  module Nodes
    class Scalar < Node
      alias_method :token, :head_token
    end

    class QuotedString < Scalar
      def to_ruby
        token.text[1..-2]
      end
    end

    class UnquotedString < Scalar
      def to_ruby
        token.text
      end
    end

    class Boolean < Scalar
      def to_ruby
        token.text == 'true'
      end
    end

    class Null < Scalar
      def to_ruby
        nil
      end
    end

    class Number < Scalar
      def to_ruby
        if token.text.match?(/[.e]/i)
          value_f = token.text.to_f
          value_i = value_f.to_i
          value_f == value_i ? value_i : value_f
        else
          token.text.to_i
        end
      end
    end
  end
end
