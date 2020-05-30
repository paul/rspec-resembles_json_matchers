# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/object/try"

module RSpec::ResemblesJsonMatchers
  class AttributeMatcher
    include RSpec::ResemblesJsonMatchers::Helpers
    Undefined = Object.new # TODO use Dry::Core::Constants::Undefined

    attr_reader :attribute_name, :expected, :document

    def initialize(attribute_name, expected = NullMatcher.new)
      @attribute_name, @expected = attribute_name, expected
    end

    def description
      sentencize "have attribute #{attribute_name.inspect} #{expected.description}"
    end

    def matches?(document)
      @document = document.try(:with_indifferent_access)

      @matched = document.key?(attribute_name) && expected.matches?(actual_value)
    end

    def failure_message
      %{Expected attribute #{attribute_name.inspect} to #{value_matcher.description}, but it was #{actual_value.inspect}}
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
    end
  end

  class MissingAttributeMatcher < AttributeMatcher
    def matches?(document)
      @document = document.try(:with_indifferent_access)
      false
    end

    def failure_message
      "Document had is missing attribute #{attribute_name.inspect}"
    end

    def description
      "be present"
    end
  end

  class ExtraAttributeMatcher < AttributeMatcher
    def matches?(document)
      @document = document.try(:with_indifferent_access)
      false
    end

    def failure_message
      "Document had unexpected attribute #{attribute_name.inspect}"
    end

    def description
      "not be present"
    end
  end
end
