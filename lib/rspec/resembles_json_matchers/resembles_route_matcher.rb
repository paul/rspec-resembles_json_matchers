
module RSpec::ResemblesJsonMatchers
  class ResemblesRouteMatcher
    ROUTE_REGEX = %r{\A/.*:}.freeze
    def self.can_match?(route_string)
      route_string.is_a?(String) &&
        route_string.start_with?("/") &&
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
end
