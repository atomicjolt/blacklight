require "rake/testtask"
require "bundler/gem_tasks"
require "senkyoshi/tasks"

Rake.application.options.trace_rules = true

Rake::TestTask.new do |t|
  t.name = :spec
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
  t.warning = false
end

task default: :spec

Senkyoshi::Tasks.install_tasks
