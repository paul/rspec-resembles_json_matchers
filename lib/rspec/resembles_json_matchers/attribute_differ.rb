require "active_support/inflector"

module RSpec::ResemblesJsonMatchers
  class AttributeDiffer
    def initialize(matcher)
      @matcher = matcher
    end

    def to_s
      @buffer = StringIO.new
      @buffer.puts NEUTRAL_COLOR + "Diff:"
      render(@matcher)
      @buffer.string
    end

    private

    def render(matcher, **opts)
      class_name = ActiveSupport::Inflector.demodulize(matcher.class.to_s)
      method_name = :"render_#{class_name}"
      send method_name, matcher, **opts
    end

    def render_JsonMatcher(matcher, depth: 0, starts_on_newline: false, **opts)
      @buffer.print indent("", depth) if starts_on_newline
      @buffer.print NORMAL_COLOR
      @buffer.puts "{"
      matcher.expected_matchers.each do |key, attr_matcher|
        last = (matcher.expected_matchers.keys.last == key)
        render(attr_matcher, depth: depth + 1, last: last, **opts)
      end
      @buffer.print NORMAL_COLOR
      @buffer.print indent("}", depth)
    end

    def render_AttributeMatcher(matcher, depth: 0, last: false)
      if matcher.matched? || nested_matcher?(matcher.value_matcher)
        @buffer.print NORMAL_COLOR
        @buffer.print indent("#{matcher.attribute_name.to_json}: ", depth)
        render(matcher.value_matcher, depth: depth)
        @buffer.print(",") unless last
        @buffer.puts
      else
        @buffer.print REMOVED_COLOR
        @buffer.print indent("- #{matcher.attribute_name.to_json}: ", depth - 1)
        render(matcher.value_matcher, depth: depth)
        @buffer.print NORMAL_COLOR
        @buffer.print(",") unless last
        @buffer.puts
        unless matcher.missing_attribute?
          @buffer.print ADDED_COLOR
          @buffer.print indent("+ #{matcher.attribute_name.to_json}: ", depth - 1)
          render(matcher.actual_value, depth: depth)
          @buffer.print NORMAL_COLOR
          @buffer.print(",") unless last
          @buffer.puts
        end
      end
    end

    def render_ResemblesAnyOfMatcher(matcher, depth: 0, **opts)
      @buffer.puts "["
      matcher.attempted_matchers.each do |attempted_matcher|
        last = (matcher.attempted_matchers.last == attempted_matcher)
        render attempted_matcher, depth: depth + 1, starts_on_newline: true
        @buffer.print(",") unless last
        @buffer.puts
      end
      @buffer.print indent("]", depth)
    end

    def render_ResemblesStringMatcher(matcher, **opts)
      @buffer.print matcher.expected.to_json
    end

    def render_ResemblesDateMatcher(matcher, **opts)
      @buffer.print matcher.expected.to_json
    end

    def render_ResemblesNumericMatcher(matcher, **opts)
      @buffer.print matcher.expected.to_json
    end

    def render_ResemblesClassMatcher(matcher, **opts)
      @buffer.print matcher.expected.inspect
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s.start_with?("render_")
        raise NoMethodError, method_name if method_name.to_s.end_with?("Matcher")
        @buffer.print RSpec::Support::ObjectFormatter.format(args.first)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with?("render_")
    end

    def indent(text, depth)
      "  " * depth + text
    end

    def nested_matcher?(matcher)
      matcher.is_a?(JsonMatcher) || matcher.is_a?(ResemblesAnyOfMatcher)
    end

    NORMAL_COLOR  = "\e[0m".freeze
    REMOVED_COLOR = "\e[31m".freeze # Red
    ADDED_COLOR   = "\e[32m".freeze # Green
    NEUTRAL_COLOR = "\e[34m".freeze # Blue

  end
end

