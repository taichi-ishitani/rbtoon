# frozen_string_literal: true

require_relative 'test_helper'

module RbToon
  class TestIndentation < TestCase
    def test_wrong_indent_spaces
      toon = <<~'TOON'
        a:
           b: 1
      TOON
      assert_parse_error(toon, 'indentation must be exact multiple of 2, but found 3 spaces')

      toon = <<~'TOON'
        items[2]:
           - id: 1
           - id: 2
      TOON
      assert_parse_error(toon, 'indentation must be exact multiple of 2, but found 3 spaces')

      toon = <<~'TOON'
        a:
           b: 1
      TOON
      json = <<~'JSON'
        {"a":{"b":1}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))

      toon = <<~'TOON'
        a:
           b:
             c: 1
      TOON
      json = <<~'JSON'
        {"a":{"b":{"c":1}}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))
    end

    def test_custom_indent_size
      toon = <<~'TOON'
        a:
            b: 1
      TOON
      json = <<~'JSON'
        {"a": {"b": 1}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, indent_size: 4))

      toon = <<~'TOON'
        a:
          b: 1
      TOON
      assert_parse_error(toon, 'indentation must be exact multiple of 4, but found 2 spaces', indent_size: 4)

      toon = <<~'TOON'
        items[2]:
            - id: 1
            - id: 2
      TOON
      json = <<~'JSON'
        {"items": [{"id":1},{"id":2}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon, indent_size: 4))

      toon = <<~'TOON'
        items[2]:
          - id: 1
          - id: 2
      TOON
      assert_parse_error(toon, 'indentation must be exact multiple of 4, but found 2 spaces', indent_size: 4)
    end

    def test_tab_in_indent
      toon = <<~'TOON'
        a:
        	b: 1
      TOON
      assert_parse_error(toon, "tabs are not allowed in indentation")

      toon = <<~'TOON'
        a:
         	b: 1
      TOON
      assert_parse_error(toon, "tabs are not allowed in indentation")

      toon = "\ta: 1"
      assert_parse_error(toon, "tabs are not allowed in indentation")
    end

    def test_tab_in_string
      toon = <<~'TOON'
        text: "hello	world"
      TOON
      json = <<~'JSON'
        {"text":"hello\tworld"}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        "key	tab": value
      TOON
      json = <<~'JSON'
        {"key\ttab":"value"}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]: "a	b","c	d"
      TOON
      json = <<~'JSON'
        {"items":["a\tb","c\td"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))
    end
  end
end
