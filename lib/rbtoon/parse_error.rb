# frozen_string_literal: true

module RbToon
  ##
  # The exception class is raised when the given Toon includes errors.
  #
  # Fields:
  # +error_message+::
  #   Message string of the detected error.
  # +position+::
  #   Position information where the error is detected.
  class ParseError < StandardError
    def initialize(error_message, position)
      super(error_message)
      @error_message = error_message
      @position = position
    end

    ##
    # Read accessor to +error_message+ field.
    attr_reader :error_message

    ##
    # Read accessor to +position+ field.
    attr_reader :position

    ##
    # Return the +error_message+ string.
    # The +position+ information is also included if provided.
    def to_s
      (position && "#{super} -- #{position}") || super
    end
  end

  module RaiseParseError # :nodoc:
    private

    def raise_parse_error(message, position = nil)
      raise ParseError.new(message, position)
    end
  end
end
