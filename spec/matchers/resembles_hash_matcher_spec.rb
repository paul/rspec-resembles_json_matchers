require_relative "../spec_helper"

RSpec.describe RSpec::ResemblesJsonMatchers::ResemblesHashMatcher do
  subject(:matcher) { described_class.new(expected) }

  context "when all fields match exactly" do
    let(:given) do
      {
        id: 1,
        type: "Post",
        title: "Hello, world!",
        published_at: Time.now.iso8601
      }
    end

    let(:expected) do
      {
        id: 1,
        type: eq("Post"),
        title: String,
        published_at: "2016-01-01T00:00:00Z"
      }
    end

    specify { expect(matcher.matches? given).to be_truthy }

    describe "#description" do
      subject(:description) { matcher.description }

      specify { expect(description).to eq(<<-TXT.strip_heredoc) }
                  resemble json
                    {
                      "id": 1,
                      "type": eq "Post",
                      "title": String,
                      "published_at": "2016-01-01T00:00:00Z"
                    }
      TXT
    end
  end

  context "when a single field does not match" do
    let(:given) do
      {
        id: 1,
        type: "NotAPost",
        title: "Hello, world!",
        published_at: Time.now.iso8601
      }
    end

    let(:expected) do
      {
        id: 1,
        type: eq("Post"),
        title: String,
        published_at: "2016-01-01T00:00:00Z"
      }
    end

    specify { expect(matcher.matches? given).to_not be_truthy }

    describe "#failure_message" do
      before { expect(matcher.matches?(given)).to_not be_truthy }
      subject(:failure_message) { matcher.failure_message }

      specify { expect(failure_message).to eq(<<-TXT.strip_heredoc) }
        failed because
          attribute "type":
            expected: "Post"
                 got: "NotAPost"
      TXT
    end
  end

  context "when multiple fields do not match" do
    let(:given) do
      {
        id: "one",
        type: "NotAPost",
        title: 42.0,
        published_at: "yesterday"
      }
    end

    let(:expected) do
      {
        id: 1,
        type: eq("Post"),
        title: String,
        published_at: "2016-01-01T00:00:00Z"
      }
    end

    specify { expect(matcher.matches? given).to_not be_truthy }

    describe "#failure_message" do
      before { expect(matcher.matches?(given)).to_not be_truthy }
      subject(:failure_message) { matcher.failure_message }

      specify { expect(failure_message).to eq(<<-TXT.strip_heredoc) }
        failed because
          attribute "id":
            "one" does not resemble a number
          attribute "type":
            expected: "Post"
                 got: "NotAPost"
          attribute "title":
            42.0 does not resemble a String
          attribute "published_at":
            "yesterday" does not resemble a Date or Timestamp
      TXT
    end

  end

  context "when the given has extra fields" do
    let(:given) do
      {
        id: 1,
        type: "Post",
        title: "Hello, world!",
        published_at: Time.now.iso8601,
        deleted_at:   Time.now.iso8601
      }
    end

    let(:expected) do
      {
        id: 1,
        type: eq("Post"),
        title: String,
        published_at: "2016-01-01T00:00:00Z"
      }
    end

    specify { expect(matcher.matches? given).to_not be_truthy }

    describe "#failure_message" do
      before { expect(matcher.matches?(given)).to_not be_truthy }
      subject(:failure_message) { matcher.failure_message }

      specify { expect(failure_message).to eq(<<-TXT.strip_heredoc) }
        failed because
          attribute "deleted_at":
            is present, but no matcher provided to match it
      TXT
    end
  end

  context "when the matcher has extra fields" do
    let(:given) do
      {
        id: 1,
        type: "Post",
        title: "Hello, world!",
        published_at: Time.now.iso8601
      }
    end

    let(:expected) do
      {
        id: 1,
        type: eq("Post"),
        title: String,
        published_at: "2016-01-01T00:00:00Z",
        deleted_at: "2016-01-01T00:00:00Z"
      }
    end

    specify { expect(matcher.matches? given).to_not be_truthy }

    describe "#failure_message" do
      before { expect(matcher.matches?(given)).to_not be_truthy }
      subject(:failure_message) { matcher.failure_message }

      specify { expect(failure_message).to eq(<<-TXT.strip_heredoc) }
        failed because
          attribute "deleted_at":
            has a matcher defined, but that attribute was not provided
      TXT
    end
  end
end

