# Senkyoshi Converter [![Build Status](https://travis-ci.org/atomicjolt/senkyoshi.svg?branch=master)](https://travis-ci.org/atomicjolt/senkyoshi)

Senkyoshi converts exported Blackboard packages into Canvas .imscc packages. It also allows you to upload those converted packages to a Canvas instance.

## Feature Comparison

Senkyoshi converts Blackboard course exports as well as Instructure's converter with several improvements detailed in the table below:

| Feature  | Instructure Blackboard Converter | Senkyoshi |
|:---------|----------------------------------|-----------|
| Announcements | Partial Conversion, links embedded or otherwise are not converted/broken. | Converts all announcements including all links. |
|Assignments|All assignments lumped into one big group.  No separations from quizzes, surveys, and assignments, some broken links in content.| Separates the assignments into a few categories based on Blackboard structure: Tests, Assignments, Surveys, Practicums, and Quizzes. A few courses have broken links to files that did not exist in the Blackboard course file. All links in content work appropriately. |
|Discussions|Basic conversion supported, some discussions missing.| All discussions, including Blackboard Seminar Discussions, are imported with topic content.|
|Pages|Basic conversion supported, some pages missing or content links broken.|Creates pages for most all module items and separates them per assignment and lesson page from Blackboard structure.  Creates additional pages for Blackboard attachments that have content descriptions.|
|Files|Basic support, flattened file directories into a single top level with all files. | Keeps folder/file structure from Blackboard when importing to Canvas Files. |
|Quizzes|Basic support, unable to convert quiz answers in certain formats and converts an incorrect number of quizzes from the quiz banks.| Converts the correct amount of quizzes and is able to determine all the correct answers for each quiz. Changes Blackboard formats that Canvas doesn't support into correct formats.|
|Modules|Basic support, modules created at a single level and category. | Converts Blackboard Lesson Category structure into Canvas Modules with indented structure for sub-content. |
|Pre-requisites|No support for Blackboard Adaptive Release.| Converts Blackboard Adaptive Release content into Canvas Pre-Requisite requirements to view certain class material. Follows same format that was used in Blackboard.|
|SCORM|No support for SCORM content.|*(Optional)* Uploads SCORM packages to a SCORM management system tool in Canvas as well as place them into Canvas Files. Will find any SCORM packages that exist in a Blackboard course export.|

## Installation

#### Canvas
See [Senkyoshi Canvas Plugin](https://github.com/atomicjolt/senkyoshi_canvas_plugin) if you want to enable this in your canvas app.

#### CLI
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

Create a `Rakefile` and add:
```ruby
require "senkyoshi/tasks"
Senkyoshi::Tasks.install_tasks
```

Create a `senkyoshi.yml` and add credentials:
```yaml
# Generally looks like https://< mycanvas_instance >/api
:canvas_url: <canvas instance api url>

# Canvas tokens can be generated at <my_canvas_url>/profile/settings provided
# that the user has the required privileges
:canvas_token: <canvas token>

# The account or sub-account ID. This can be :self, :default, or an ID
:account_id: <id>

# URL of SCORM manager. This could be the Adhesion app
# [https://github.com/atomicjolt/adhesion]
:scorm_url: <scorm manager url>

# This should be the endpoint to launch a given SCORM course. In the case of
# Adhesion, this will look like https://<adhesion url>/scorm_course
:scorm_launch_url: <scorm launch url>

# This should be the oauth_consumer_key for scorm. In the case of
# Adhesion, it would just be `scorm`.
:scorm_oauth_consumer_key: <scorm oauth consumer key>

# This is the shared id for the jwt aud. In the case of Adhesion it
# will be `adhesion`.
:scorm_shared_id: <scorm shared id>

# This is the secret used to create a jwt to communicate with the SCORM manager.
:scorm_shared_auth: <scorm manager token>

# The number of seconds before uploads timeout. Defaults to 1800 (30 minutes)
:request_timeout: <request timeout seconds>
```

## CLI Usage

Senkyoshi rake tasks can be used to batch convert Blackboard Courses to Canvas Courses and optionally upload them to a Canvas instance.

It expects all Blackboard courses to be converted to be in a folder called `sources`, and outputs to a folder

Run the rake task to convert from .zip to .imscc:
```bash
rake senkyoshi:imscc
```
This will take all your files in your source folder and convert them to your outputs folder.

Run converting files in parallel:
```bash
time rake senkyoshi:imscc -m # The `time` command is optional.
```

Delete entire outputs folder:
```bash
rake clean
```

Upload to Canvas to process:
```bash
rake senkyoshi:upload
```

## Development

After checking out the repo, run `bundle install` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/atomicjolt/senkyoshi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [AGPL-3.0 License](http://www.gnu.org/licenses/).
