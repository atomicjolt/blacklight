require 'rake/testtask'
require 'bundler/setup'
require "rake/clean"

Rake::TestTask.new do |t|
  t.name = :spec
  t.pattern = "spec/*_spec.rb"
  t.verbose = true
  t.warning = false
end


## CHANGED THESE TO CHANGE THE FOLDER LOCATIONS
SOURCE_FILE = 'sources'
OUTPUT_FILE = 'outputs'



SOURCE_FILES = Rake::FileList.new("#{SOURCE_FILE}/*.zip")

task :imscc => SOURCE_FILES.pathmap("%{^#{SOURCE_FILE}/,#{OUTPUT_FILE}/}X.imscc")

directory OUTPUT_FILE

rule ".imscc" => [->(f){source_for_html(f)}, OUTPUT_FILE] do |t|
  mkdir_p t.name.pathmap("%d")
  sh "ruby -Ilib ./bin/import_blackboard ./#{SOURCE_FILE}/"
end

def source_for_html(html_file)
  SOURCE_FILES.detect{|f|
    f.ext('') == html_file.pathmap("%{^#{OUTPUT_FILE}/,#{SOURCE_FILE}/}X")
  }
end

task :clean do
  rm_rf OUTPUT_FILE
end
