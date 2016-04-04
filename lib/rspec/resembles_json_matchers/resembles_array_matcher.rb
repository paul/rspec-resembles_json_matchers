
module RSpec::ResemblesJsonMatchers
  class ResemblesArrayMatcher
    include Helpers

    def self.can_match?(array)
      array.is_a? Array
    end

    def initialize(expected)
      @expected = expected
    end

    def description
      "resemble #{@expected.inspect}"
    end

    def matches?(actual)
      actual.is_a?(Array) && actual.all? do |a|
        expected_matchers.any? do |e|
          e.matches? a
        end
      end
    end

    def expected_matchers
      @expected.map { |e| matcherize(e) }
    end

    def failure_message
    end
  end


end
