require 'fileutils'
require 'cocoapods-core'
require 'json'


module Fastlane
  module Actions
    module SharedValues
      PODSPEC_CUSTOM_VALUE = :PODSPEC_CUSTOM_VALUE
    end

    class PodspecAction < Action
      Dependency = Struct.new("PodspecDependency", :name, :version, keyword_init: true)

      def self.run(params)
        podfile = Pod::Podfile.from_file(params[:podfile])

        dependencies =  podfile.target_definitions[params[:name]].nil? ? [] : podfile.target_definitions[params[:name]].dependencies.map do |dep| 
          Dependency.new(
            name: dep.name.split("/").first,
            version: dep.to_s.scan(/\((.*)\)/m).flatten[0]&.gsub("-APD", "")
          )
        end

        # Removes Stack dependencies from adapters (inherited from Appodeal)
        # And BidMachine bidding adapters
        if params[:is_adapter] 
          unless params[:name].include?("Stack") 
            dependencies = dependencies.select { |d| !d.name.include?("Stack") && !d.name.start_with?("BDM") }
          end

          dependencies.append(Dependency.new(
            name: "Bidon",
            version: params[:sdk_version]
          ))
        end

        podspec = Pod::Specification.new do |spec|
          spec.name = params[:name]
          spec.version = params[:version]
          spec.summary = params[:name] == "Bidon" ? "Bidon iOS Framework" : "Bidon adapter for #{params[:name]}"
          spec.description = <<-DESC
          Appodeal’s supply-side platform is designed and built by veteran publishers,for publishers. Appodeal is not an ad network; it is a new approach to monetizing for publishers.
        The platform is a large auction house, accompanied by a mediation layer, that exposes a publisher’s inventory to all available buyers on the market via relationships with every major ad network, RTB exchange, and DSP. Appodeal showcases publisher inventory to the advertiser, and offers the highest rate in real time.
        Appodeal’s goal is to cater to the needs of the publisher, not the advertiser, so you always know that you’re in good hands.
                         DESC
          spec.homepage = "https://appodeal.com"
          spec.license = { :type => "Copyright", :text => "Copyright #{Time.new.year}. Appodeal, Inc." }
          spec.author = { "Appodeal, Inc" => "https://appodeal.com" }
          spec.platform = :ios, "10.0"
          spec.source = { :http => "https://s3-us-west-1.amazonaws.com/appodeal-ios/Bidon/#{spec.name}/#{spec.version}/#{spec.name}.zip" }
          spec.swift_versions = "4.0", "4.2", "5.0"
        
          spec.vendored_frameworks = params[:vendored_frameworks]
            
          dependencies.each do | dep |
            if dep.version.nil? 
              spec.dependency dep.name
            else 
              spec.dependency dep.name, dep.version
            end
          end

          root = params[:podfile].split('/')[0...-1].join('/') + "/Pods"

          pod_target_xcconfig = {
            "OTHER_LDFLAGS": "-lObjC",
            "VALID_ARCHS[sdk=iphoneos*]": "arm64 armv7",
          }

          user_target_xcconfig = {
            "OTHER_LDFLAGS": "-lObjC"
          }

          if self.is_apple_silicon_compatible(dependencies, root) 
            pod_target_xcconfig["VALID_ARCHS[sdk=iphonesimulator*]"] = "x86_64 arm64"
          elsif self.is_legacy_framework(dependencies, root)
            pod_target_xcconfig["VALID_ARCHS[sdk=iphonesimulator*]"] = "x86_64"
            user_target_xcconfig["VALID_ARCHS[sdk=iphoneos*]"] = "arm64 armv7"
            user_target_xcconfig["VALID_ARCHS[sdk=iphonesimulator*]"] = "x86_64"
          else
            pod_target_xcconfig["VALID_ARCHS[sdk=iphonesimulator*]"] = "x86_64"
          end

          spec.pod_target_xcconfig = pod_target_xcconfig
          spec.user_target_xcconfig = user_target_xcconfig
        end
        
        File.open(params[:path] + "/" + params[:name] + ".podspec.json", "w") do |f|
          f.write(JSON.pretty_generate(podspec))
        end
      end

      def self.description
        "Generate Podspec by using of project Podfile"
      end

      def self.is_apple_silicon_compatible(dependencies, root) 
        return dependencies.inject(true) do |result, dep|
          return  Dir.glob(root + "/" + dep.name + "/**/*").inject(result) do |result, path|
            components = path.split('/')
            # Search xcframeworks first and read it info.plist
            if components[-1] == 'Info.plist' && components[-2].end_with?(".xcframework")
              plist = Xcodeproj::Plist.read_from_path(path)
              supports_arm_64_simulator = plist["AvailableLibraries"]
                .select { |lib| lib["SupportedPlatformVariant"] == "simulator" && lib["SupportedArchitectures"].include?("arm64") }
                .length > 0
              result && supports_arm_64_simulator
            elsif components[-1].end_with?(".framework") && !path.include?("xcframework")
              result && false
            else 
              result && true
            end
          end
        end
      end

      def self.is_legacy_framework(dependencies, root)
        return dependencies.inject(true) do |result, dep|
          return  Dir.glob(root + "/" + dep.name + "/**/*").inject(result) do |result, path|
            components = path.split('/')
            result && components[-1].end_with?(".framework") && !path.include?("xcframework")
          end
        end
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :version,
            description: "Version",
            verify_block: proc do |value|
              UI.user_error!("No version for Podspec given, pass using `version: 'x.y.z`") unless (value and not value.empty?)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :is_adapter,
            description: "Identifies that podspec is adapter or not",
            default_value: false,
            optional: true,
            is_string: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :sdk_version,
            description: "SDK version",
            optional: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :podfile,
            description: "Path to podfile",
            verify_block: proc do |value|
              UI.user_error!("No Podfile path given, pass using `podfile: '/User/../Podfile'`") unless (value and not value.empty?)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :name,
            description: "Name of Podspec",
            verify_block: proc do |value|
              UI.user_error!("No Podspec path given, pass using `name: 'name'`") unless (value and not value.empty?)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :path,
            description: "Path to Podspec file",
            verify_block: proc do |value|
              UI.user_error!("No Podspec path given, pass using `path: '/User/../*.podspec'`") unless (value and not value.empty?)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :vendored_frameworks,
            description: "Vendored frameworks",
            is_string: false,
            default_value: []
          )
        ]
      end

      def self.output
        [
          ['PODSPEC_CUSTOM_VALUE', '']
        ]
      end

      def self.authors
        ["Appodeal"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end