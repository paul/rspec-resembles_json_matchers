require_relative "spec_helper"
require "rspec/resembles_json_matchers"

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
