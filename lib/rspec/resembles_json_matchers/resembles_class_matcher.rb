
module RSpec::ResemblesJsonMatchers
  class ResemblesClassMatcher
    def self.can_match?(klass)
      klass.is_a? Class
    end

    def initialize(expected)
      @expected = expected
    end

    def description
      "resemble #{@expected}"
    end

    def matches?(actual)
      @actual = actual
      actual.kind_of? @expected
    end

    def expected_formatted
      @expected
    end

    def failure_message
      "#{@actual.inspect} does not resemble a #{@expected}"
    end
  end
end
