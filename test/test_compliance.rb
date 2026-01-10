# frozen_string_literal: true

require_relative 'test_helper'

module RbToon
  class TestCompliance < TestCase
    FIXTURES_DIR = File.join(__dir__, 'spec', 'tests', 'fixtures', 'decode')
    FIXTURES = Dir.glob('*.json', base: FIXTURES_DIR)

    def test_compliance
      FIXTURES.each do |fixture|
        fixture = JSON.load_file(File.join(FIXTURES_DIR, fixture))
        fixture['tests'].each do |test|
          run_compliance_test(test)
        end
      end
    end

    def run_compliance_test(test)
      testname, options = extract_options(test)
      message = "test '#{test['name']}' is failed"
      if test['shouldError']
        assert_raises(ParseError, message) do
          decode_toon(test['input'], filename: testname, **options)
        end
        assert_raises(ParseError, message) do
          decode_toon_file(test['input'], testname, **options)
        end
      elsif test['expected'].nil?
        assert_nil(decode_toon(test['input'], filename: testname, **options), message)
        assert_nil(decode_toon_file(test['input'], testname, **options), message)
      else
        assert_equal(test['expected'], decode_toon(test['input'], filename: testname, **options), message)
        assert_equal(test['expected'], decode_toon_file(test['input'], testname, **options), message)
      end
    end

    def decode_toon_file(input, testname, **options)
      Tempfile.create([testname, '.toon']) do |temp|
        temp.write(input)
        temp.rewind
        RbToon.decode_file(temp.path, **options)
      end
    end

    def extract_options(test)
      options = {}

      testname = test['name'].tr(' ', '_')

      if test['options']&.key?('strict')
        options[:strict] = test['options']['strict']
      end
      if test['options']&.key?('indent')
        options[:indent_size] = test['options']['indent']
      end
      if test['options']&.key?('expandPaths')
        options[:path_expansion] = test['options']['expandPaths'] == 'safe'
      end

      [testname, options]
    end
  end
end
