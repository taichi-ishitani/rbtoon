# frozen_string_literal: true

module Toonrb
  class Parser < GeneratedParser
    def initialize(scanner)
      @scanner = scanner
      @root = Nodes::Root.new
      super()
    end

    def parse
      do_parse
      @root
    end

    private

    def next_token
      @scanner.next_token
    end
  end
end
