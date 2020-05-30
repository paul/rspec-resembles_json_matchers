# RSpec::ResemblesJsonMatchers

[![Gem Version](https://badge.fury.io/rb/rspec-json_api_matchers.svg)](https://badge.fury.io/rb/rspec-json_api_matchers)[![Build Status](https://travis-ci.org/paul/rspec-json_api_matchers.svg?branch=master)](https://travis-ci.org/paul/rspec-json_api_matchers)


This gem provides a set of matchers that make testing JSON documents (actually the hashes parsed from them) simpler and more elegant.

## `resemble` Matcher

Oftentimes when testing your JSON API responses, you don't care about the actual values matching exactly, just that they "resemble" your expected values. This gem provides a variety of matchers to just get close:

### Numbers

Anything that's a Ruby `Numeric` will match:

```ruby
# These pass
expect(10).to   resemble 42
expect(3.14).to resemble 42
expect(10).to   resemble 42.4

# These fail
expect("string").to resemble 42
expect(Time.now).to resemble 42
```

I haven't needed it yet, but I'm open to discussing if more accurate matches would be needed. For example:

 * Does 1_000_000_000 "resemble" 1?
 * Does a float "resemble" an integer?


### Dates/Times

Anything that is a Ruby `Date`/`Time`/`DateTime`, or a string that can be parsed by `Time.iso8601` will match:

```ruby
# These pass
expect(Time.now).to         resemble "2018-01-01T00:00:00Z"
expect(Time.now.iso8601).to resemble "2018-01-01T00:00:00Z"

# These fail
expect("Some string").to resemble "2018-01-01T00:00:00Z"
```

Open questions:

 * Does `"2018-01-01T00:00:00-0700"` "resemble" `"2018-01-01T00:00:00Z"`? That is, should it ensure the timezone matches?
 * Do non-ISO8601 datetimes "resemble" ISO8601 ones?
 * Is there a permissible time range? Does the year 1600 "resemble" 2017? Does `"0000-00-00T00:00:00Z"`? Does `Time.at(0)`?

### Rails routes

If you're using Rails (specifically `ActionDispatch`), we can check that routes resemble each other:

```ruby
# These pass
expect("/posts/1").to                    resemble posts_path(post)
expect("/posts/1000000").to              resemble posts_path(post)
expect("https://example.com/posts/1").to resemble posts_path(post)

# These fail
expect("/users/1").to    resemble posts_path(post)
expect("Some string").to resemble posts_path(post)
```

### Strings

Any string that didn't match one of the other resembles matchers will match:

```ruby
# These pass
expect("Some string").to resemble "some other string"
expect("").to            resemble "some other string"
expect("a" * 100_000).to resemble "some other string"

# These fail
expect(42).to       resemble "42"
expect(Time.now).to resemble "Time.now

```

Open questions:

 * Should there be some heuristic to decide if a string resembles another? Does length matter?

## `#resemble_json/match_json`

The resembles matchers are nice on their own, but their power shines when used with the `resembles_json` matcher. This allows you to write an example JSON document in your spec, and match it against the output from a request. Any values in the "expected" document that aren't already matchers will be converted to the best `resembles` matcher. You can write plain json documents as the expected, or be explicit by specifying matchers.


### Example Usage

```ruby
RSpec.describe "a basic json document" do
  # This would probably actually come from something like `JSON.parse(response.body)`
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
        "@id": post_path(post),                 # resembles route
        "@type": eq("Post"),                    # using an explicit matcher to match exactly
        "title": match(/^Hello/),               # another explicit matcher
        "body": "lorem ipsum",                  # resembles string
        "created_at": "2016-03-01T00:03:42",    # resembles time
        "published_at": post.published_at       # Also resembles time
      }
    )
  end
end
```

It provides good descriptions if you run `rspec` with `--format=documentation`:

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

It also provides a failure message as a diff of the JSON object:

```
  1) The resembles json matcher a basic json document with several attributes that failed to match should have json that looks like
  {
    "@id": "/posts/:year/:title",
    "@type": "PostCollection",
    "title": 42.0,
    "body": "lorem ipsum",
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

       {
         "@id": "/posts/:year/:title",
       - "@type": eq "PostCollection",
       + "@type": "Post",
       - "title": 42.0,
       + "title": "Hello World!",
         "body": "lorem ipsum",
         "created_at": "2016-03-01T00:03:42",
         "published_at": "2016-03-10T15:35:00"
       }
     # ./examples/example_spec.rb:40:in `block (4 levels) in <top (required)>'
```

It can also handle nested JSON documents and Arrays, showing the proper diffs. See the `./examples` directory, but it works pretty much how you'd expect.

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

## License


[![WTFPL](http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-4.png)][http://www.wtfpl.net/]
