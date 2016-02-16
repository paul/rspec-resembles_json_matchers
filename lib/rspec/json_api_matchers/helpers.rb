module RSpec::JsonApiMatchers
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

  end
end
