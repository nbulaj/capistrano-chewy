# Ensure deploy tasks are loaded before we run
require 'capistrano/deploy'
require 'capistrano-chewy'

load File.expand_path('../tasks/chewy.rake', __FILE__)
