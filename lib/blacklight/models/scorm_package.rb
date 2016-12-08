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

    def self.correct_path(path, scorm_path)
      corrected = path.gsub(scorm_path, "")
      corrected.slice(1, corrected.size) if corrected.start_with? "/"
    end

    def to_zip(export_name)
      scorm_path = File.dirname @manifest.name
      Zip::File.open export_name, Zip::File::CREATE do |zip|
        @entries.each do |entry|
          if entry.file?
            zip.get_output_stream(self.class.correct_path(entry.name, scorm_path)) do |file|
              file.write(entry.get_input_stream.read)
            end
          end
        end
      end
    end

    def canvas_conversion
    end

    def api_call
    end
  end
end
