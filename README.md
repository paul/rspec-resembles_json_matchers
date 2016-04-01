# RSpec::ResemblesJsonMatchers

[![Gem Version](https://badge.fury.io/rb/rspec-json_api_matchers.svg)](https://badge.fury.io/rb/rspec-json_api_matchers)[![Build Status](https://travis-ci.org/paul/rspec-json_api_matchers.svg?branch=master)](https://travis-ci.org/paul/rspec-json_api_matchers)

This gem provides a set of matchers that make testing JSON documents (actually
the hashes parsed from them) simpler and more elegant.

It provides two primary matchers, `have_attribute` and `resembles`/`resembles_json`.

## `#have_attribute`

Use this matcher when you want to examine a single attribute, and optionally
match against its value.

### Example Usage

```ruby
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
end
```

It will also provide nice descriptions in the rspec doc format, and useful
failure messages:

```
my hash
  should have attribute :author be present
  should have attribute :author eq "Paul"
  should have attribute :author match /Paul/
  should have attribute :gems_published be > 40
  should have attribute :created_at match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
```

```
Failures:

  1) my hash should have attribute :full_name be present
     Failure/Error: it { should have_attribute :full_name }
       Expected attribute :full_name to be present
     # ./spec/examples_spec.rb:24:in `block (2 levels) in <top (required)>'

  2) my hash should have attribute :author match /paul/
     Failure/Error: it { should have_attribute :author, match(/paul/) }
       Expected value of attribute :author to match /paul/ but it was "Paul"
     # ./spec/examples_spec.rb:25:in `block (2 levels) in <top (required)>'
```

## `#resembles_json`

This matcher builds upon `#have_attribute` to let you test an entire JSON document in a single example, but still provide detailed errors about each attribute.

Additionally, it does "fuzzy" matching on the fields (unless a matcher is explicitly given), because its primary purpose it do have a clear and concise example of the API output for documentation.

See the examples folder for more.

### Example Usage

```ruby
RSpec.describe "a basic json document" do
  let(:document) do
    {
      "@id": "/posts/2016/test1",
      "@type": "Post",
      "title": "Hello World!",
      "body": "lorem ipsum",
      "created_at": "2016-03-01T00:03:42",
      "published_at": "2016-03-10T15:35:00"
    }
  end

  specify do
    expect(document).to resemble_json(
      {
        "@id": "/posts/:year/:title",
        "@type": eq("Post"),
        "title": "Hello World!",
        "body": "lorem ipsum",
        "created_at": "2016-03-01T00:03:42",
        "published_at": "2016-03-10T15:35:00"
      }
    )
  end
end
```

Again, it provides good descriptions:

```
  a basic json document
    should resemble json
      {
        "@id": /posts/:year/:title,
        "@type": "Post",
        "title": Hello World!,
        "body": lorem ipsum,
        "created_at": "2016-03-01T00:03:42",
        "published_at": "2016-03-10T15:35:00"
      }
```

And useful failure messages:

```
Failures:

  1) The resembles json matcher a basic json document with several attributes that failed to match should resemble json
  {
    "@id": /posts/:year/:title,
    "@type": "PostCollection",
    "title": 42.0,
    "body": lorem ipsum,
    "created_at": "2016-03-01T00:03:42",
    "published_at": "2016-03-10T15:35:00"
  }

     Failure/Error:
       expect(document).to resemble_json(
         {
           "@id": "/posts/:year/:title",
           "@type": eq("PostCollection"),
           "title": 42.0,
           "body": "lorem ipsum",
           "created_at": "2016-03-01T00:03:42",
           "published_at": "2016-03-10T15:35:00"
         }
       )

       failed because
         attribute "@type":
           expected: "PostCollection"
                got: "Post"
         attribute "title":
           "Hello World!" does not resemble a number
     # ./examples/example_spec.rb:40:in `block (4 levels) in <top (required)>'

  2) The resembles json matcher a basic json document when the matcher is missing a field that is present in the document should resemble json
  {
    "@id": /posts/:year/:title,
    "@type": "Post",
    "body": lorem ipsum,
    "created_at": "2016-03-01T00:03:42",
    "published_at": "2016-03-10T15:35:00"
  }

     Failure/Error:
       expect(document).to resemble_json(
         {
           "@id": "/posts/:year/:title",
           "@type": eq("Post"),
           "body": "lorem ipsum",
           "created_at": "2016-03-01T00:03:42",
           "published_at": "2016-03-10T15:35:00"
         }
       )

       failed because
         attribute "title":
           is present, but no matcher provided to match it
     # ./examples/example_spec.rb:55:in `block (4 levels) in <top (required)>'

  3) The resembles json matcher a basic json document when the document is missing a field that is present in the matcher should resemble json
  {
    "@id": /posts/:year/:title,
    "@type": "Post",
    "body": lorem ipsum,
    "created_at": "2016-03-01T00:03:42",
    "published_at": "2016-03-10T15:35:00"
  }

     Failure/Error:
       expect(document).to resemble_json(
         {
           "@id": "/posts/:year/:title",
           "@type": eq("Post"),
           "body": "lorem ipsum",
           "created_at": "2016-03-01T00:03:42",
           "published_at": "2016-03-10T15:35:00"
         }
       )

       failed because
         attribute "title":
           is present, but no matcher provided to match it
     # ./examples/example_spec.rb:69:in `block (4 levels) in <top (required)>'
```


# Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-json_api_matchers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-json_api_matchers

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/paul/rspec-json_api_matchers.

