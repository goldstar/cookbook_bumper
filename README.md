[![CircleCI](https://circleci.com/gh/goldstar/cookbook_bumper.svg?style=svg&circle-token=123299b301092a28c04343c4b39489e4f3c78964)](https://circleci.com/gh/goldstar/cookbook_bumper)

# CookbookBumper

CookBumper does exactly what you think, it bumps cookbook versions for you as you modify them.

When it runs it looks for cookbooks that have been modified and bumps them.  It also updates your
environment files with the latest versions of all the cookbooks, and gives a nice little print out
of what it did.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cookbook_bumper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cookbook_bumper

## Usage

Configure it as a rake task

```ruby
require 'cookbook_bumper/rake_task'

CookbookBumper::RakeTask.new(:bump)
```

Or use it directly from the command line

```bash
$ cookbook_bumper
                   production
-------------------------------------------------
 Cookbook             Action   Old Ver   New Ver
-------------------------------------------------
 apparmor             Deleted  = 0.9.0
 awscli               Bumped   = 0.0.3   0.0.4
 backups              Updated  = 0.1.6   0.1.7
                     staging
-------------------------------------------------
 Cookbook             Action   Old Ver   New Ver
-------------------------------------------------
 apparmor             Deleted  = 0.9.0
 awscli               Bumped   = 0.0.3   0.0.4
 backups              Updated  = 0.1.6   0.1.7
```

## Configuration

At the moment the only way to change the default settings is through the rake task


* `cookbook_path` - Where to look for cookbooks - `Array` (default: read from `knife.rb`)
* `environment_path` - Where to look for environment files - `Array` (default: read from `knife.rb`)
* `exclude_environment` - Names of environments to leave alone - `Array` (default: `['development']`)
* `repo_root` - Root of repository to look for changes - `String` (default\*: `./`)
* `knife_path` - Location of `knife.rb` - `String` (default\*: `./.chef/knife.rb`)

\*:_Relative paths are relative to the location of the Rakefile_

```ruby
require 'cookbook_bumper/rake_task'

CookbookBumper::RakeTask.new(:bump) do |config|
  config.knife_path = './knife.rb'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/goldstar/cookbook_bumper.


