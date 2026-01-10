# frozen_string_literal: true

require_relative 'test_helper'

module RbToon
  class TestArray < TestCase
    def test_array_nested
      toon = <<~'TOON'
        items[2]:
          - id: 1
            name: First
          - id: 2
            name: Second
            extra: true
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"name":"First"},{"id":2,"name":"Second","extra":true}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3]:
          - first
          - second
          -
      TOON
      json = <<~'JSON'
        {"items":["first","second",{}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]:
          - properties:
              state:
                type: string
          - id: 2
      TOON
      json = <<~'JSON'
        {"items":[{"properties":{"state":{"type":"string"}}},{"id":2}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1]:
          - id: 1
            nested:
              x: 1
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"nested":{"x":1}}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1]:
          - users[2]{id,name}:
              1,Ada
              2,Bob
            status: active
      TOON
      json = <<~'JSON'
        {"items":[{"users":[{"id":1,"name":"Ada"},{"id":2,"name":"Bob"}],"status":"active"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1]:
          - name: test
            data[0]:
      TOON
      json = <<~'JSON'
        {"items":[{"name":"test","data":[]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1]:
          - matrix[2]:
              - [2]: 1,2
              - [2]: 3,4
            name: grid
      TOON
      json = <<~'JSON'
        {"items":[{"matrix":[[1,2],[3,4]],"name":"grid"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        pairs[2]:
          - [2]: a,b
          - [2]: c,d
      TOON
      json = <<~'JSON'
        {"pairs":[["a","b"],["c","d"]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        pairs[2]:
          - [2]: a,b
          - [3]: "c,d","e:f","true"
      TOON
      json = <<~'JSON'
        {"pairs":[["a","b"],["c,d","e:f","true"]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        pairs[2]:
          - [0]:
          - [0]:
      TOON
      json = <<~'JSON'
        {"pairs":[[],[]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        pairs[2]:
          - [1]: 1
          - [2]: 2,3
      TOON
      json = <<~'JSON'
        {"pairs":[[1],[2,3]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [5]: x,y,"true",true,10
      TOON
      json = <<~'JSON'
        ["x","y","true",true,10]
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [2]{id}:
          1
          2
      TOON
      json = <<~'JSON'
        [{"id":1},{"id":2}]
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [2]:
          - id: 1
          - id: 2
            name: Ada
      TOON
      json = <<~'JSON'
        [{"id":1},{"id":2,"name":"Ada"}]
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [0]:
      TOON
      json = <<~'JSON'
        []
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [2]:
          - [2]: 1,2
          - [0]:
      TOON
      json = <<~'JSON'
        [[1,2],[]]
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        user:
          id: 123
          name: Ada
          tags[2]: reading,gaming
          active: true
          prefs[0]:
      TOON
      json = <<~'JSON'
        {"user":{"id":123,"name":"Ada","tags":["reading","gaming"],"active":true,"prefs":[]}}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3]:
          - 1
          - a: 1
          - text
      TOON
      json = <<~'JSON'
        {"items":[1,{"a":1},"text"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]:
          - a: 1
          - [2]: 1,2
      TOON
      json = <<~'JSON'
        {"items":[{"a":1},[1,2]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        "x-items"[2]:
          - id: 1
          - id: 2
      TOON
      json = <<~'JSON'
        {"x-items":[{"id":1},{"id":2}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))
    end

    def test_array_primitive
      toon = 'tags[3]: reading,gaming,coding'
      json = '{"tags":["reading","gaming","coding"]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'nums[3]: 1,2,3'
      json = '{"nums":[1,2,3]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'data[4]: x,y,true,10'
      json = '{"data":["x","y",true,10]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'items[0]:'
      json = '{"items":[]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'items[1]: ""'
      json = '{"items":[""]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'items[3]: a,"",b'
      json = '{"items":["a","","b"]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'items[2]: " ","  "'
      json = '{"items":[" ","  "]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'items[3]: a,"b,c","d:e"'
      json = '{"items":["a","b,c","d:e"]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'items[4]: x,"true","42","-3.14"'
      json = '{"items":["x","true","42","-3.14"]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = 'items[3]: "[5]","- item","{key}"'
      json = '{"items":["[5]","- item","{key}"]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = '"my-key"[3]: 1,2,3'
      json = '{"my-key":[1,2,3]}'
      assert_equal(load_json(json), decode_toon(toon))

      toon = '"key[test]"[3]: 1,2,3'
      json = '{"key[test]":[1,2,3]}'
      assert_equal(load_json(json), decode_toon(toon))

      # TODO
      # Need to clarify specification of unquoted array key format
      # https://github.com/toon-format/spec/discussions/25
      #toon = 'key[test][3]: 1,2,3'
      #json = '{"key[test][3]":"1,2,3"}'
      #assert_equal(load_json(json), decode_toon(toon))

      toon = '"x-custom"[0]:'
      json = '{"x-custom":[]}'
      assert_equal(load_json(json), decode_toon(toon))
    end

    def test_array_tabular
      toon = <<~'TOON'
        items[2]{sku,qty,price}:
          A1,2,9.99
          B2,1,14.5
      TOON
      json = <<~'JSON'
        {"items":[{"sku":"A1","qty":2,"price":9.99},{"sku":"B2","qty":1,"price":14.5}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]{id,value}:
          1,null
          2,"test"
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"value":null},{"id":2,"value":"test"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]{id,note}:
          1,"a:b"
          2,"c:d"
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"note":"a:b"},{"id":2,"note":"c:d"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]{"order:id","full name"}:
          1,Ada
          2,Bob
      TOON
      json = <<~'JSON'
        {"items":[{"order:id":1,"full name":"Ada"},{"order:id":2,"full name":"Bob"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        "x-items"[2]{id,name}:
          1,Ada
          2,Bob
      TOON
      json = <<~'JSON'
        {"x-items":[{"id":1,"name":"Ada"},{"id":2,"name":"Bob"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]{id,name}:
          1,Alice
          2,Bob
        count: 2
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}],"count":2}
      JSON
      assert_equal(load_json(json), decode_toon(toon))
    end

    def test_delimiter
      toon = <<~'TOON'
        tags[3	]: reading	gaming	coding
      TOON
      json = <<~'JSON'
        {"tags":["reading","gaming","coding"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        tags[3|]: reading|gaming|coding
      TOON
      json = <<~'JSON'
        {"tags":["reading","gaming","coding"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        tags[3]: reading,gaming,coding
      TOON
      json = <<~'JSON'
        {"tags":["reading","gaming","coding"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2	]{sku	qty	price}:
          A1	2	9.99
          B2	1	14.5
      TOON
      json = <<~'JSON'
        {"items":[{"sku":"A1","qty":2,"price":9.99},{"sku":"B2","qty":1,"price":14.5}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2|]{sku|qty|price}:
          A1|2|9.99
          B2|1|14.5
      TOON
      json = <<~'JSON'
        {"items":[{"sku":"A1","qty":2,"price":9.99},{"sku":"B2","qty":1,"price":14.5}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        pairs[2	]:
          - [2	]: a	b
          - [2	]: c	d
      TOON
      json = <<~'JSON'
        {"pairs":[["a","b"],["c","d"]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        pairs[2|]:
          - [2|]: a|b
          - [2|]: c|d
      TOON
      json = <<~'JSON'
        {"pairs":[["a","b"],["c","d"]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1	]:
          - tags[3]: a,b,c
      TOON
      json = <<~'JSON'
        {"items":[{"tags":["a","b","c"]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1	]:
          - tags[3|]: a|b|c
      TOON
      json = <<~'JSON'
        {"items":[{"tags":["a","b","c"]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1|]:
          - tags[3]: a,b,c
      TOON
      json = <<~'JSON'
        {"items":[{"tags":["a","b","c"]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[1|]:
          - tags[3	]: a	b	c
      TOON
      json = <<~'JSON'
        {"items":[{"tags":["a","b","c"]}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [3	]: x	y	z
      TOON
      json = <<~'JSON'
        ["x","y","z"]
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [3|]: x|y|z
      TOON
      json = <<~'JSON'
        ["x","y","z"]
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [2	]{id}:
          1
          2
      TOON
      json = <<~'JSON'
        [{"id":1},{"id":2}]
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        [2|]{id}:
          1
          2
      TOON
      json = <<~'JSON'
        [{"id":1},{"id":2}]
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3	]: a	"b\tc"	d
      TOON
      json = <<~'JSON'
        {"items":["a","b\tc","d"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3|]: a|"b|c"|d
      TOON
      json = <<~'JSON'
        {"items":["a","b|c","d"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2	]: a,b	c,d
      TOON
      json = <<~'JSON'
        {"items":["a,b","c,d"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2|]: a,b|c,d
      TOON
      json = <<~'JSON'
        {"items":["a,b","c,d"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]{id,note}:
          1,"a,b"
          2,"c,d"
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"note":"a,b"},{"id":2,"note":"c,d"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2	]{id	note}:
          1	a,b
          2	c,d
      TOON
      json = <<~'JSON'
        {"items":[{"id":1,"note":"a,b"},{"id":2,"note":"c,d"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2	]:
          - status: a,b
          - status: c,d
      TOON
      json = <<~'JSON'
        {"items":[{"status":"a,b"},{"status":"c,d"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2]:
          - status: "a,b"
          - status: "c,d"
      TOON
      json = <<~'JSON'
        {"items":[{"status":"a,b"},{"status":"c,d"}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        pairs[1|]:
          - [2|]: a|"b|c"
      TOON
      json = <<~'JSON'
        {"pairs":[["a","b|c"]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        pairs[1	]:
          - [2	]: a	"b\tc"
      TOON
      json = <<~'JSON'
        {"pairs":[["a","b\tc"]]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3|]: "true"|"42"|"-3.14"
      TOON
      json = <<~'JSON'
        {"items":["true","42","-3.14"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3	]: "true"	"42"	"-3.14"
      TOON
      json = <<~'JSON'
        {"items":["true","42","-3.14"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3|]: "[5]"|"{key}"|"- item"
      TOON
      json = <<~'JSON'
        {"items":["[5]","{key}","- item"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[3	]: "[5]"	"{key}"	"- item"
      TOON
      json = <<~'JSON'
        {"items":["[5]","{key}","- item"]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))

      toon = <<~'TOON'
        items[2|]{"a|b"}:
          1
          2
      TOON
      json = <<~'JSON'
        {"items":[{"a|b":1},{"a|b":2}]}
      JSON
      assert_equal(load_json(json), decode_toon(toon))
    end
  end
end
