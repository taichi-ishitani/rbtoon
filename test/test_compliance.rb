# frozen_string_literal: true

require_relative 'test_helper'

module Toonrb
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
      options = extract_options(test)
      message = "test '#{test['name']}' is failed"
      if test['shouldError']
        assert_raises(ParseError, message) do
          decode_toon(test['input'], **options)
        end
      elsif test['expected'].nil?
        assert_nil(decode_toon(test['input'], **options), message)
      else
        assert_equal(test['expected'], decode_toon(test['input'], **options), message)
      end
    end

    def extract_options(test)
      options = {}

      options[:filename] = test['name']

      if test['options']&.key?('strict')
        options[:strict] = test['options']['strict']
      end
      if test['options']&.key?('indent')
        options[:indent_size] = test['options']['indent']
      end
      if test['options']&.key?('expandPaths')
        options[:path_expansion] = test['options']['expandPaths'] == 'safe'
      end

      options
    end
  end
end
