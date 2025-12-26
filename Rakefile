# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create

unless ENV.key?('CI')
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)

  require 'bump/tasks'

  desc 'generate Toon parser'
  file 'lib/toonrb/generated_parser.rb' => 'toon.y' do
    sh 'bundle exec racc toon.y -v -F -t -o lib/toonrb/generated_parser.rb'
  end

  task test: ['lib/toonrb/generated_parser.rb']
end

task default: :test
