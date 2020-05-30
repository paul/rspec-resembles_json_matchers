# frozen_string_literal: true

require "spec_helper"

require "time"
require "active_support/core_ext/hash" # Hash#except

RSpec.describe RSpec::ResemblesJsonMatchers::JsonMatcher do
  subject(:matcher) { described_class.new(expected) }

  let(:result) { matcher.matches?(document) }
  let(:failure_message) { result; strip_colors(matcher.failure_message) }

  let(:document) do
    {
      id:         1,
      name:       "Paul",
      website:    "http://sadauskas.com",
      created_at: "2017-01-01T00:00:00Z"
    }
  end

  let(:expected) do
    {
      id:         1,
      name:       "Paul",
      website:    "http://sadauskas.com",
      created_at: "2017-01-01T00:00:00Z"
    }
  end

  context "when expected is a regular json document" do
    it "should match the document" do
      expect(result).to be_truthy
    end

    it "should include the document in the description" do
      expect(matcher.description.strip).to eq(<<~TXT.strip)
        have json that looks like
          {
            "id": 1,
            "name": "Paul",
            "website": "http://sadauskas.com",
            "created_at": "2017-01-01T00:00:00Z"
          }
      TXT
    end

    context "when one of the matchers fails" do
      let(:document) { super().merge(id: "some string") }

      it "should not match the document" do
        expect(result).to be_falsey
      end

      it "should have a failure message with a diff containing the mismatch field" do
        matcher.matches?(document)
        expect(strip_colors(failure_message)).to eq(<<~TXT.strip)
          Diff:
          {
          - "id": 1,
          + "id": "some string",
            "name": "Paul",
            "website": "http://sadauskas.com",
            "created_at": "2017-01-01T00:00:00Z"
          }
        TXT
      end
    end

    context "when the document is missing a field" do
      let(:document) { super().except(:website) }

      it "should not match the document" do
        expect(result).to be_falsey
      end

      it "should have a failure message with a diff containing the mismatch field" do
        expect(strip_colors(failure_message)).to eq(<<~TXT.strip)
          Diff:
          {
            "id": 1,
            "name": "Paul",
          - "website": "http://sadauskas.com",
            "created_at": "2017-01-01T00:00:00Z"
          }
        TXT
      end
    end

    context "when the document has an extra field" do
      let(:document) { super().merge(email: "paul@sadauskas.com") }

      it "should not match the document" do
        expect(result).to be_falsey
      end

      it "should have a failure message with a diff containing the mismatch field" do
        expect(strip_colors(failure_message)).to eq(<<~TXT.strip)
          Diff:
          {
            "id": 1,
            "name": "Paul",
            "website": "http://sadauskas.com",
            "created_at": "2017-01-01T00:00:00Z",
          + "email": "paul@sadauskas.com"
          }
        TXT
      end
    end

    context "nested documents" do
      let(:document) do
        {
          title:  "hello",
          author: {
            name: 42
          }
        }
      end

      let(:expected) do
        {
          title:  "hello",
          author: {
            name: "Paul"
          }
        }
      end

      it "should not match the document" do
        expect(result).to be_falsey
      end

      it "should have a failure message with a diff containing the mismatch field" do
        expect(strip_colors(failure_message)).to eq(<<~TXT.strip)
          Diff:
          {
            "title": "hello",
            "author": {
            - "name": "Paul"
            + "name": 42
            }
          }
        TXT
      end

      context "when nested document is missing entirely" do
        let(:document) do
          {
            title: "hello"
          }
        end

        it "should not match the document" do
          expect(result).to be_falsey
        end

        it "should have a failure message with a diff containing the missing object" do
          expect(strip_colors(failure_message)).to eq(<<~TXT.strip)
            Diff:
            {
              "title": "hello",
            - "author": {
            -   "name": "Paul"
            - }
            }
          TXT
        end
      end
    end

    context "nested array of documents" do
      let(:document) do
        {
          "@context": "/_contexts/Collection.jsonld",
          "@id":      "/users",
          "@type":    "UserCollection",
          "member":   [
            {
              "@context":   "/_contexts/Collection.jsonld",
              "@id":        "/users",
              "@type":      "UserCollection",
              "name":       42,
              "created_at": "2017-01-01T00:00:00Z"
            }
          ]
        }
      end

      let(:expected) do
        {
          "@context": "/_contexts/Collection.jsonld",
          "@id":      "/users",
          "@type":    "UserCollection",
          "member":   [
            {
              "@context":   "/_contexts/Collection.jsonld",
              "@id":        "/users",
              "@type":      "UserCollection",
              "name":       "Paul",
              "created_at": "2017-01-01T00:00:00Z"
            }
          ]
        }
      end

      it "should not match the document" do
        expect(result).to be_falsey
      end

      it "should have a failure message with a diff containing the mismatch field" do
        expect(strip_colors(failure_message)).to eq(<<~TXT.strip)
          Diff:
          {
            "@context": "/_contexts/Collection.jsonld",
            "@id": "/users",
            "@type": "UserCollection",
            "member": [
              {
                "@context": "/_contexts/Collection.jsonld",
                "@id": "/users",
                "@type": "UserCollection",
              - "name": "Paul",
              + "name": 42,
                "created_at": "2017-01-01T00:00:00Z"
              }
            ]
          }
        TXT
      end
    end
  end

  context "when expected has matchers in it" do
    let(:expected) do
      {
        id:         Integer,
        name:       match(/Paul/),
        website:    eq("http://example.com"),
        created_at: Time.parse("2018-01-01T00:00:00Z")
      }
    end

    it "should match the document" do
      expect(result).to be_falsey
    end

    it "should have a pretty description" do
      expect(matcher.description.strip).to eq(<<~TXT.strip)
        have json that looks like
          {
            "id": Integer,
            "name": /Paul/,
            "website": "http://example.com",
            "created_at": 2018-01-01 00:00:00.000000000 +0000
          }
      TXT
    end

    it "should print a diff of the failures" do
      matcher.matches?(document)
      expect(strip_colors(failure_message)).to eq(<<~TXT.strip)
        Diff:
        {
          "id": Integer,
          "name": match /Paul/,
        - "website": eq "http://example.com",
        + "website": "http://sadauskas.com",
          "created_at": "2018-01-01 00:00:00 UTC"
        }
      TXT
    end
  end

  def strip_colors(text)
    text.gsub(/\e\[\d+m/, "").strip
  end
end
