require "pandarus"
require "senkyoshi/models/scorm_package"
require "rest-client"

module Senkyoshi
  ##
  # This class represents a canvas course for which we are uploading data to
  ##

  class CanvasCourse
    attr_reader :scorm_packages

    ##
    # A new canvas course accepts the metadata for a course
    # and the pandarus course resourse
    ##
    def initialize(metadata, course_resource, blackboard_export)
      @metadata = metadata
      @course_resource = course_resource
      @scorm_packages = ScormPackage.get_scorm_packages(blackboard_export)
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
        prefix: Senkyoshi.configuration.canvas_url,
        token: Senkyoshi.configuration.canvas_token,
      )
    end

    ##
    # Find or Create a new CanvasCourse instance from the given metadata
    ##
    def self.from_metadata(metadata, blackboard_export = nil)
      course_name = metadata[:name] || metadata[:title]
      canvas_course = client.create_new_course(
        Senkyoshi.configuration.account_id,
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
    def create_scorm_assignment(scorm_package, course_id, local)
      if local
        _create_scorm_assignment_local(scorm_package)
      else
        _create_scorm_assignment_external(scorm_package, course_id)
      end
    end

    ##
    # Assembles the launch url with the course_id
    ##
    def _scorm_launch_url(package_id)
      "#{Senkyoshi.configuration.scorm_launch_url}?course_id=#{package_id}"
    end

    ##
    # Creates a scorm assignment from a Canvas course object
    ##
    def _create_scorm_assignment_local(scorm_package)
      url = _scorm_launch_url(scorm_package["package_id"])

      payload = {
        title: scorm_package["title"],
        submission_types: "external_tool",
        integration_id: scorm_package["package_id"],
        integration_data: {
          provider: "atomic-scorm",
        },
        external_tool_tag_attributes: {
          url: url,
        },
        points_possible: scorm_package["points_possible"],
      }

      # @course_resource in this case is a Canvas course object
      @course_resource.assignments.create(payload)
    end

    ##
    # Creates a scorm assignment using the Canvas api
    ##
    def _create_scorm_assignment_external(scorm_package, course_id)
      url = _scorm_launch_url(scorm_package["package_id"])

      payload = {
        assignment__submission_types__: ["external_tool"],
        assignment__integration_id__: scorm_package["package_id"],
        assignment__integration_data__: {
          provider: "atomic-scorm",
        },
        assignment__external_tool_tag_attributes__: {
          url: url,
        },
        assignment__points_possible__: scorm_package["points_possible"],
      }

      CanvasCourse.client.create_assignment(
        course_id,
        scorm_package["title"],
        payload,
      )
    end

    ##
    # Uploads a scorm package to scorm manager specified in senkyoshi.yml
    # config file
    ##
    def upload_scorm_package(scorm_package, course_id, tmp_name)
      zip = scorm_package.write_zip tmp_name
      File.open(zip, "rb") do |file|
        RestClient.post(
          "#{Senkyoshi.configuration.scorm_url}/api/scorm_courses",
          {
            oauth_consumer_key: "scorm-player",
            lms_course_id: course_id,
            file: file,
          },
          SharedAuthorization: Senkyoshi.configuration.scorm_shared_auth,
        ) do |resp|
          result = nil
          begin
            result = JSON.parse(resp.body)["response"]
            raise Exceptions::BadResponse.new if result.nil?
            result["points_possible"] = scorm_package.points_possible
          rescue Exceptions::BadResponse, JSON::ParserError => e
            STDERR.puts(
              "Error: Invalid response from Scorm Manager: #{e}",
            )
          end

          result
        end
      end
    end

    ##
    # Creates assignments from all previously uploaded scorm packages
    ##
    def create_scorm_assignments(scorm_packages, course_id, local)
      scorm_packages.map do |pack|
        create_scorm_assignment(pack, course_id, local) if !pack.nil?
      end
    end

    ##
    # Uploads all scorm packages to scorm manager specified in senkyoshi.yml
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

    def process_scorm(local: false)
      create_scorm_assignments(
        upload_scorm_packages(@scorm_packages),
        @course_resource.id,
        local,
      )
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
      puts "Done uploading: #{name}"

      puts "Creating Scorm: #{name}"
      process_scorm
      puts "Done creating scorm: #{name}"
    end

    def upload_to_s3(migration, filename)
      File.open(filename, "rb") do |file|
        # Attach the file to the S3 auth
        pre_attachment = migration.pre_attachment
        upload_url = pre_attachment["upload_url"]
        upload_params = pre_attachment["upload_params"]
        upload_params[:file] = file

        # Post to S3
        RestClient::Request.execute(
          method: :post,
          url: upload_url,
          payload: upload_params,
          timeout: Senkyoshi.configuration.request_timeout,
        ) do |response|
          # Post to Canvas
          RestClient.post(
            response.headers[:location],
            nil,
            Authorization: "Bearer #{Senkyoshi.configuration.canvas_token}",
          )
        end
      end
    end
  end
end
