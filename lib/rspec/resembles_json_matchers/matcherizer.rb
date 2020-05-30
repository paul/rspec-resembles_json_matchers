# frozen_string_literal: true

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
end
