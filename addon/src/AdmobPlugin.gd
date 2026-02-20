#
# © 2024-present https://github.com/cengiz-pz
#

@tool
extends EditorPlugin

const PLUGIN_NODE_TYPE_NAME = "@pluginNodeName@"
const PLUGIN_PARENT_NODE_TYPE = "Node"
const PLUGIN_NAME: String = "@pluginName@"
const ANDROID_DEPENDENCIES: Array = [ @androidDependencies@ ]
const IOS_PLATFORM_VERSION: String = "@iosPlatformVersion@"
const IOS_FRAMEWORKS: Array = [ @iosFrameworks@ ]
const IOS_EMBEDDED_FRAMEWORKS: Array = [ @iosEmbeddedFrameworks@ ]
const IOS_LINKER_FLAGS: Array = [ @iosLinkerFlags@ ]

const APP_ID_META_TAG = """
<meta-data
		tools:replace="android:value"
		android:name="com.google.android.gms.ads.APPLICATION_ID"
		android:value="%s"/>
"""

var android_export_plugin: AndroidExportPlugin
var ios_export_plugin: IosExportPlugin


func _enter_tree() -> void:
	android_export_plugin = AndroidExportPlugin.new()
	add_export_plugin(android_export_plugin)
	ios_export_plugin = IosExportPlugin.new()
	add_export_plugin(ios_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(android_export_plugin)
	android_export_plugin = null
	remove_export_plugin(ios_export_plugin)
	ios_export_plugin = null


class AndroidExportPlugin extends EditorExportPlugin:
	var _plugin_name = PLUGIN_NAME
	var _export_config: AdmobAndroidExportConfig


	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid


	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		if debug:
			return PackedStringArray(["%s/bin/debug/%s-debug.aar" % [_plugin_name, _plugin_name]])
		else:
			return PackedStringArray(["%s/bin/release/%s-release.aar" % [_plugin_name, _plugin_name]])


	func _get_name() -> String:
		return _plugin_name


	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		if _supports_platform(get_export_platform()):
			_export_config = AdmobAndroidExportConfig.new()
			if not _export_config.export_config_file_exists() or _export_config.load_export_config_from_file() != OK:
				_export_config.load_export_config_from_node()


	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		var deps: PackedStringArray = PackedStringArray(ANDROID_DEPENDENCIES)
		if _export_config and _export_config.enabled_mediation_networks.size() > 0:
			for __network in _export_config.enabled_mediation_networks:
				for __dependency in __network.android_dependencies:
					deps.append(__dependency)

		Admob.log_info("Android dependencies: %s" % str(deps))

		return deps


	func _get_android_dependencies_maven_repos(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		var __custom_repos: PackedStringArray = []

		if _export_config and _export_config.enabled_mediation_networks.size() > 0:
			for network in _export_config.enabled_mediation_networks:
				if network.android_custom_maven_repo and not network.android_custom_maven_repo.is_empty():
					__custom_repos.append(network.android_custom_maven_repo)
					Admob.log_info("Added custom Maven repo for %s mediation: %s" %
							[network.tag, network.android_custom_maven_repo])

		return __custom_repos


	func _get_android_manifest_application_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		var __contents: String

		if _export_config:
			__contents = APP_ID_META_TAG % (_export_config.real_application_id if _export_config.is_real else _export_config.debug_application_id)
		else:
			Admob.log_warn("Export config not found for %s!" % _plugin_name)
			__contents = ""

		return __contents


class IosExportPlugin extends EditorExportPlugin:
	const NS_APP_TRANSPORT_SECURITY: String = """
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoads</key>
	<true/>
	<key>NSAllowsArbitraryLoadsInWebContent</key>
	<true/>
</dict>
"""

	var _plugin_name = PLUGIN_NAME
	var _export_config: AdmobIosExportConfig
	var _export_path: String


	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformIOS


	func _get_name() -> String:
		return _plugin_name


	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		if _supports_platform(get_export_platform()):
			_export_path = path.simplify_path()
			_export_config = AdmobIosExportConfig.new()
			if not _export_config.export_config_file_exists() or _export_config.load_export_config_from_file() != OK:
				_export_config.load_export_config_from_node()

			add_apple_embedded_platform_plist_content("<key>GADApplicationIdentifier</key>")
			add_apple_embedded_platform_plist_content("\t<string>%s</string>" % (_export_config.real_application_id if _export_config.is_real else _export_config.debug_application_id))

			if _export_config.att_enabled and _export_config.att_text and not _export_config.att_text.is_empty():
				add_apple_embedded_platform_plist_content("<key>NSUserTrackingUsageDescription</key>")
				add_apple_embedded_platform_plist_content("<string>%s</string>" % _export_config.att_text)

			add_apple_embedded_platform_plist_content(MediationNetwork.generate_sk_ad_network_plist(_export_config.enabled_mediation_networks))

			add_apple_embedded_platform_plist_content(NS_APP_TRANSPORT_SECURITY)

			for __framework in IOS_FRAMEWORKS:
				add_apple_embedded_platform_framework(__framework)

			for __framework in IOS_EMBEDDED_FRAMEWORKS:
				add_apple_embedded_platform_embedded_framework(__framework)

			for __flag in IOS_LINKER_FLAGS:
				add_apple_embedded_platform_linker_flags(__flag)


	func _export_end() -> void:
		if _supports_platform(get_export_platform()):
			_install_mediation_dependencies(_export_path.get_base_dir(), _export_path.get_file().get_basename())


	func _install_mediation_dependencies(a_base_dir: String, a_project_name: String) -> void:
		if _export_config.enabled_mediation_networks.size() > 0:
			if _generate_dependency_script(a_base_dir, a_project_name) == Error.OK:
				var __script_path = a_base_dir.path_join("setup_packages.sh")
				if _generate_setup_script(__script_path, a_project_name) == Error.OK:
					if OS.has_feature("macos"):
						Admob.log_info("Detected macOS: Auto-running pod install...")

						# Step 1: Make executable
						var chmod_output: Array = []
						var chmod_code = OS.execute("chmod", ["+x", __script_path], chmod_output, true, false)
						if chmod_code != 0:
							Admob.log_error("Failed to chmod script: %s" % (chmod_output if chmod_output.size() > 0 else "Unknown error"))
							Admob.log_warn("Run manually: cd %s && ./setup_pods.sh" % a_base_dir)
							return

						# Step 2: Execute the script (blocking; captures output)
						var exec_output: Array = []
						var exec_code = OS.execute(__script_path, [], exec_output, true, false)

						if exec_code == 0:
							Admob.log_info("Mediation dependency packages added successfully!")
							for line in exec_output:
								Admob.log_info("SPM: %s" % line)
						else:
							Admob.log_error("Failed to add mediation dependency packages (exit code %d)" % exec_code)
							for line in exec_output:
								Admob.log_error("SPM: %s" % line)
							Admob.log_warn("Try manually: cd %s && ./setup_packages.sh" % a_base_dir)
					else:
						# Non-macOS: Instructions only
						Admob.log_warn("Non-macOS detected (OS: %s). Manual setup required:" % OS.get_name())
						Admob.log_warn("1. In terminal: cd '%s'" % a_base_dir)
						Admob.log_warn("2. Run: ./setup_packages.sh")
						Admob.log_warn("3. Open '%s.xcodeproj' in Xcode." % a_project_name)
			else:
				Admob.log_error("Failed to generate dependency script!")
		else:
			Admob.log_info("No mediation enabled; skipping mediation dependency setup.")


	const ADD_DEPENDENCIES_RUBY_SCRIPT = """
require 'xcodeproj'

project_path = "%s.xcodeproj"
deps = [ %s ]

unless File.exist?(project_path)
	puts "Error: Xcode project not found at #{project_path}"
	exit 1
end

begin
	project = Xcodeproj::Project.open(project_path)
	target = project.targets.first

	if target.nil?
		puts "Error: No targets found in the Xcode project."
		exit 1
	end

	# Store the target UUID for fixing scheme files later
	target_uuid = target.uuid

	# Clean up old build files to prevent duplicate/dangling references on re-exports
	target.frameworks_build_phase.files.delete_if do |file|
		!file.product_ref.nil? && file.product_ref.class == Xcodeproj::Project::Object::XCSwiftPackageProductDependency
	end

	project.root_object.package_references.clear
	target.package_product_dependencies.clear

	# After clearing references and dependencies, also remove orphaned object definitions
	project.objects.each do |uuid, obj|
		if obj.class == Xcodeproj::Project::Object::XCRemoteSwiftPackageReference ||
				obj.class == Xcodeproj::Project::Object::XCSwiftPackageProductDependency
			project.objects.delete(uuid)
		end
	end

	deps.each do |dep|
		next if dep.empty?
		parts = dep.split('|').map(&:strip)

		if parts.size == 3
			url, version, product_name = parts

			pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
			pkg.repositoryURL = url

			pkg.requirement = {
				'kind' => 'exactVersion',
				'version' => version
			}
			project.root_object.package_references << pkg

			ref = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
			ref.product_name = product_name
			ref.package = pkg
			target.package_product_dependencies << ref

			# Link the dependency in the Frameworks Build Phase so it actually compiles
			build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
			build_file.product_ref = ref
			target.frameworks_build_phase.files << build_file
		else
			puts "Warning: Skipping invalid SPM dependency format: #{dep}. Expected 'URL|Version|ProductName'"
		end
	end

	project.save
	puts "Successfully updated SPM dependencies in #{File.basename(project_path)}"

	# Fix scheme files to use the correct target UUID
	scheme_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
	if Dir.exist?(scheme_dir)
		Dir.glob(File.join(scheme_dir, '*.xcscheme')).each do |scheme_file|
			content = File.read(scheme_file)

			modified = content.gsub(/BlueprintIdentifier\\s*=\\s*"[A-F0-9]{24}"/) do |match|
				"BlueprintIdentifier = \\"#{target_uuid}\\""
			end

			if modified != content
				File.write(scheme_file, modified)
				puts "Fixed scheme file: #{File.basename(scheme_file)}"
			end
		end
	end

rescue => e
	puts "An error occurred: #{e.message}"
	puts e.backtrace
	exit 1
end
"""

	func _generate_dependency_script(a_project_dir: String, a_project_name: String) -> Error:
		var __result = Error.OK
		var __script_path = a_project_dir.path_join("add_dependencies.rb")

		# Generate Podfile content
		var __script_content = ADD_DEPENDENCIES_RUBY_SCRIPT % [
				a_project_name,
				MediationNetwork.generate_package_list(_export_config.enabled_mediation_networks)
			]

		# Write Podfile
		var __script_file = FileAccess.open(__script_path, FileAccess.WRITE)
		if __script_file:
			__script_file.store_string(__script_content)
			__script_file.close()
			Admob.log_info("Generated %s for target '%s' with mediation: %s" % [__script_path, a_project_name,
					MediationNetwork.generate_tag_list(_export_config.enabled_mediation_networks)])
		else:
			Admob.log_error("Failed to write script file: %s" % __script_path)
			__result = Error.ERR_FILE_CANT_WRITE

		return __result


	const SETUP_BASH_SCRIPT = """
#!/bin/bash
set -e	# Exit on error

cd "$(dirname "$0")" 	# Change to project dir

echo
echo "Adding dependencies for mediation..."

ruby "add_dependencies.rb"

echo
echo "Resolving dependencies for mediation..."

xcodebuild -resolvePackageDependencies \
			-project "%s.xcodeproj" \
			-scheme "%s" || true

echo
echo "Setup complete!"
"""

	func _generate_setup_script(a_script_path: String, a_project_name: String) -> Error:
		var __result: Error = Error.OK

		var __script_content = SETUP_BASH_SCRIPT % [ a_project_name, a_project_name]

		var __script_file = FileAccess.open(a_script_path, FileAccess.WRITE)
		if __script_file:
			__script_file.store_string(__script_content)
			__script_file.close()
			Admob.log_info("Generated setup script: %s" % a_script_path)
		else:
			Admob.log_error("Failed to write setup script: %s" % a_script_path)
			__result = Error.ERR_FILE_CANT_WRITE

		return __result
