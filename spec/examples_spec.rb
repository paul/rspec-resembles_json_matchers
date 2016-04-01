require_relative "spec_helper"
require "rspec/resembles_json_matchers"

RSpec.describe "my hash" do
  include RSpec::ResemblesJsonMatchers

  subject(:response_document) do
    {
      author: "Paul",
      gems_published: 42,
      created_at: "2016-01-01T00:00:00Z"
    }
  end

  # Test that the key is present, regardless of value (even nil)
  it { should have_attribute :author }

  # Test the value by using another matcher
  it { should have_attribute :author, eq("Paul") }
  it { should have_attribute :author, match(/Paul/) }
  it { should have_attribute :gems_published, be > 40 }
  it { should have_attribute :created_at, iso8601_timestamp }

  # it { should have_attribute :full_name }
  # it { should have_attribute :author, match(/paul/) }
end

RSpec.describe "my json response document" do
  include RSpec::ResemblesJsonMatchers

  subject(:response_document) do
    {
      author: "Paul",
      gems_published: 42,
      created_at: "2016-01-01T00:00:00Z"
    }
  end

  it { should match_json(
    {
      author: "Paul",
      gems_published: be > 40,
      created_at: iso8601_timestamp
    }
  )}

end
