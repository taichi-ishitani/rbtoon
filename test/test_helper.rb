# frozen_string_literal: true

require_relative '../lib/toonrb'
require 'minitest/autorun'
require 'json'

module Toonrb
  class TestCase < Minitest::Test
    private

    def load_toon(toon, **)
      Toonrb.load(toon, **)
    end

    def load_json(json)
      JSON.load(json)
    end

    def assert_parse_error(toon, message = nil)
      error = assert_raises(ParseError, Racc::ParseError) do
        load_toon(toon)
      end
      message && assert_equal(message, error.error_message)
    end
  end
end
