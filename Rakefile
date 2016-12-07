require "rake/testtask"
require "bundler/setup"
require "rake/clean"

Rake::TestTask.new do |t|
  t.name = :spec
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
  t.warning = false
end

task default: :spec

## CHANGED THESE TO CHANGE THE FOLDER LOCATIONS
SOURCE_DIR = "sources".freeze
OUTPUT_DIR = "canvas".freeze

## Don"t change these, these are just getting the last
## of the folder name for the script below"s use
SOURCE_NAME = SOURCE_DIR.split("/").last
OUTPUT_NAME = OUTPUT_DIR.split("/").last
SOURCE_FILES = Rake::FileList.new("#{SOURCE_DIR}/*.zip")

task imscc: SOURCE_FILES.pathmap("%{^#{SOURCE_NAME}/,#{OUTPUT_DIR}/}X.imscc")

directory OUTPUT_NAME

rule ".imscc" => [->(f) { source_for_imscc(f) }, OUTPUT_NAME] do |t|
  mkdir_p t.name.pathmap("%d")
  mkdir_p OUTPUT_DIR
  sh "ruby -Ilib ./bin/import_blackboard #{SOURCE_DIR}/ #{OUTPUT_DIR}/"
end

def source_for_imscc(imscc_file)
  SOURCE_FILES.detect do |f|
    f.ext("") == imscc_file.pathmap("%{^#{OUTPUT_DIR}/,#{SOURCE_DIR}/}X")
  end
end

task :clean do
  rm_rf OUTPUT_DIR
end



Bundler::GemHelper.install_tasks
