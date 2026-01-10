# frozen_string_literal: true

require_relative 'test_helper'

module RbToon
  class TestPathExpansion < TestCase
    def test_path_expansion
      toon = <<~'TOON'
        a.b.c: 1
      TOON
      json = <<~'JSON'
        {"a":{"b":{"c":1}}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true))

      toon = <<~'TOON'
        data.meta.items[2]: a,b
      TOON
      json = <<~'JSON'
        {"data":{"meta":{"items":["a","b"]}}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true))

      toon = <<~'TOON'
        a.b.items[2]{id,name}:
          1,A
          2,B
      TOON
      json = <<~'JSON'
        {"a":{"b":{"items":[{"id":1,"name":"A"},{"id":2,"name":"B"}]}}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true))

      toon = <<~'TOON'
        a.b.c: 1
        a.b.d: 2
        a.e: 3
      TOON
      json = <<~'JSON'
        {"a":{"b":{"c":1,"d":2},"e":3}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true))

      toon = <<~'TOON'
        a.b.c:
      TOON
      json = <<~'JSON'
        {"a":{"b":{"c":{}}}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true))
    end

    def test_expansion_off
      toon = <<~'TOON'
        user.name: Ada
      TOON
      json = <<~'JSON'
        {"user.name":"Ada"}
      JSON
      assert_equal(load_json(json), decode_toon(toon))
    end

    def test_unexpandable_key
      toon = <<~'TOON'
        a.b: 1
        "c.d": 2
      TOON
      json = <<~'JSON'
        {"a":{"b":1},"c.d":2}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true))

      toon = <<~'TOON'
        full-name.x: 1
      TOON
      json = <<~'JSON'
        {"full-name.x":1}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true))
    end

    def test_key_conflict
      toon = <<~'TOON'
        a.b: 1
        a: 2
      TOON
      assert_parse_error(toon, 'key conflict at "a"', path_expansion: true)

      toon = <<~'TOON'
        a.b: 1
        a[2]: 2,3
      TOON
      assert_parse_error(toon, 'key conflict at "a"', path_expansion: true)
    end

    def test_key_conflict_without_strict_mode
      toon = <<~'TOON'
        a.b: 1
        a: 2
      TOON
      json = <<~'JSON'
        {"a":2}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true, strict: false))

      toon = <<~'TOON'
        a: 1
        a.b: 2
      TOON
      json = <<~'JSON'
        {"a":{"b":2}}
      JSON
      assert_equal(load_json(json), decode_toon(toon, path_expansion: true, strict: false))
    end
  end
end
