# frozen_string_literal: true

require_relative 'test_helper'

module Toonrb
  class TestArray < TestCase
    def test_root_array
      toon = '[5]: x,y,"true",true,10'
      json = '["x", "y", "true", true, 10]'
      assert_equal(load_json(json), load_toon(toon))

      # TODO
      #toon = <<~'TOON'
      #  [2]{id}:
      #    1
      #    2
      #TOON
      #json = '[{"id": 1}, {"id": 2}]'
      #assert_equal(load_json(json), load_toon(toon))

      # TODO
      #toon = <<~'TOON'
      #  [2]:
      #    - id: 1
      #    - id: 2
      #      name: Ada
      #TOON
      #json = '[{"id": 1}, {"id" 2, "name": "Ada"}]'
      #assert_equal(load_json(json), load_toon(toon))

      toon = '[0]:'
      json = '[]'
      assert_equal(load_json(json), load_toon(toon))

      #toon = <<~'TOON'
      #[2]:
      #  - [2]: 1, 2
      #  - [0]:
      #TOON
      #json = '[[1, 2], []]'
      #assert_equal(load_json(json), load_toon(toon))
    end
  end
end
