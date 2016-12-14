module Blacklight
  class ScormPackage
    attr_accessor(:entries, :manifest)

    ##
    # Scorm packages should include this string in the <schema> tag. We
    # downcase, and remove spaces to be more consistant
    ##
    SCORM_SCHEMA = "adlscorm".freeze

    def initialize(zip_file, manifest)
      @manifest = manifest
      @entries = ScormPackage.get_entries zip_file, manifest
    end

    ##
    # Returns true if a manifest is a scorm manifest file, false otherwise
    ##
    def self.scorm_manifest?(manifest)
      begin
        parsed_manifest = Nokogiri::XML(manifest.get_input_stream.read)
        schema_name = parsed_manifest.
          xpath("//xmlns:metadata/xmlns:schema").
          text.delete(" ").downcase
        return schema_name == SCORM_SCHEMA

      # NOTE we occasionally run into malformed manifest files
      rescue Nokogiri::XML::XPath::SyntaxError
        false
      end
    end

    ##
    # Returns array of all scorm manifest files inside of blackboard export
    ##
    def self.find_scorm_manifests(zip_file)
      return [] if zip_file.nil?
      zip_file.
        entries.select do |e|
          File.fnmatch("*imsmanifest.xml", e.name) && scorm_manifest?(e)
        end
    end

    ##
    # Returns array of all zip file entries that belong in scorm package
    ##
    def self.get_entries(zip_file, manifest)
      zip_file.entries.select do |e|
        File.dirname(e.name).include? File.dirname(manifest.name)
      end
    end

    ##
    # Returns file path with relative path to scorm package removed
    ##
    def self.correct_path(path, scorm_path)
      corrected = path.gsub(scorm_path, "")
      corrected.slice(1, corrected.size) if corrected.start_with? "/"
    end

    ##
    # Writes all entries to a zip file in a temporary directory and returns
    # location of temporary file
    ##
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

    ##
    # Removes all temp files if they exist
    ##
    def self.cleanup
      @@dir ||= nil
      FileUtils.rm_r @@dir unless @@dir.nil?
    end
  end
end
