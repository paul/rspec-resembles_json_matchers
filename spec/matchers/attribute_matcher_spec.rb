require "spec_helper"

RSpec.describe RSpec::ResemblesJsonMatchers::AttributeMatcher do

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

      specify { expect(matcher.matches?(example_hash)).to be_falsey }
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

  describe "#description" do
    context "with just a key provided" do
      let(:matcher) { described_class.new(key) }
      subject(:description) { matcher.description }
      let(:key) { :true }

      specify { expect(description).to eq "have attribute :true be present" }
    end

    context "with key and value matcher provided" do
      let(:matcher) { described_class.new(key, value_matcher) }
      subject(:description) { matcher.description }
      let(:key) { :true }
      let(:value_matcher) { be_true }

      specify { expect(description).to start_with "have attribute :true" }
      specify { expect(description).to end_with value_matcher.description }
    end
  end

  describe "#failure_message" do
    subject(:failure_message) { matcher.failure_message }
    before { matcher.matches? example_hash }

    context "when the document has the attribute, but it doesn't match" do
      let(:value_matcher) { be_true }
      let(:key) { :false }
      let(:matcher) { described_class.new(key, value_matcher) }

      specify { expect(failure_message).to eq "Expected attribute :false to be true, but it was false" }

    end
  end
end
