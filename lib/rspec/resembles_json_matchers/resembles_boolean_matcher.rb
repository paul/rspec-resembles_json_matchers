
module RSpec::ResemblesJsonMatchers
  class ResemblesBooleanMatcher
    def self.can_match?(bool)
      bool.is_a?(TrueClass) || bool.is_a?(FalseClass)
    end

    attr_reader :expected

    def initialize(expected)
      @expected = expected
    end

    def description
      "resemble boolean #{@expected.inspect}"
    end

    def matches?(actual)
      actual.is_a?(TrueClass) || actual.is_a?(FalseClass)
    end

    def expected_formatted
      @expected
    end
  end
end
