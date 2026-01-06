# frozen_string_literal: true

module Toonrb
  module Nodes
    class Base
      include RaiseParseError

      def initialize(position)
        @position = position
      end

      attr_reader :position

      [
        :array, :blank, :object, :empty_object, :root,
        :quoted_string, :unquoted_string, :empty_string,
        :boolean, :null, :number
      ].each do |kind|
        class_eval(<<~M, __FILE__, __LINE__ + 1)
          # def array?
          #   kind == :array
          # end
          def #{kind}?
            kind == :#{kind}
          end
        M
      end

      def validate(strict: true, path_expansion: false)
      end
    end
  end
end
