module Senkyoshi
  class ScormPackage
    attr_accessor(:entries, :manifest, :points_possible)

    def initialize(zip_file, manifest, scorm_item = nil)
      @manifest = manifest
      @entries = ScormPackage.get_entries zip_file, manifest
      @points_possible = if scorm_item
                           scorm_item.xpath(
                             "/scormItem/gradebookInfo/@pointsPossible",
                           ).text
                         end
    end

    ##
    # Extracts scorm packages from a blackboard export zip file
    ##
    def self.get_scorm_packages(blackboard_export)
      find_scorm_items(blackboard_export).
        map do |item|
          manifest_entry = find_scorm_manifest(blackboard_export, item)
          ScormPackage.new blackboard_export, manifest_entry, item
        end
    end

    ##
    # Returns paths to scormItem files
    ##
    def self.find_scorm_item_paths(zip_file)
      Nokogiri::XML.parse(
        Senkyoshi.read_file(zip_file, "imsmanifest.xml"),
      ).
        xpath("//resource[@type='resource/x-plugin-scormengine']").
        map { |r| r.xpath("./@bb:file").text }
    rescue Exceptions::MissingFileError
      []
    end

    ##
    # Returns array of parsed scormItem files
    ##
    def self.find_scorm_items(zip_file)
      find_scorm_item_paths(zip_file).map do |path|
        Nokogiri::XML.parse(zip_file.get_input_stream(path).read)
      end
    end

    ##
    # Returns the zip file entry for the scorm package manifest, given
    # a scormItem file
    ##
    def self.find_scorm_manifest(zip_file, scorm_item)
      path = scorm_item.xpath("/scormItem/@mappedContentId").text
      zip_file.get_entry("#{path}/imsmanifest.xml")
    end

    ##
    # Returns array of all scorm manifest files inside of blackboard export
    ##
    def self.find_scorm_manifests(zip_file)
      find_scorm_items(zip_file).map do |scorm_item|
        find_scorm_manifest(zip_file, scorm_item)
      end
    end

    ##
    # Returns array of paths to scorm packages
    ##
    def self.find_scorm_paths(zip_file)
      manifests = ScormPackage.find_scorm_manifests(zip_file)
      manifests.map { |manifest| File.dirname(manifest.name) }
    end

    ##
    # Returns array of all zip file entries that belong in scorm package
    ##
    def self.get_entries(zip_file, manifest)
      zip_file.entries.select do |e|
        File.dirname(e.name).start_with?(File.dirname(manifest.name)) &&
          !e.directory?
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
              ScormPackage.correct_path(entry.name, scorm_path),
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
