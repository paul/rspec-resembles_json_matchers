require "active_support/core_ext/array/wrap"

module RSpec::ResemblesJsonMatchers
  class ResemblesAnyOfMatcher
    include Helpers

    def self.can_match?(array)
      array.is_a? Array
    end

    attr_reader :expected, :actual

    def initialize(expected)
      @expected = expected.map { |e| matcherize(e) }
    end

    def matches?(actual)
      @actual = Array.wrap(actual)
      if actual.empty?
        expected_matchers.empty?
      else
        actual.all? do |a|
          expected_matchers.any? { |m| attempted_matchers << m; m.matches? a }
        end
      end
    end

    def description
      if @expected.size == 1
        "have every item #{expected_matchers.first.description}"
      else
        "have every item match one of:\n#{expected_formatted}"
      end
    end

    def failure_message

    end

    def expected_matchers
      @expected
    end

    def attempted_matchers
      @attempted_matchers ||= []
    end

    def expected_formatted
      "".tap do |out|
        out << expected_matchers.map do |v|
          case v
          when RSpec::Matchers::BuiltIn::Eq
            "should #{v.description}".indent(2)
          else
            "should #{v.description}".indent(2)
          end
        end.join("\n")
      end << "\n"
    end
  end
end
