require "active_support/core_ext/array/wrap"

module RSpec::ResemblesJsonMatchers
  class ResemblesAnyOfMatcher
    include Helpers

    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      Array.wrap(actual).flatten.all? do |a|
        expected_matchers.any? { |m| m.matches? a }
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
      sentencize ["Expected every item to match one of:\n",
                  expected_formatted,
                  "The item at",
                  failed_item_indexes,
                  "did not because:\n",
                  failure_messages]

    end

    def expected_matchers
      @expected.map { |e| matcherize(e) }
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
