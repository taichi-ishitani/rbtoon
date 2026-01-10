# frozen_string_literal: true

require_relative '../lib/rbtoon'
require 'minitest/autorun'
require 'json'
require 'tempfile'

module RbToon
  class TestCase < Minitest::Test
    private

    def decode_toon(toon, **)
      RbToon.decode(toon, **)
    end

    def load_json(json, **)
      JSON.parse(json, **)
    end

    def assert_parse_error(toon, message = nil, **)
      error = assert_raises(ParseError) do
        decode_toon(toon, **)
      end
      message && assert_equal(message, error.error_message)
    end
  end
end
