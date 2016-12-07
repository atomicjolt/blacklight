require "rake/testtask"
require "bundler/setup"
require "blacklight/tasks"

Rake::TestTask.new do |t|
  t.name = :spec
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
  t.warning = false
end

task default: :spec

Bundler::GemHelper.install_tasks
Blacklight::Tasks.install_tasks
