# RSpec::JsonApiMatchers

This gem provides a set of matchers that make testing JSON documents (actually
the hashes parsed from them) simpler and more elegant.

It provides two matchers, `have_attribute` and `match_json`.

## `#have_attribute`

Use this matcher when you want to examine a single attribute, and optionally
match against its value.

### Example Usage

```ruby
RSpec.describe "my hash" do
  include RSpec::JsonApiMatchers

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

## `#match_json`

This matcher builds upon `#have_attribute` to let you test an entire JSON document in a single example, but still provide detailed errors about each attribute.

### Example Usage

```ruby
RSpec.describe "my json response document" do
  include RSpec::JsonApiMatchers

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

```

Again, it provides good descriptions and useful failure messages:

```
my json response document
  should have json that looks like
      {
        "author": "Paul",
        "gems_published": be > 40,
        "created_at": match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
      }
```

```
  1) my json response document should have json that looks like
      {
        "author": "Someone else",
        "gems_published": be > 40,
        "created_at": match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/,
        "does_not_exist": be present
      }
     Failure/Error:
       it { should match_json(
         {
           author: "Paul",
           gems_published: be > 40,
           created_at: iso8601_timestamp,
           does_not_exist: be_present,
           author: "Someone else"
         }
       )}

       Expected:
         {
           "author": "Paul",
           "gems_published": 42,
           "created_at": "2016-01-01T00:00:00Z"
         }
       To match:
         {
           "author": "Someone else",
           "gems_published": be > 40,
           "created_at": match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/,
           "does_not_exist": be present
         }
       Failures:
         {
           "author": Expected value of attribute "author" to eq "Someone else" but it was "Paul",
           "does_not_exist": Expected value of attribute "does_not_exist" to be present but it was nil
         }
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

