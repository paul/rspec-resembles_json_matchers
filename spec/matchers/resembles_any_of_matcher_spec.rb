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

    specify { expect(matcher.matches? given).to_not be_truthy }
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
end
