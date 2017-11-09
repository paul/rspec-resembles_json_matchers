require_relative "../spec_helper"

RSpec.describe RSpec::ResemblesJsonMatchers::ResemblesAnyOfMatcher do

  subject(:matcher) { RSpec::ResemblesJsonMatchers::ResemblesAnyOfMatcher.new(matcher_candidates) }

  context "when every item in the given array matches one of the matchers" do
    let(:given) { [ 1, 2, "foo" ] }
    let(:matcher_candidates) { [ be_kind_of(Integer), "foo" ] }

    specify { expect(matcher.matches? given).to be_truthy }
  end

  context "when all the items in the given array do not match all of the matchers" do
    let(:given) { [ 1, 2 ] }
    let(:matcher_candidates) { [ be_kind_of(Integer), "foo" ] }

    specify { expect(matcher.matches? given).to be_truthy }
  end

  context "when not every item in the given array matches the matchers" do
    let(:given) { [ 1, 2, "foo" ] }
    let(:matcher_candidates) { [ be_kind_of(Integer) ] }

    specify {
      expect(matcher.matches? given).to_not be_truthy
    }
  end

  context "when given array is empty" do
    let(:given) { [] }
    let(:matcher_candidates) { ["foo"] }

    specify { expect(matcher.matches? given).to_not be_truthy }

    context "and matchers are empty" do
      let(:matcher_candidates) { [] }

      specify { expect(matcher.matches? given).to be_truthy }
    end
  end

  describe "#description" do
    context "when there is only one matcher provded" do
      let(:matcher_candidates) { [ be_kind_of(Integer) ] }

      specify { expect(matcher.description).to eq "have every item be a kind of Integer" }
    end

    context "when multiple matchers are provided" do
      let(:matcher_candidates) { [ be_kind_of(Integer), "foo" ] }

      specify { expect(matcher.description).to eq <<-TXT.strip_heredoc
                  have every item match one of:
                    should be a kind of Integer
                    should resemble text "foo"
        TXT
      }
    end
  end

  describe "#failure_message" do
    let(:given) { [ 1, 2, "foo" ] }
    let(:matcher_candidates) { [ be_kind_of(Integer) ] }

    before { expect(matcher.matches? matcher_candidates).to_not be_truthy }

    subject(:failure_message) { matcher.failure_message }

    xspecify { expect(failure_message).to eq <<-TXT.strip_heredoc
                Expected every item to match on of:
                  should be a kind of Integer
                  should match "foo"
                The item at [2] did not because:
                  foo
      TXT
    }
  end
end
