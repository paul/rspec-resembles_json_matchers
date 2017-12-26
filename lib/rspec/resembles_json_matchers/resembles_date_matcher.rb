require "time"

module RSpec::ResemblesJsonMatchers
  class ResemblesDateMatcher
    DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\Z/.freeze
    ISO8601_REGEX = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\Z/.freeze
    def self.can_match?(date_or_str)
      case date_or_str
      when Date, Time, DateTime
        true
      when DATE_REGEX, ISO8601_REGEX
        true
      when String
        begin
          Time.iso8601(date_or_str)
          true
        rescue ArgumentError
          false
        end
      end
    end

    attr_reader :expected

    def initialize(expected)
      @expected = expected
      # @expected = expected.is_a?(String) ? Time.parse(expected) : expected
    end

    def description
      "resemble date #{@expected.inspect}"
    end

    def matches?(actual)
      @actual = actual
      self.class.can_match?(actual)
    end

    def failure_message
      "#{@actual.inspect} does not resemble a Date or Timestamp"
    end
  end
end
