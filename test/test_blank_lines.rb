# frozen_string_literal: true

require_relative 'test_helper'

module RbToon
  class TestBlankLines < TestCase
    def test_blank_lines_inside_array
      toon = <<~'TOON'
        items[3]:
          - a

          - b
          - c
      TOON
      assert_parse_error(toon, "blank lines inside array are not allowed")

      toon = <<~'TOON'
        items[2]{id}:
          1

          2
      TOON
      assert_parse_error(toon, "blank lines inside tabular rows are not allowed")

      toon = <<~'TOON'
        items[2]:
          - a


          - b
      TOON
      assert_parse_error(toon, "blank lines inside array are not allowed")

      toon = [
        'items[2]:',
        '  - a',
        '  ',
        '  - b',
      ].join("\n")
      assert_parse_error(toon, "blank lines inside array are not allowed")

      toon = <<~'TOON'
        outer[2]:
          - inner[2]:
              - a

              - b
          - x
      TOON
      assert_parse_error(toon, "blank lines inside array are not allowed")

      toon = <<~'TOON'
        outer[1]:
          - inner[2]:
              - [1]: a

              - [1]: b
      TOON
      assert_parse_error(toon, "blank lines inside array are not allowed")

      toon = <<~'TOON'
        outer[1]:
          - inner[1]:
              - a: 0

                b: 1
      TOON
      assert_parse_error(toon, "blank lines inside array are not allowed")

      toon = <<~'TOON'
        outer[1]:
          - inner[1]:

              - 0
      TOON
      assert_parse_error(toon, "blank lines inside array are not allowed")

      toon = <<~'TOON'
        outer[1]:
          - inner[1]:
              - a:

                  b: 0
      TOON
      assert_parse_error(toon, "blank lines inside array are not allowed")
    end

    def test_blank_lines_inside_array_without_strict_mode
      toon = <<~'TOON'
        items[3]:
          - a

          - b
          - c
      TOON
      json = <<~'JSON'
        {"items":["a","b","c"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))

      toon = <<~'TOON'
        items[2]{id,name}:
          1,Alice

          2,Bob
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))

      toon = <<~'TOON'
        items[2]:
          - a


          - b
      TOON
      json = <<~'JSON'
        {"items":["a","b"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))

      toon = <<~'TOON'
        outer[1]:
          - inner[2]:
              - [1]: a

              - [1]: b
      TOON
      json = <<~'JSON'
        {"outer":[{"inner":[["a"],["b"]]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))

      toon = <<~'TOON'
        outer[1]:
          - inner[1]:
              - a: 0

                b: 1
      TOON
      json = <<~'JSON'
        {"outer":[{"inner":[{"a":0,"b":1}]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))

      toon = <<~'TOON'
        outer[1]:
          - inner[1]:

              - 0
      TOON
      json = <<~'JSON'
        {"outer":[{"inner":[0]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))

      toon = <<~'TOON'
        outer[1]:
          - inner[1]:
              - a:

                  b: 0
      TOON
      json = <<~'JSON'
        {"outer":[{"inner":[{"a":{"b":0}}]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon, strict: false))
    end

    def test_blank_lines_outside_array
      toon = <<~'TOON'
        a: 1

        b: 2
      TOON
      json = <<~'JSON'
        {"a":1,"b":2}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        a: 1

      TOON
      json = <<~'JSON'
        {"a":1}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        a: 1




      TOON
      json = <<~'JSON'
        {"a":1}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1]:
          - a

        b: 2
      TOON
      json = <<~'JSON'
        {"items":["a"],"b":2}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        a:
          b: 1

          c: 2
      TOON
      json = <<~'JSON'
        {"a":{"b":1,"c":2}}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        a:
          b: 1

          c: 2
      TOON
      json = <<~'JSON'
        {"a":{"b":1,"c":2}}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        outer[1]:
          - inner[2]:
              - [1]: a
              - [1]: b

        c: d
      TOON
      json = <<~'JSON'
        {"outer":[{"inner":[["a"],["b"]]}],"c":"d"}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        outer[1]:
          - inner[1]:
              - a: 0
                b: 1

        c: 2
      TOON
      json = <<~'JSON'
        {"outer":[{"inner":[{"a":0,"b":1}]}],"c":2}
      JSON
      assert_equal(load_json(json), decode_toon(toon))
    end
  end
end
