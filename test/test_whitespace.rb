# frozen_string_literal: true

require_relative 'test_helper'

module RbToon
  class TestWhiteSpace < TestCase
    def test_whitespace_tolerance
      toon = <<~'TOON'
        tags[3]: a , b , c
      TOON
      json = <<~'JSON'
        {"tags":["a","b","c"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        tags[3|]: a | b | c
      TOON
      json = <<~'JSON'
        {"tags":["a","b","c"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        tags[3	]: a 	 b 	 c
      TOON
      json = <<~'JSON'
        {"tags":["a","b","c"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]{id,name}:
          1 , Alice
          2 , Bob
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3]: "a" , "b" , "c"
      TOON
      json = <<~'JSON'
        {"items":["a","b","c"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))
    end

    def test_empty_string
      toon = <<~'TOON'
        items[3]: ,b,c
      TOON
      json = <<~'JSON'
        {"items":["","b","c"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3]: a,,c
      TOON
      json = <<~'JSON'
        {"items":["a","","c"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3]: a,b,
      TOON
      json = <<~'JSON'
        {"items":["a","b",""]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1]{a,b,c}:
          ,1,2
      TOON
      json = <<~'JSON'
        {"items": [{"a":"","b":1,"c":2}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1]{a,b,c}:
          0,,2
      TOON
      json = <<~'JSON'
        {"items": [{"a":0,"b":"","c":2}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1]{a,b,c}:
          0,1,
      TOON
      json = <<~'JSON'
        {"items": [{"a":0,"b":1,"c":""}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))
    end
  end
end
