require "active_support/core_ext/hash/keys"     # stringify_keys

require "json"

module RSpec::ResemblesJsonMatchers
  class JsonMatcher
    include RSpec::Matchers::Composable
    include RSpec::ResemblesJsonMatchers::Helpers

    def initialize(expected_json)
      @expected_json = expected_json.stringify_keys
      @failed_matchers = {}
    end

    def matches?(actual_json)
      @actual_json = actual_json
      expected_matchers.each do |expected_key, value_matcher|
        attr_matcher = AttributeMatcher.new(expected_key, value_matcher)
        match = attr_matcher.matches?(@actual_json)
        @failed_matchers[expected_key] = attr_matcher unless match
      end
      @failed_matchers.size == 0
    end

    def description
      # TODO Figure out how to discover the right indent level
      "have json that looks like\n#{expected_formatted.indent(6)}"
    end

    def failure_message
      msgs = [ "Expected:",
                pretty_actual.indent(2),
                "To match:",
                expected_formatted.indent(2),
                "Failures:",
                pretty_errors.indent(2) ]
      msgs.join("\n")
    end

    def pretty_json(obj)
      JSON.pretty_generate(obj)
    end

    def expected_formatted
      pretty_json(@expected_json)
    end

    def pretty_actual
      pretty_json(@actual_json)
    end

    def expected_matchers
      @expected_matchers ||= {}.tap do |hsh|
        @expected_json.each do |k,v|
          hsh[k] = v.respond_to?(:description) ? v : RSpec::Matchers::BuiltIn::Eq.new(v)
        end
      end
    end

    def expected_formatted
      out = "{\n"
      out << expected_matchers.map do |k,v|
        case v
        when RSpec::Matchers::BuiltIn::Eq
          %{"#{k}": #{v.expected_formatted}}.indent(2)
        else
          %{"#{k}": #{v.description}}.indent(2)
        end
      end.join(",\n")
      out << "\n}"
    end

    def pretty_errors
      out = "{\n"
      out << @failed_matchers.map do |k,v|
        %{"#{k}": #{v.failure_message}}.indent(2)
      end.join(",\n")
      out << "\n}"
    end

  end
end
