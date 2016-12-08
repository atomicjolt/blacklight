module Blacklight
  class ScormPackage
    attr_accessor(:entries, :manifest)

    def initialize(zip_file, manifest)
      @manifest = manifest
      @entries = ScormPackage.get_entries zip_file, manifest
    end

    def self.get_entries(zip_file, manifest)
      zip_file.entries.select do |e|
        File.dirname(e.name).include? File.dirname(manifest.name)
      end
    end

    def to_zip
      # TODO use get_output_stream, and then both put_next_entry, and write to write
      # new zip
      # http://stackoverflow.com/questions/23957178/how-can-i-create-a-zip-file-without-temporary-files-in-ruby
    end

    def canvas_conversion
    end

    def api_call
    end
  end
end
