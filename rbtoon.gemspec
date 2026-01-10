# frozen_string_literal: true

require_relative 'lib/rbtoon/version'

Gem::Specification.new do |spec|
  spec.name = 'rbtoon'
  spec.version = RbToon::VERSION
  spec.authors = ['Taichi Ishitani']
  spec.email = ['taichi730@gmail.com']

  spec.summary = 'Toon parser for Ruby'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/taichi-ishitani/rbtoon'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata = {
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'changelog_uri' => "#{spec.homepage}/releases",
    'documentation_uri' => 'https://taichi-ishitani.github.io/rbtoon/',
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => spec.homepage
  }

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z lib *.md *.txt`.split("\x0")
  end

  spec.require_paths = ['lib']
end
