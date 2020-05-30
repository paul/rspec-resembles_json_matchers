# frozen_string_literal: true

module RSpec::ResemblesJsonMatchers
  class ResemblesNilMatcher
    def self.can_match?(nillish)
      nillish.nil?
    end

    attr_reader :expected

    def initialize(expected)
      @expected = expected
    end

    def description
      "resemble boolean #{@expected.inspect}"
    end

    def matches?(actual)
      actual.nil?
    end

    def expected_formatted
      @expected
    end
  end
end
