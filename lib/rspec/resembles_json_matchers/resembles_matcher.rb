require "active_support/core_ext/array/wrap"

module RSpec::ResemblesJsonMatchers

  module Matcherizer
    def matcherize(expected)
      if matcher? expected
        expected

      elsif expected.is_a?(Hash)
        RSpec::ResemblesJsonMatchers::JsonMatcher.new(expected)

      elsif expected.respond_to? :===
        RSpec::Matchers::BuiltIn::Match.new(expected)

      else
        RSpec::Matchers::BuiltIn::Eq.new(expected)
      end
    end

    def matcher?(obj)
      obj.respond_to?(:matches?) && obj.respond_to?(:description)
    end
  end

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
      # Order matters
      @candidates ||= [
        ResemblesArrayMatcher,
        ResemblesHashMatcher,
        ResemblesRouteMatcher,
        ResemblesDateMatcher,
        ResemblesNumericMatcher,
        ResemblesStringMatcher
      ].freeze
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

  class ResemblesArrayMatcher
    include Matcherizer

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
  end

  require "active_support/core_ext/string/indent" # indent
  class ResemblesHashMatcher
    include Matcherizer

    def self.can_match?(hash)
      hash.is_a? Hash
    end

    def initialize(expected)
      @expected = expected
      @failed_matches = {}
    end

    def description
      "resemble #{pretty_expected.indent(6)}"
    end

    def matches?(hash)
      expected_matchers.each do |expected_key, value_matcher|
        attr_matcher = RSpec::ResemblesJsonMatchers::AttributeMatcher.new(expected_key, value_matcher)
        match = attr_matcher.matches?(hash)
        @failed_matches[expected_key] = attr_matcher unless match
      end
      @failed_matches.size == 0
    end

    def expected_matchers
      @expected_matchers ||= {}.tap do |hsh|
        @expected.each do |key, value_matcher|
          hsh[key] = matcherize(value_matcher)
        end
      end
    end

  end

  class ResemblesRouteMatcher
    ROUTE_REGEX = %r{\A/.*:}.freeze
    def self.can_match?(route_string)
      route_string.is_a?(String) &&
        route_string.starts_with?("/") &&
        route_string.include?(":")
    end

    def initialize(expected_route)
      @expected_route = expected_route
    end

    def description
      "resemble route #{@expected_route.inspect}"
    end

    def matches?(actual)
      path = ActionDispatch::Journey::Path::Pattern.from_string(@expected_route)
      actual =~ path.to_regexp
    end
  end

  class ResemblesDateMatcher
    DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\Z/.freeze
    def self.can_match?(date_or_str)
      case date_or_str
      when Date, Time, DateTime
        true
      when DATE_REGEX
        true
      end
    end

    def initialize(expected)
      @expected = expected
    end

    def description
      "resemble date #{@expected.inspect}"
    end

    def matches?(actual)
      self.class.can_match?(actual)
    end
  end

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
  end

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
      self.class.can_match?(actual)
    end
  end


  RSpec.configure { |c| c.include self }
end

