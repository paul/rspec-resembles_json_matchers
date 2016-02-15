module RSpec::JsonMatchers

  class AttributeMatcher
    include RSpec::JsonMatchers::Helpers

    attr_reader :attribute_name, :expected, :document

    def initialize(attribute_name, expected = NullMatcher)
      @attribute_name, @expected = attribute_name, expected
    end

    def description
      sentencize "have attribute #{attribute_name.inspect} #{expected.description}"
    end

    def matches?(document)
      @document = document.with_indifferent_access

      @document.key?(attribute_name) &&
        expected === @document.fetch(attribute_name) { nil }
    end

    def failure_message
      msgs = ["Expected",
              document.fetch(attribute_name, nil).inspect,
              "to",
              expected.description]
      sentencize(*msgs)
    end

    def failure_message_when_negated
      sentencize "Expected attribute #{attribute_name.inspect}",
                 expected.description,
                 "to be absent"
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

    def matcherize(expected)
      if matcher? expected
        expected

      elsif expected.respond_to? :===
        RSpec::Matchers::Builtin::Match.new(expected)

      else
        RSpec::Matchers::Builtin::Eq.new(expected)
      end
    end

    def matcher?(obj)
      obj.respond_to(:matches?) && (obj.respond_to?(:failure_message) ||
                                     obj.respond_to?(:failure_message_for_should))
    end

  end

end
