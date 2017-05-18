# encoding: utf-8

require 'bundler/setup'
require 'bundler/gem_tasks'

task default: %w(spec rubocop)

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new
