# Senkyoshi Converter [![Build Status](https://travis-ci.org/atomicjolt/senkyoshi.svg?branch=master)](https://travis-ci.org/atomicjolt/senkyoshi)

TODO: Describe the gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem "senkyoshi"
gem "canvas_cc", git: "https://github.com/atomicjolt/canvas_cc.git"
```

And then execute:
```sh
$ bundle
```

Or install it yourself as:
```sh
$ gem install senkyoshi
```

Create a `Rakefile` and add
```ruby
require "senkyoshi/tasks"
Senkyoshi::Tasks.install_tasks
```

Create a `senkyoshi.yml` and add credentials
```yaml
# Generally looks like https://< mycanvas_instance >/api
:canvas_url: <canvas instance api url>

# Canvas tokens can be generated at <my_canvas_url>/profile/setting provided
# that the user has the required priviledges
:canvas_token: <canvas token>

# Url of scorm manager. This could the the adhesion app
# [https://github.com/atomicjolt/adhesion]
:scorm_url: <scorm manager url>

# This should be the endpoint to launch a given scorm course, in the case of
# adhesion this will look like https://<adhesion url>/scorm_course
:scorm_launch_url: <scorm launch url>

# This is the secret to authenticate requests to the scorm manager. In the case
# of adhesion you can generate a shared secret by logging into the server and
# running rake shared_auth, which will generate and save a token
:scorm_shared_auth: <scorm manager token>

# The account or sub-account id. This can be :self, :default, or an id
:account_id: <id>
```

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

After checking out the repo, run `bundle install` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/senkyoshi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


### Things not quite implemented
People Group Sets
Blogs
