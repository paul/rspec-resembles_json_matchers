# frozen_string_literal: true

module RSpec::ResemblesJsonMatchers
  class ResemblesRouteMatcher
    ROUTE_REGEX = %r{\A/.*:}.freeze
    def self.can_match?(route_string)
      defined?(ActionDispatch) &&
        route_string.is_a?(String) &&
        route_string.start_with?("/") &&
        route_string.include?(":")
    end

    attr_reader :expected

    def initialize(expected_route)
      @expected = expected_route
    end

    def description
      "resemble route #{@expected.inspect}"
    end

    def matches?(actual)
      path = ActionDispatch::Journey::Path::Pattern.from_string(@expected)
      actual =~ path.to_regexp
    end
  end
end
