module RSpec::ResemblesJsonMatchers
  class ResemblesHashMatcher
    include Helpers

    def self.can_match?(hash)
      hash.is_a? Hash
    end

    attr_reader :expected

    def initialize(expected)
      @expected = expected
      @failed_matches = {}
      @matched_keys = []
      @matched_matchers = []
    end

    def matches?(actual)
      @actual = actual
      expected_matchers.each do |expected_key, value_matcher|
        @matched_keys << expected_key

        attr_matcher = RSpec::ResemblesJsonMatchers::AttributeMatcher.new(expected_key, value_matcher)
        match = attr_matcher.matches?(actual)

        if match
          @matched_matchers << value_matcher
        else
          @failed_matches[expected_key] = value_matcher unless match
        end
      end

      actual.keys.each { |k| unmatched_matchers.delete(k) }

      !failed_matches.any? and
        !unmatched_keys.any? and
        !unmatched_matchers.any?
    end

    def description
      "resemble json\n" + expected_formatted.indent(2)
    end

    def failure_message
      "failed because\n" +
        pretty_failed_matches.indent(2) +
        pretty_unmatched_keys.indent(2) +
        pretty_unmatched_matchers.indent(2) +
        "\n"
    end

    protected

    def expected_matchers
      @expected_matchers ||= {}.tap do |hsh|
        expected.each do |key, value_matcher|
          hsh[key] = matcherize(value_matcher)
        end
      end
    end

    def failed_matches
      @failed_matches
    end

    def unmatched_keys
      @actual.keys - @matched_keys
    end

    def unmatched_matchers
      @unmatched_matchers ||= expected_matchers.dup
    end

    def expected_formatted
      out = "{\n"
      out << expected_matchers.map do |k,v|
        %{  "%s": %s} % [k, v.expected_formatted]
      end.join(",\n")
      out << "\n}\n"
    end

    def pretty_failed_matches
      failed_matches.map do |k,matcher|
        next unless @actual.key?(k) # Covered by the unmatched matchers messages
        matcher_failure_message =
          matcher.failure_message
                 .gsub("(compared using ==)", "") # From the equality matcher, ugly in this context
                 .strip
                 .indent(2)

        "attribute #{k.to_s.inspect}:\n#{matcher_failure_message}"
      end.join("\n")
    end

    def pretty_unmatched_keys
      unmatched_keys.map do |key|
        "attribute #{key.to_s.inspect}:\n  is present, but no matcher provided to match it"
      end.join("\n")
    end

    def pretty_unmatched_matchers
      unmatched_matchers.map do |key, matcher|
        "attribute #{key.to_s.inspect}:\n  has a matcher defined, but that attribute was not provided"
      end.join("\n")
    end

  end
end
