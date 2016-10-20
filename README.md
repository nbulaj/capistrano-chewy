# Capistrano::Chewy
[![Gem Version](https://badge.fury.io/rb/capistrano-chewy.svg)](http://badge.fury.io/rb/capistrano-chewy)
[![Build Status](https://travis-ci.org/nbulaj/capistrano-chewy.svg?branch=master)](https://travis-ci.org/nbulaj/capistrano-chewy)
[![Dependency Status](https://gemnasium.com/nbulaj/capistrano-chewy.svg)](https://gemnasium.com/nbulaj/capistrano-chewy)
[![Code Climate](https://codeclimate.com/github/nbulaj/capistrano-chewy/badges/gpa.svg)](https://codeclimate.com/github/nbulaj/capistrano-chewy)

Manage and continuously rebuild your ElasticSearch indexes with [Chewy](https://github.com/toptal/chewy/) and [Capistrano](https://github.com/capistrano/capistrano) v3.

`Capistrano::Chewy` gem adds automatic conditionally reset of only modified Chewy indexes and the removal of deleted index files to your deploy flow so you do not have to do it manually.
Moreover, it adds the possibility of manual index management with the base Chewy tasks on the remote server.

## Requirements

* Ruby >= 1.9.3
* Capistrano >= 3.0
* Chewy >= 0.4

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-chewy', require: false
```

or:

```ruby
gem 'capistrano-chewy', require: false, group: :development
```

And then run bundler:

```
$ bundle
```

Or install it yourself as:

```
$ gem install capistrano-chewy
```

If you want to use the latest version from the `master`, then add the following line to your Gemfile:

```ruby
gem 'capistrano-chewy', git: 'https://github.com/nbulaj/capistrano-chewy.git'
```

## Usage

Require it in your `Capfile`:

```ruby
# Capfile

...
require 'capistrano/chewy'
...
```

then you can use `cap -T` to list `Capistrano::Chewy` tasks:

```ruby
cap chewy:rebuild            # Reset only modified Chewy indexes
cap chewy:reset              # Destroy, recreate and import data to all the indexes
cap chewy:reset[indexes]     # Destroy, recreate and import data to the specified indexes
cap chewy:update             # Updates data to all the indexes
cap chewy:update[indexes]    # Updates data to the specified indexes
```

By default `Capistrano::Chewy` adds `deploy:chewy:rebuild` task after `deploy:updated` and `deploy:reverted`.
If you want to change it, then you need to disable default gem hooks by setting `chewy_default_hooks` to `false` in your deployment config and manually define the order of the tasks.

## Configuration

You can setup the following:

```ruby
# deploy.rb
set :chewy_conditionally_reset, false    # Reset only modified Chewy indexes, true by default
set :chewy_path, 'app/my_indexes'        # Path to Chewy indexes, 'app/chewy' by default
set :chewy_env, :chewy_production        # Environment variable for Chewy, equal to RAILS_ENV by default
set :chewy_role, :web                    # Chewy role, :app by default
set :chewy_default_hooks, false          # Add default capistrano-chewy hooks to your deploy flow, true by default
set :chewy_delete_removed_indexes, false # Delete indexes which files have been deleted, true by default
```

## Contributing

1. Fork it ( http://github.com/nbulaj/capistrano-chewy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
