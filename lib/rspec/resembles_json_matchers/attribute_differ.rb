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

    def render_JsonMatcher(matcher, prefix: "", starts_on_newline: false, **opts)
      @buffer.print prefix if starts_on_newline
      @buffer.print NORMAL_COLOR unless prefix.include?("-")
      @buffer.puts "{"
      matcher.expected_matchers.each do |key, attr_matcher|
        last = (matcher.expected_matchers.keys.last == key)
        render(attr_matcher, prefix: prefix, last: last, **opts)
      end
      if matcher.actual.nil?
        @buffer.print REMOVED_COLOR
        if prefix.include? "-"
          @buffer.print prefix + "}"
        else
          @buffer.print prefix + "- }"
        end
      else
        @buffer.print NORMAL_COLOR unless prefix.include?("-")
        @buffer.print prefix + "}"
      end
    end

    def render_AttributeMatcher(matcher, prefix: "", last: false)
      if matcher.matched?
        @buffer.print NORMAL_COLOR
        @buffer.print prefix + "  " + "#{matcher.attribute_name.to_json}: "
        render(matcher.value_matcher, prefix: prefix + "  ")
        @buffer.print(",") unless last
        @buffer.puts
      else
        if nested_matcher?(matcher.value_matcher)
          @buffer.print NORMAL_COLOR
          @buffer.print prefix + "  " + "#{matcher.attribute_name.to_json}: "
          render(matcher.value_matcher, prefix: prefix + "  ")
          @buffer.print(",") unless last
          @buffer.puts
        else
          @buffer.print REMOVED_COLOR
          @buffer.print prefix
          if prefix.include? "-"
            @buffer.print "  "
          else
            @buffer.print "- "
          end
          @buffer.print "#{matcher.attribute_name.to_json}: "
          render(matcher.value_matcher, prefix: prefix + "  ")
          @buffer.print NORMAL_COLOR
          @buffer.print(",") unless last
          @buffer.puts
          @buffer.print ADDED_COLOR
          @buffer.print prefix + "+ #{matcher.attribute_name.to_json}: "
          render(matcher.actual_value, prefix: prefix + "  ")
          @buffer.print NORMAL_COLOR
          @buffer.print(",") unless last
          @buffer.puts
        end
      end
    end

    def render_MissingAttributeMatcher(matcher, prefix: "", last: false)
      prefix = prefix + (prefix.include?("-") ? "  " : "- ")
      @buffer.print REMOVED_COLOR
      @buffer.print prefix + "#{matcher.attribute_name.to_json}: "
      render(matcher.value_matcher, prefix: prefix)
      @buffer.print(",") unless last
      @buffer.puts
    end

    def render_ExtraAttributeMatcher(matcher, prefix: "", last: false)
      prefix = prefix + "+ "
      @buffer.print ADDED_COLOR
      @buffer.print prefix + matcher.attribute_name.to_json + ": "
      render(matcher.actual_value, prefix: prefix)
      @buffer.print "," unless last
      @buffer.puts
    end

    def render_ResemblesAnyOfMatcher(matcher, prefix: "", **opts)
      @buffer.puts "["
      if matcher.actual.nil? || matcher.actual.empty?
        example_matcher = matcher.expected.first
        render example_matcher, prefix: prefix + "  ", starts_on_newline: true
        @buffer.puts
      else
        matcher.attempted_matchers.each do |attempted_matcher|
          last = (matcher.attempted_matchers.last == attempted_matcher)
          render attempted_matcher, prefix: prefix + "  ", starts_on_newline: true
          @buffer.print(",") unless last
          @buffer.puts
        end
      end
      @buffer.print prefix + "]"
    end

    def render_ResemblesBooleanMatcher(matcher, **opts)
      @buffer.print matcher.expected.to_json
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

    def render_ResemblesNilMatcher(matcher, **opts)
      @buffer.print "null"
    end

    def render_ResemblesRouteMatcher(matcher, **opts)
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

    def nested_matcher?(matcher)
      matcher.is_a?(JsonMatcher) || matcher.is_a?(ResemblesAnyOfMatcher)
    end

    NORMAL_COLOR  = "\e[0m".freeze
    REMOVED_COLOR = "\e[31m".freeze # Red
    ADDED_COLOR   = "\e[32m".freeze # Green
    NEUTRAL_COLOR = "\e[34m".freeze # Blue

  end
end

