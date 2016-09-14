module RSpec
  module ResemblesJsonMatchers
    module StringIndent
      def indent!(amount, indent_string = nil, indent_empty_lines = false)
        indent_string = indent_string || self[/^[ \t]/] || ' '
        re = indent_empty_lines ? /^/ : /^(?!$)/
        gsub!(re, indent_string * amount)
      end

      def indent(amount, indent_string = nil, indent_empty_lines = false)
        dup.tap { |me| me.indent!(amount, indent_string, indent_empty_lines) }
      end
    end
  end
end

# String#indent was added in ActiveSupport 4 and appears here in order to support ActiveSupport 3
begin
  require "active_support/core_ext/string/indent" # indent
rescue LoadError
  String.send(:include, RSpec::ResemblesJsonMatchers::StringIndent)
end
