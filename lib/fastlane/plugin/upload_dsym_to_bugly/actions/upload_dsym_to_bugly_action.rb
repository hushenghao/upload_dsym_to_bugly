require "fastlane/action"
require_relative "../helper/upload_dsym_to_bugly_helper"
require 'fileutils'

module Fastlane
  module Actions
    module SharedValues
      UPLOAD_DSYM_TO_BUGLY_RESULT = :UPLOAD_DSYM_TO_BUGLY_RESULT
    end
    class UploadDsymToBuglyAction < Action
      def self.run(params)

        jar_path = File.expand_path('../../jars/buglyqq-upload-symbol.jar', __FILE__)
        UI.message "jar path: #{jar_path}"

        mapping_file_path = nil
        if params[:mapping_file_path]
          mapping_file_path = File.expand_path("#{params[:mapping_file_path]}")
        end
        UI.message "mapping file path: #{mapping_file_path}"

        file_path = nil
        unzip_path = nil
        if params[:file_path]
          file_path = File.expand_path("#{params[:file_path]}")
          unzip_path = File.expand_path(".upload_dsym_to_bugly_tmp", "#{File.dirname("#{file_path}")}") 

          if Dir.exist?(unzip_path)
            FileUtils.rm_r(unzip_path, force: true)
          end
        end 
        UI.message "file path: #{file_path}"
        UI.message "unzip path: #{unzip_path}"

        has_mapping = mapping_file_path != nil && !Dir.glob(mapping_file_path).empty?
        has_symbol = file_path != nil && !Dir.glob(file_path).empty?

        if !has_mapping && !has_symbol
          UI.message "dSYM zip or mapping.txt File don't exist"
          Actions.lane_context[SharedValues::UPLOAD_DSYM_TO_BUGLY_RESULT] = false
          raise if params[:raise_if_error]
        end
        if has_symbol
          sh("unzip -o \"#{file_path}\" -d \"#{unzip_path}\"")
        end

        java_path = params[:java_path] || 'java'
        cmd = "#{java_path} -jar \"#{jar_path}\" -appid \"#{params[:app_id]}\" -appkey \"#{params[:app_key]}\" -bundleid \"#{params[:bundle_id]}\" -version \"#{params[:version]}\" -buildNo \"#{params[:build_no]}\" -platform \"#{params[:platform]}\" -inputSymbol \"#{unzip_path}\" -inputMapping \"#{mapping_file_path}\""

        log_file = "dSYM_upload_result.log"

        begin
          sh("#{cmd} > #{log_file}")
          log_content = File.read("#{log_file}")

          success = log_content.include?("retCode: 200") and log_content.include?("\"msg\":\"所有符号表都已经上传过。\"")
          if success
            UI.success " 🎉 🎉 🎉 dSYM upload successfully (づ｡◕‿‿◕｡)づ"            
            Actions.lane_context[SharedValues::UPLOAD_DSYM_TO_BUGLY_RESULT] = true
          else
            UI.error "┭┮﹏┭┮ dSYM upload failed ┭┮﹏┭┮"
            Actions.lane_context[SharedValues::UPLOAD_DSYM_TO_BUGLY_RESULT] = false
            raise if params[:raise_if_error]        
          end

        rescue => exception
          UI.message "dSYM upload failed, See log output above"
          Actions.lane_context[SharedValues::UPLOAD_DSYM_TO_BUGLY_RESULT] = false
          raise if params[:raise_if_error]
        end
      end

      def self.description
        "upload_dsym_to_bugly"
      end

      def self.authors
        ["liubo"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_APP_ID",
                                       description: "app id",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No APP id for UploadDsymToBuglyAction given, pass using `app_id: 'app_id'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_key,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_APP_KEY",
                                       description: "app key",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No APP key for UploadDsymToBuglyAction given, pass using `api_key: 'app_key'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :bundle_id,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_BUNDLE_ID",
                                       description: "bundle id",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No symbol type for UploadDsymToBuglyAction given, pass using `bundle_id: 'bundle_id'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_VERSION",
                                       description: "app version",
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No symbol type for UploadDsymToBuglyAction given, pass using `version: 'version'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :build_no,
                                        env_name: "FL_UPLOAD_DSYM_TO_BUGLY_VERSION",
                                        description: "build no",
                                        is_string: true,
                                        verify_block: proc do |value|
                                          UI.user_error!("No symbol type for UploadDsymToBuglyAction given, pass using `build_no: 'build_no'`") unless (value and not value.empty?)
                                        end,
                                        optional: true),
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_FILE",
                                       description: "file path",
                                       is_string: true,
                                       verify_block: proc do |value|
                                          UI.user_error!("No symbol type for UploadDsymToBuglyAction given, pass using `file_path: 'file_path'`") unless (value and not value.empty?)
                                       end,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :mapping_file_path,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_FILE",
                                       description: "mapping file path",
                                       is_string: true,
                                       verify_block: proc do |value|
                                          UI.user_error!("No symbol type for UploadDsymToBuglyAction given, pass using `mapping_file_path: 'mapping_file_path'`") unless (value and not value.empty?)
                                       end,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_FILE",
                                       description: "platform",
                                       is_string: true,
                                       default_value: "IOS",
                                       verify_block: proc do |value|
                                         UI.user_error!("platform value error, available values: IOS, Android") unless (value == "IOS" or value == "Android")
                                      end),
          FastlaneCore::ConfigItem.new(key: :raise_if_error,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_RAISE_IF_ERROR",
                                       description: "Raises an error if fails, so you can fail CI/CD jobs if necessary \(true/false)",
                                       default_value: true,
                                       is_string: false,
                                       type: Boolean,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :java_path,
                                       env_name: "FL_UPLOAD_DSYM_TO_BUGLY_JAVA_PATH",
                                       description: "Use specific Java, instead of system one",
                                       default_value: nil,
                                       is_string: true,
                                       optional: true),
        ]
      end

      def self.output
        [
          ["UPLOAD_DSYM_TO_BUGLY_RESULT", "upload result"],
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
