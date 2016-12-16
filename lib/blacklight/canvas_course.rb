require "pandarus"
require "blacklight/config"
require "blacklight/models/scorm_package"
require "rest-client"

module Blacklight
  ##
  # This class represents a canvas course for which we are uploading data to
  ##
  class CanvasCourse
    ##
    # A new canvas course accepts the metadata for a course
    # and the pandarus course resourse
    ##
    def initialize(metadata, course_resource, blackboard_export)
      @metadata = metadata
      @course_resource = course_resource
      @scorm_packages = CanvasCourse.get_scorm_packages(blackboard_export)
    end

    ##
    # Extracts scorm packages from a blackboard export zip file
    ##
    def self.get_scorm_packages(blackboard_export)
      ScormPackage.find_scorm_manifests(blackboard_export).map do |manifest|
        ScormPackage.new blackboard_export, manifest
      end
    end

    ##
    # Given a filename to a zip file, extract the necessary metadata
    # for the course
    ##
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

    ##
    # Create a new pandarus instance to communicate with the canvas server
    ##
    def self.client
      @client ||= Pandarus::Client.new(
        prefix: Blacklight.canvas_url,
        token: Blacklight.canvas_token,
      )
    end

    ##
    # Find or Create a new CanvasCourse instance from the given metadata
    ##
    def self.from_metadata(metadata, blackboard_export = nil)
      course_name = metadata[:name] || metadata[:title]
      courses = client.list_active_courses_in_account(Blacklight.account_id)
      canvas_course = courses.detect { |course| course.name == course_name } ||
        client.create_new_course(
          Blacklight.account_id,
          course: {
            name: course_name,
          },
        )
      CanvasCourse.new(metadata, canvas_course, blackboard_export)
    end

    ##
    # Creates a canvas assignment from a scorm package that has already been
    # uploaded to a scorm manager
    ##
    def create_scorm_assignment(scorm_package, course_id)
      url = "#{Blacklight.scorm_launch_url}?" +
        "course_id=#{scorm_package['package_id']}"

      payload = {
        assignment__submission_types__: ["external_tool"],
        assignment__integration_id__: scorm_package["package_id"],
        assignment__integration_data__: {
          provider: "atomic-scorm",
        },
        assignment__external_tool_tag_attributes__: {
          url: url,
        },
      }

      CanvasCourse.client.create_assignment(
        course_id,
        scorm_package["title"],
        payload,
      )
    end

    ##
    # Uploads a scorm package to scorm manager specified in blacklight.yml
    # config file
    ##
    def upload_scorm_package(scorm_package, course_id, tmp_name)
      zip = scorm_package.write_zip tmp_name
      RestClient.post(
        "#{Blacklight.scorm_url}/api/scorm_courses",
        {
          oauth_consumer_key: "scorm-player",
          lms_course_id: course_id,
          file: File.new(zip, "rb"),
        },
        SharedAuthorization: Blacklight.scorm_shared_auth,
      ) do |resp|
        JSON.parse(resp.body)["response"]
      end
    end

    ##
    # Creates assignments from all previously uploaded scorm packages
    ##
    def create_scorm_assignments(scorm_packages, course_id)
      scorm_packages.each { |pack| create_scorm_assignment(pack, course_id) }
    end

    ##
    # Uploads all scorm packages to scorm manager specified in blacklight.yml
    # config file
    ##
    def upload_scorm_packages(scorm_packages)
      package_index = 0
      scorm_packages.map do |pack|
        package_index += 1
        tmp_name = "#{@metadata[:name]}_#{package_index}.zip"
        upload_scorm_package(pack, @course_resource.id, tmp_name)
      end
    end

    ##
    # Create a migration for the course
    # and upload the imscc file to be imported into the course
    ##
    def upload_content(filename)
      client = CanvasCourse.client
      name = File.basename(filename)
      # Create a migration for the course and get S3 upload authorization
      migration = client.
        create_content_migration_courses(
          @course_resource.id,
          :canvas_cartridge_importer,
          pre_attachment: { name: name },
        )

      puts "Uploading: #{name}"
      upload_to_s3(migration, filename)
      create_scorm_assignments(
        upload_scorm_packages(@scorm_packages),
        @course_resource.id,
      )

      puts "Done uploading: #{name}"
    end

    def upload_to_s3(migration, filename)
      # Attach the file to the S3 auth
      pre_attachment = migration.pre_attachment
      upload_url = pre_attachment["upload_url"]
      upload_params = pre_attachment["upload_params"]
      upload_params[:file] = File.new(filename, "rb")

      # Post to S3
      RestClient.post(
        upload_url,
        upload_params,
      ) do |response|
        # Post to Canvas
        RestClient.post(
          response.headers[:location],
          nil,
          Authorization: "Bearer #{Blacklight.canvas_token}",
        )
      end
    end
  end
end
