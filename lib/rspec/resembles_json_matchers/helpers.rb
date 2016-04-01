require "json"

module RSpec::ResemblesJsonMatchers
  module Helpers
    # Returns string composed of the specified clauses with proper
    # spacing between them. Empty and nil clauses are ignored.
    def sentencize(*clauses)
      clauses
        .flatten
        .compact
        .reject(&:empty?)
        .map(&:strip)
        .join(" ")
    end

    def matcherize(expected)
      if is_matcher? expected
        expected
      else
        RSpec::ResemblesJsonMatchers.resembles_matcher_for(expected).new(expected)
      end
    end

    def is_matcher?(obj)
      obj.respond_to?(:matches?) && obj.respond_to?(:description)
    end

  end
end
