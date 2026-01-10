# frozen_string_literal: true

require_relative 'test_helper'

module RbToon
  class TestObject < TestCase
    def test_object
      toon = decode_toon(<<~'TOON')
        id: 123
        name: Ada
        active: true
      TOON
      json = load_json(<<~'JSON')
        {"id":123,"name":"Ada","active":true}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        id: 123
        value: null
      TOON
      json = load_json(<<~'JSON')
        {"id":123,"value":null}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        user:
      TOON
      json = load_json(<<~'JSON')
        {"user":{}}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        note: "a:b"
      TOON
      json = load_json(<<~'JSON')
        {"note":"a:b"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        note: "a,b"
      TOON
      json = load_json(<<~'JSON')
        {"note":"a,b"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        text: "line1\nline2"
      TOON
      json = load_json(<<~'JSON')
        {"text":"line1\nline2"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        text: "say \"hello\""
      TOON
      json = load_json(<<~'JSON')
        {"text":"say \u0022hello\u0022"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        text: " padded "
      TOON
      json = load_json(<<~'JSON')
        {"text":" padded "}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        text: "  "
      TOON
      json = load_json(<<~'JSON')
        {"text":"  "}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        v: "true"
      TOON
      json = load_json(<<~'JSON')
        {"v":"true"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        v: "42"
      TOON
      json = load_json(<<~'JSON')
        {"v":"42"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        v: "-7.5"
      TOON
      json = load_json(<<~'JSON')
        {"v":"-7.5"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "order:id": 7
      TOON
      json = load_json(<<~'JSON')
        {"order:id":7}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "[index]": 5
      TOON
      json = load_json(<<~'JSON')
        {"[index]":5}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "{key}": 5
      TOON
      json = load_json(<<~'JSON')
        {"{key}":5}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "a,b": 1
      TOON
      json = load_json(<<~'JSON')
        {"a,b":1}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "full name": Ada
      TOON
      json = load_json(<<~'JSON')
        {"full name":"Ada"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "-lead": 1
      TOON
      json = load_json(<<~'JSON')
        {"-lead":1}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        " a ": 1
      TOON
      json = load_json(<<~'JSON')
        {" a ":1}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "123": x
      TOON
      json = load_json(<<~'JSON')
        {"123":"x"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "": 1
      TOON
      json = load_json(<<~'JSON')
        {"":1}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        user.name: Ada
      TOON
      json = load_json(<<~'JSON')
        {"user.name":"Ada"}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        _private: 1
      TOON
      json = load_json(<<~'JSON')
        {"_private":1}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        user_name: 1
      TOON
      json = load_json(<<~'JSON')
        {"user_name":1}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "line\nbreak": 1
      TOON
      json = load_json(<<~'JSON')
        {"line\nbreak":1}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "tab\there": 2
      TOON
      json = load_json(<<~'JSON')
        {"tab\there":2}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        "he said \"hi\"": 1
      TOON
      json = load_json(<<~'JSON')
        {"he said \u0022hi\u0022":1}
      JSON
      assert_equal(json, toon)

      toon = decode_toon(<<~'TOON')
        a:
          b:
            c: deep
      TOON
      json = load_json(<<~'JSON')
        {"a":{"b":{"c":"deep"}}}
      JSON
      assert_equal(json, toon)
    end

    def test_empty_document
      toon = decode_toon(<<~'TOON')

      TOON
      assert_equal({}, toon)
    end
  end
end
