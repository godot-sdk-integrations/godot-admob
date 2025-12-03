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
	add_custom_type(PLUGIN_NODE_TYPE_NAME, PLUGIN_PARENT_NODE_TYPE, preload("%s.gd" % PLUGIN_NODE_TYPE_NAME), preload("icon.png"))
	android_export_plugin = AndroidExportPlugin.new()
	add_export_plugin(android_export_plugin)
	ios_export_plugin = IosExportPlugin.new()
	add_export_plugin(ios_export_plugin)


func _exit_tree() -> void:
	remove_custom_type(PLUGIN_NODE_TYPE_NAME)
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
			if _generate_podfile(a_base_dir, a_project_name) == Error.OK:
				var __script_path = a_base_dir.path_join("setup_pods.sh")
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
							Admob.log_info("Pod install completed successfully!")
							for line in exec_output:
								Admob.log_info("Pods: %s" % line)
						else:
							Admob.log_error("Pod install failed (exit code %d)" % exec_code)
							for line in exec_output:
								Admob.log_error("Pods: %s" % line)
							Admob.log_warn("Check CocoaPods installation and try manually: cd %s && ./setup_pods.sh" % a_base_dir)
					else:
						# Non-macOS: Instructions only
						Admob.log_warn("Non-macOS detected (OS: %s). Manual setup required:" % OS.get_name())
						Admob.log_warn("1. Ensure CocoaPods is installed (run 'gem install cocoapods' on macOS/Linux).")
						Admob.log_warn("2. In terminal: cd '%s'" % a_base_dir)
						Admob.log_warn("3. Run: ./setup_pods.sh")
						Admob.log_warn("4. Open '%s.xcworkspace' in Xcode." % a_project_name)
			else:
				Admob.log_error("Failed to generate podfile!")
		else:
			Admob.log_info("No mediation enabled; skipping Podfile and setup.")


	func _generate_podfile(a_project_dir: String, a_project_name: String) -> Error:
		var __result = Error.OK
		var __podfile_path = a_project_dir.path_join("Podfile")

		# Generate Podfile content
		var __pod_content = """
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

project '%s.xcodeproj'

target '%s' do
	platform :ios, '%s'

%s
end
""" % [a_project_name, a_project_name, IOS_PLATFORM_VERSION, MediationNetwork.generate_pod_list(_export_config.enabled_mediation_networks)]

		# Write Podfile
		var __pod_file = FileAccess.open(__podfile_path, FileAccess.WRITE)
		if __pod_file:
			__pod_file.store_string(__pod_content)
			__pod_file.close()
			Admob.log_info("Generated %s for target '%s' with mediation: %s" % [__podfile_path, a_project_name,
					MediationNetwork.generate_tag_list(_export_config.enabled_mediation_networks)])
			Admob.log_info("Podfile content:\n%s" % __pod_content)
		else:
			Admob.log_error("Failed to write Podfile: %s" % __podfile_path)
			__result = Error.ERR_FILE_CANT_WRITE

		return __result


	func _generate_setup_script(a_script_path: String, a_project_name: String) -> Error:
		var __result: Error = Error.OK

		var __script_content = """#!/bin/bash
set -e	# Exit on error

cd "$(dirname "$0")" 	# Change to project dir
echo "Setting up CocoaPods for mediation..."
pod install --repo-update

echo "Setup complete! Open '%s.xcworkspace' in Xcode (not .xcodeproj)."
""" % a_project_name

		var __script_file = FileAccess.open(a_script_path, FileAccess.WRITE)
		if __script_file:
			__script_file.store_string(__script_content)
			__script_file.close()
			Admob.log_info("Generated setup script: %s" % a_script_path)
			Admob.log_info("Setup script content:\n%s" % __script_content)
		else:
			Admob.log_error("Failed to write setup script: %s" % a_script_path)
			__result = Error.ERR_FILE_CANT_WRITE

		return __result
