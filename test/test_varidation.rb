# frozen_string_literal: true

require_relative 'test_helper'

module RbToon
  class TestVaridation < TestCase
    def test_array_size_mismatch
      toon = <<~'TOON'
        tags[2]: a,b,c
      TOON
      assert_parse_error(toon, 'expected 2 array items, but got 3')

      toon = <<~'TOON'
        tags[4]: a,b,c
      TOON
      assert_parse_error(toon, 'expected 4 array items, but got 3')

      toon = <<~'TOON'
        items[1]:
          - 1
          - 2
      TOON
      assert_parse_error(toon, 'expected 1 array items, but got 2')

      toon = <<~'TOON'
        items[3]:
          - 1
          - 2
      TOON
      assert_parse_error(toon, 'expected 3 array items, but got 2')

      toon = <<~'TOON'
        items[1]{id,name}:
          1,Ada
          2,Bob
      TOON
      assert_parse_error(toon, 'expected 1 tabular rows, but got 2')

      toon = <<~'TOON'
        items[3]{id,name}:
          1,Ada
          2,Bob
      TOON
      assert_parse_error(toon, 'expected 3 tabular rows, but got 2')
    end

    def test_tabular_row_size_mismatch
      toon = <<~'TOON'
        items[2]{id,name}:
          1,Ada
          2
      TOON
      assert_parse_error(toon, 'expected 2 tabular row items, but got 1')

      toon = <<~'TOON'
        items[2]{id}:
          1
          2,Ada
      TOON
      assert_parse_error(toon, 'expected 1 tabular row items, but got 2')
    end

    def test_invalid_escape_sequence
      toon = <<~'TOON'
        "a\x"
      TOON
      assert_parse_error(toon, 'invalid escape sequence: \x')
    end

    def test_mssing_closing_quote
      toon = <<~'TOON'
        "unterminated
      TOON
      assert_parse_error(toon, 'missing closing quote')

      toon = <<~'TOON'
        "unterminated\"
      TOON
      assert_parse_error(toon, 'missing closing quote')

      toon = <<~'TOON'
        "unterminated
        "
      TOON
      assert_parse_error(toon, 'missing closing quote')
    end

    def test_missing_colon
      toon = <<~'TOON'
        tags[2] a,b
      TOON
      assert_parse_error(toon)

      toon = <<~'TOON'
        tags[2]
          - a
          - b
      TOON
      assert_parse_error(toon)

      toon = <<~'TOON'
        items[2]{id,name}
          1,Ada
          2,Bob
      TOON
      assert_parse_error(toon)

      toon = <<~'TOON'
        a:
          user
      TOON
      assert_parse_error(toon)
    end

    def test_multiple_values_at_root_depth
      toon = <<~'TOON'
        hello
        world
      TOON
      assert_parse_error(toon, 'two or more values at root depth')

      toon = <<~'TOON'
        hello
        [1]: a
      TOON
      assert_parse_error(toon, 'two or more values at root depth')

      toon = <<~'TOON'
        hello
        a: b
      TOON
      assert_parse_error(toon, 'two or more values at root depth')

      toon = <<~'TOON'
        [1]: hello
        a
      TOON
      assert_parse_error(toon, 'two or more values at root depth')

      toon = <<~'TOON'
        [1]: hello
        [1]: world
      TOON
      assert_parse_error(toon, 'two or more values at root depth')

      toon = <<~'TOON'
        [1]: hello
        a: b
      TOON
      assert_parse_error(toon, 'two or more values at root depth')

      # Parse error is repored for the code below but not
      # 'multiple values at root depth' error
      toon = <<~'TOON'
        hello: world
        a
      TOON
      assert_parse_error(toon)

      toon = <<~'TOON'
        hello: world
        [1]: a
      TOON
      assert_parse_error(toon, 'two or more values at root depth')
    end

    def test_mismatched_delimiter
      # '1,2' is treated as a one unquoted string.
      toon = <<~'TOON'
        items[2	]{a	b}:
          1,2
          3,4
      TOON
      assert_parse_error(toon, 'expected 2 tabular row items, but got 1')

      # 'a,b' is treated as one unquoted string.
      toon = <<~'TOON'
        items[2	]{a,b}:
          1	2
          3	4
      TOON
      assert_parse_error(toon, 'expected 1 tabular row items, but got 2')
    end
  end
end
