require "active_support/core_ext/array/wrap"

module RSpec::ResemblesJsonMatchers

  def resembles(expected)
    ResemblesMatcher.new(expected)
  end

  class ResemblesMatcher
    def initialize(expected, inclusion: nil)
      @expected = expected

      candidate_class = if inclusion == :any
                          ResemblesAnyOfMatcher
                        elsif inclusion == :all
                          ResemblesAllOfMatcher
                        else
                          candidates.detect { |candidate| candidate.can_match?(@expected) }
                        end

      if candidate_class
        @candidate = candidate_class.new(expected)
      else
        fail "Could not find an acceptable resembles matcher for #{@expected.inspect}"
      end
    end

    def description
      @candidate.description
    end

    def matches?(actual)
      @actual = actual
      if @candidate
        @candidate.matches?(actual)
      end
    end

    def failure_message(negated: false)
      "expected #{@actual.inspect} to #{negated ? "not " : ""}#{description}"
    end

    def negative_failure_message
      failure_message(negated: true)
    end

    def candidates
    end
  end

  class ResemblesAnyOfMatcher
    include Matcherizer

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
        "have every item match one of:\n#{pretty_expected}"
      end
    end

    def failure_message
      sentencize ["Expected every item to match one of:\n",
                  pretty_expected,
                  "The item at",
                  failed_item_indexes,
                  "did not because:\n",
                  failure_messages]

    end

    def expected_matchers
      @expected.map { |e| matcherize(e) }
    end

    def pretty_expected
      "".tap do |out|
        out << expected_matchers.map do |v|
          case v
          when RSpec::Matchers::BuiltIn::Eq
            "should #{v.expected_formatted}".indent(2)
          else
            "should #{v.description}".indent(2)
          end
        end.join("\n")
      end << "\n"
    end

  end

  class ResemblesAllOfMatcher

  end



  RSpec.configure { |c| c.include self }
end

