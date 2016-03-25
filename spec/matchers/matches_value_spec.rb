require_relative "../spec_helper"

RSpec.describe RSpec::ResemblesJsonMatchers::ResemblesMatcher do

  subject(:matcher) { described_class.new(expected) }
  let(:description) { matcher.description }
  let(:failure_message) { matcher.failure_message }

  context "when matching a simple value" do
    let(:expected) { 1 }

    context "when the value matches" do
      specify { expect(matcher.matches? 1).to be_truthy }

      describe "#description" do
        specify { expect(description).to eq(%{resemble the number 1}) }
      end
    end

    context "when the value does not match" do
      specify { expect(matcher.matches? "foo").to_not be_truthy }

      describe "#failure_message" do
        before { matcher.matches? "foo" }
        specify { expect(failure_message).to eq(%{expected "foo" to resemble the number 1}) }
      end
    end

    context "when negated" do
      describe "#failure_message" do
        before { matcher.matches? 2 }
        specify do
          expect(matcher.negative_failure_message).to eq(%{expected 2 to not resemble the number 1})
        end
      end
    end
  end

  context "when matching an array" do
    context "of simple values" do
      let(:expected) { [1, 2, 3, 4] }

      context "when all the values match" do
        specify { expect(matcher.matches?([5, 6, 7, 8])).to be_truthy }

        describe "#description" do
          specify { expect(description).to eq(%{resemble [1, 2, 3, 4]}) }
        end

        describe "#failure_message" do
          before { matcher.matches? [1, 2, 3, 4] }
          specify { expect(failure_message).to eq(%{expected "foo" to resemble the number 1}) }
        end
      end

    end
  end

  specify { expect([1, 2, 3, 4]).to include(1, 5) }

end

