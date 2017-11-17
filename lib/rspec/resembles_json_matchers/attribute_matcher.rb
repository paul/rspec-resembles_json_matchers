require "active_support/core_ext/hash/indifferent_access"

module RSpec::ResemblesJsonMatchers

  class AttributeMatcher
    include RSpec::ResemblesJsonMatchers::Helpers

    attr_reader :attribute_name, :expected, :document

    def initialize(attribute_name, expected = NullMatcher)
      @attribute_name, @expected = attribute_name, expected
    end

    def description
      sentencize "have attribute #{attribute_name.inspect} #{expected.description}"
    end

    def matches?(document)
      @document = document.with_indifferent_access

      @matched = !missing_attribute? && expected.matches?(actual_value)
    end

    def failure_message
      if missing_attribute?
        %{Expected document to have attribute #{attribute_name.inspect}}
      else
        %{Expected attribute #{attribute_name.inspect} to #{value_matcher.description}, but it was #{actual_value.inspect}}
      end
    end

    def matched?
      @matched
    end

    def value_matcher
      @expected
    end

    def expected_value
      value_matcher.expected
    end

    def actual_value
      document.fetch(attribute_name, nil)
    end

    def missing_attribute?
      !document.key?(attribute_name)
    end

    NullMatcher = Class.new do
      def matches?(*_args)
        true
      end

      def failure_message
        ""
      end
      alias_method :failure_message_for_should, :failure_message

      def description
        "be present"
      end

      def ===(_other)
        true
      end
    end.new

  end
end
