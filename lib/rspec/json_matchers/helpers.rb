module RSpec::JsonMatchers
  module Helpers
    require "awesome_print"

    AP_OPTIONS = {
      indent:    -2,
      index:     false,
      sort_keys: false,
      plain:     true
    }

    # Returns a pretty-formatted inspected string
    def pp(obj)
      obj.ai(AP_OPTIONS)
    end

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
