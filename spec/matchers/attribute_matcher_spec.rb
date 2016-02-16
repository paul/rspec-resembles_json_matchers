require_relative "../spec_helper"

RSpec.describe RSpec::JsonApiMatchers::AttributeMatcher do

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
    context "when just a key was provided" do
      let(:matcher) { described_class.new(key) }
      subject(:failure_message) { matcher.failure_message }
      let(:key) { :does_not_exist }

      before { matcher.matches? example_hash }

      specify { expect(failure_message).to eq "Expected attribute :does_not_exist to be present" }
    end

    context "when a key and value matcher were provided" do
      let(:matcher) { described_class.new(key, value_matcher) }
      subject(:failure_message) { matcher.failure_message }
      let(:key) { :does_not_exist }
      let(:value_matcher) { be_true }

      before { matcher.matches? example_hash }

      specify { expect(failure_message).to start_with "Expected value of attribute :does_not_exist" }
      specify { expect(failure_message).to include value_matcher.description }
      specify { expect(failure_message).to end_with "but it was nil" }
    end
  end
end
