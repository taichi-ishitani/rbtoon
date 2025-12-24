# frozen_string_literal: true

require_relative 'test_helper'

module Toonrb
  class TestPrimitive < TestCase
    def test_true
      assert_equal(load_json('true'), load_toon('true'))
    end

    def test_false
      assert_equal(load_json('false'), load_toon('false'))
    end

    def test_null
      assert_nil(load_toon('null'))
    end

    def test_integer
      100.times do |i|
        result = load_toon("#{i}")
        assert_equal(i, result)
        assert_instance_of(::Integer, result)

        result = load_toon("-#{i}")
        assert_equal(-i, result)
        assert_instance_of(::Integer, result)
      end
    end

    def test_float
      {
        '1.500' => 1.5, '-1E+03' => -1000, '2.5e2' => 250, '3E-02' => 0.03,
        '-0.0' => 0, '0.0' => 0, '1e-10' => 0.0000000001, '5E+00' => 5,
        '1e6' => 1000000, '1E+6' => 1000000, '-1e-3' => -0.001
      }.each do |toon, number|
        result = load_toon(toon)
        assert_equal(number, result)
        assert_instance_of(number.class, result)
      end
    end

    def test_unquoted_string
      ['hello', 'Ada_99', 'café', '你好', '🚀', 'hello 👋 world', '05', '007', '0123'].each do |string|
        assert_equal(string, load_toon(string))
      end
    end

    def test_quoted_string
      [
        '', "line1\nline2", "tab\there", "return\rcarriag", "C:\\Users\\path",
        "say \"hello\"", 'true', 'false', 'null', '42', '-3.14', '1e-6', '05'
      ].each do |string|
        escaped_string = string.gsub(/[\n\r\t\\"]/) do |c|
          c = { "\n" => 'n', "\r" => 'r', "\t" => 't', '"' => '"', '\\' => '\\' }[c]
          "\\#{c}"
        end
        result = load_toon("\"#{escaped_string}\"")
        assert_equal(string, result)
      end
    end
  end
end
