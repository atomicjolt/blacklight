require 'rake/testtask'
require 'bundler/setup'
require "rake/clean"

Rake::TestTask.new do |t|
  t.name = :spec
  t.pattern = "spec/*_spec.rb"
  t.verbose = true
  t.warning = false
end

SOURCE_FILES = Rake::FileList.new("sources/*.zip")

task :imscc => SOURCE_FILES.pathmap("%{^sources/,outputs/}X.imscc")

directory "outputs"

rule ".imscc" => [->(f){source_for_html(f)}, "outputs"] do |t|
  mkdir_p t.name.pathmap("%d")
  sh "ruby -Ilib ./bin/import_blackboard ./sources"
end

def source_for_html(html_file)
  SOURCE_FILES.detect{|f|
    f.ext('') == html_file.pathmap("%{^outputs/,sources/}X")
  }
end

task :clean do
  rm_rf "outputs"
end
