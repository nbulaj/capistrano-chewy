# Capistrano::Chewy

Manage and continuously rebuild your ElasticSearch indexes with [Chewy](https://github.com/toptal/chewy/) and [Capistrano](https://github.com/capistrano/capistrano) v3.

`Capistrano::Chewy` gem adds automatic conditionally reset only modified Chewy indexes to your deploy flow so you do not have to build them manually.
Moreover, it adds the possibility of manual index management with the base Chewy tasks on the remote server.

## Installation

:fire: **IMPORTANT: currently under development!** :fire:

Currently can be installed only with:

```ruby
gem 'capistrano-chewy', git: 'https://github.com/nbulaj/capistrano-chewy.git'
```

### WIP

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-chewy', require: false
```

or:

```ruby
gem 'capistrano-chewy', require: false, group: :development
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install capistrano-chewy
```

## Usage

Require it in your `Capfile`:

```ruby
# Capfile

require 'capistrano/chewy'
```

then you can use ```cap -T``` to list tasks:

```ruby
cap deploy:chewy:rebuild            # Reset only modified Chewy indexes
cap deploy:chewy:reset              # Destroy, recreate and import data to all the indexes
cap deploy:chewy:reset[indexes]     # Destroy, recreate and import data to the specified indexes
cap deploy:chewy:update             # Updates data to all the indexes
cap deploy:chewy:update[indexes]    # Updates data to the specified indexes
```

## Configuration

You can setup the following:

```ruby
# deploy.rb
set :chewy_conditionally_reset, false # Reset only modified Chewy indexes, true by default
set :chewy_path, 'app/my_indexes' # Path to Chewy indexes, 'app/chewy' by default
set :chewy_env, :chewy_production # Environment variable for Chewy, equal to RAILS_ENV by default
set :chewy_role, :web # Chewy role, :app by default
set :chewy_skip, true # Skip processing Chewy indexes during deploy, false by default
```

## Contributing

1. Fork it ( http://github.com/nbulaj/capistrano-chewy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
