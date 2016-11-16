# Blacklight Converter

TODO: Describe the gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blacklight'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blacklight

## Usage

Run the rake task to convert from .zip to .imscc
```sh
	rake imscc
```
This will take all your files in your source folder and convert them to your outputs folder

Run converting files in parallel
```sh
time rake imscc -m
```

Delete entire outputs folder
```sh
rake clean
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/blacklight. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

