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

    def write_zip(export_name)
      @@dir ||= Dir.mktmpdir
      scorm_path = File.dirname @manifest.name
      path = "#{@@dir}/#{export_name}"
      Zip::File.open path, Zip::File::CREATE do |zip|
        @entries.each do |entry|
          if entry.file?
            zip.get_output_stream(
              self.class.correct_path(entry.name, scorm_path),
            ) do |file|
              file.write(entry.get_input_stream.read)
            end
          end
        end
      end
      path
    end

    # cleanup temp files
    def self.cleanup
      @@dir ||= nil
      FileUtils.rm_r @@dir unless @@dir.nil?
    end

    def canvas_conversion(course)
      @@count ||= 0
      write_zip("export#{@@count}.zip")
      @@count += 1
      course
    end

    def self.dir
      @@dir ||= nil
    end

    def api_call
    end
  end
end
