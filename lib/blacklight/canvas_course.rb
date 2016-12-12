require "pandarus"
require "blacklight/config"
require "blacklight/models/scorm_package"
require "rest-client"

module Blacklight
  class CanvasCourse
    def initialize(metadata, course_resource, blackboard_export)
      @metadata = metadata
      @course_resource = course_resource
      @scorm_packages = self.class.get_scorm_packages(blackboard_export) # TODO add specs
    end

    def self.metadata_from_file(filename)
      Zip::File.open(filename) do |file|
        settings = "course_settings/course_settings.xml"
        config = file.find_entry(settings).get_input_stream.read
        doc = Nokogiri::XML(config)
        {
          name: doc.at("title").text,
        }
      end
    end

    def self.client
      @client ||= Pandarus::Client.new(
        prefix: Blacklight.canvas_url,
        token: Blacklight.canvas_token,
      )
    end

    def self.get_scorm_packages(zip_file)
      ScormPackage.find_scorm_manifests(zip_file).map do |manifest|
        ScormPackage.new zip_file, manifest
      end
    end

    def self.from_metadata(metadata, blackboard_export = nil)
      course_name = metadata[:name] || metadata[:title]
      courses = client.list_active_courses_in_account(:self)
      course = courses.detect { |c| c.name == course_name } ||
        client.create_new_course(
          :self,
          course: {
            name: metadata[:name],
            id: course.id
          },
        )

      CanvasCourse.new(metadata, course, blackboard_export)
    end

    def upload_scorm
      package_index = 0
      scorm_package_zips = @scorm_packages.map do |pack|
        pack.write_zip "#{@metadata[:name]}_#{package_index}"
        package_index += 1
      end
    end

    def upload_content(filename)
      client = CanvasCourse.client
      name = File.basename(filename)
      migration = client.
        create_content_migration_courses(
          @course_resource.id,
          :canvas_cartridge_importer,
          pre_attachment: { name: name },
        )

      pre_attachment = migration.pre_attachment
      upload_url = pre_attachment["upload_url"]
      upload_params = pre_attachment["upload_params"]
      upload_params[:file] = File.new(filename, "rb")

      puts "Uploading: #{name}"
      # RestClient.post(
      #   upload_url,
      #   upload_params,
      # )

      upload_scorm
      puts "Done uploading: #{name}"
    end
  end
end
