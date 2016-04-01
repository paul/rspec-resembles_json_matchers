
module RSpec::ResemblesJsonMatchers
  class ResemblesStringMatcher
    def self.can_match?(string)
      string.is_a? String
    end

    def initialize(expected)
      @expected = expected
    end

    def description
      "resemble text #{@expected.inspect}"
    end

    # TODO make sure the lengths are kinda the same? Levenschtien distances?
    def matches?(actual)
      self.class.can_match?(actual)
    end

    def expected_formatted
      @expected
    end
  end
end
