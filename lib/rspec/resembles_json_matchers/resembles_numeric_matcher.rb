
module RSpec::ResemblesJsonMatchers
  class ResemblesNumericMatcher
    NUMBER_REGEX = /\A\d+\Z/.freeze
    def self.can_match?(number)
      number.is_a?(Numeric) ||
        number =~ NUMBER_REGEX
    end

    def initialize(expected)
      @expected = expected
    end

    def description
      "resemble the number #{@expected.inspect}"
    end

    # TODO Make sure int/float matches? Numbers are within an order of magnitude?
    def matches?(actual)
      @actual = actual
      self.class.can_match?(actual)
    end

    def expected_formatted
      @expected
    end

    def failure_message
      "#{@actual.inspect} does not resemble a number"
    end
  end
end
