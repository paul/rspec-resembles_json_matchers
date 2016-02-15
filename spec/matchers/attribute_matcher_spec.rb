require_relative "../spec_helper"

RSpec.describe RSpec::JsonMatchers::AttributeMatcher do

  let(:example_hash) do
    {
      nil: nil,
      true: true,
      false: false,
      string: "string",
      number: 42,
      hash: {a: "b"},
      array: ["a", "b"],
      "string_key": "string_key",
      symbol_key: :symbol_key
    }
  end

  describe "matching with just a key provided" do
    subject(:matcher) { described_class.new(key) }

    context "with a key that exists" do
      let(:key) { :string }

      specify { expect(matcher.matches?(example_hash)).to be_truthy }

      context "even when the value is nil" do
        let(:key) { :nil }

        specify { expect(matcher.matches?(example_hash)).to be_truthy }
      end

      context "even when the value is false" do
        let(:key) { :false }

        specify { expect(matcher.matches?(example_hash)).to be_truthy }
      end
    end

    context "with a key that does not exist" do
      let(:key) { :does_not_exist }

      specify { expect(matcher.matches?(example_hash)).to be_falsy }
    end
  end

  describe "matching both a key and value matcher" do
    subject(:matcher) { described_class.new(key, value_matcher) }

    context "when both the key and value_matcher match" do
      let(:key) { :true }
      let(:value_matcher) { be true }

      specify { expect(matcher.matches?(example_hash)).to be_truthy }

      context "even when the value to match is nil" do
        let(:key) { :nil }
        let(:value_matcher) { be_nil }

        specify { expect(matcher.matches?(example_hash)).to be_truthy }
      end
    end

    context "when the value matcher fails" do
      let(:key) { :true }
      let(:value_matcher) { be false }

      specify { expect(matcher.matches?(example_hash)).to be_falsy }
    end

    context "when the key does not exist" do
      let(:key) { :does_not_exist }
      let(:value_matcher) { be_truthy }

      specify { expect(matcher.matches?(example_hash)).to be_falsy }
    end
  end
end
