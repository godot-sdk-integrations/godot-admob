#
# © 2024-present https://github.com/cengiz-pz
#

class_name MediationNetwork extends RefCounted

enum Flag {
	APPLOVIN =		1 << 0,		# 1
	CHARTBOOST =	1 << 1,		# 2
	DTEXCHANGE =	1 << 2,		# 4
	IMOBILE =		1 << 3,		# 8
	INMOBI =		1 << 4,		# 16
	IRONSOURCE =	1 << 5,		# 32
	LIFTOFF =		1 << 6,		# 64
	LINE =			1 << 7,		# 128
	MAIO =			1 << 8,		# 256
	META =			1 << 9,		# 512
	MINTEGRAL =		1 << 10,	# 1024
	MOLOCO =		1 << 11,	# 2048
	MYTARGET =		1 << 12,	# 4096
	PANGLE =		1 << 13,	# 8192
	UNITY =			1 << 14,	# 16384
}

const FLAG_PROPERTY: String = "flag"
const TAG_PROPERTY: String = "tag"
const DEPENDENCY_PROPERTY: String = "dependency"
const DEPENDENCY_VERSION_PROPERTY: String = "dependency_version"
const MAVEN_REPO_PROPERTY: String = "maven_repo"
const ANDROID_ADAPTER_CLASS_PROPERTY: String = "android_adapter_class"
const IOS_ADAPTER_CLASS_PROPERTY: String = "ios_adapter_class"
const POD_PROPERTY: String = "pod"
const POD_VERSION_PROPERTY: String = "pod_version"
const SK_AD_NETWORK_IDS_PROPERTY: String = "sk_ad_network_ids"

const GOOGLE_SK_AD_NETWORK_ID = "cstr6suwn9"
const SK_AD_NETWORK_ITEM_LIST_FORMAT: String = """
	<key>SKAdNetworkItems</key>
	<array>
%s
	</array>
"""
const SK_AD_NETWORK_ITEM_FORMAT: String = """
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>%s.skadnetwork</string>
		</dict>
"""

const MEDIATION_NETWORKS: Dictionary = {
	Flag.APPLOVIN: {
			FLAG_PROPERTY: Flag.APPLOVIN,
			TAG_PROPERTY: "applovin",
			DEPENDENCY_PROPERTY: "@applovinDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@applovinDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@applovinMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@applovinAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@applovinIosAdapterClass@",
			POD_PROPERTY: "@applovinPod@",
			POD_VERSION_PROPERTY: "@applovinPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @applovinSkAdNetworkIds@ ]
		},
	Flag.CHARTBOOST: {
			FLAG_PROPERTY: Flag.CHARTBOOST,
			TAG_PROPERTY: "chartboost",
			DEPENDENCY_PROPERTY: "@chartboostDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@chartboostDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@chartboostMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@chartboostAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@chartboostIosAdapterClass@",
			POD_PROPERTY: "@chartboostPod@",
			POD_VERSION_PROPERTY: "@chartboostPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @chartboostSkAdNetworkIds@ ]
		},
	Flag.DTEXCHANGE: {
			FLAG_PROPERTY: Flag.DTEXCHANGE,
			TAG_PROPERTY: "dtexchange",
			DEPENDENCY_PROPERTY: "@dtexchangeDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@dtexchangeDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@dtexchangeMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@dtexchangeAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@dtexchangeIosAdapterClass@",
			POD_PROPERTY: "@dtexchangePod@",
			POD_VERSION_PROPERTY: "@dtexchangePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @dtexchangeSkAdNetworkIds@ ]
		},
	Flag.IMOBILE: {
			FLAG_PROPERTY: Flag.IMOBILE,
			TAG_PROPERTY: "imobile",
			DEPENDENCY_PROPERTY: "@imobileDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@imobileDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@imobileMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@imobileAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@imobileIosAdapterClass@",
			POD_PROPERTY: "@imobilePod@",
			POD_VERSION_PROPERTY: "@imobilePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @imobileSkAdNetworkIds@ ]
		},
	Flag.INMOBI: {
			FLAG_PROPERTY: Flag.INMOBI,
			TAG_PROPERTY: "inmobi",
			DEPENDENCY_PROPERTY: "@inmobiDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@inmobiDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@inmobiMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@inmobiAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@inmobiIosAdapterClass@",
			POD_PROPERTY: "@inmobiPod@",
			POD_VERSION_PROPERTY: "@inmobiPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @inmobiSkAdNetworkIds@ ]
		},
	Flag.IRONSOURCE: {
			FLAG_PROPERTY: Flag.IRONSOURCE,
			TAG_PROPERTY: "ironsource",
			DEPENDENCY_PROPERTY: "@ironsourceDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@ironsourceDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@ironsourceMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@ironsourceAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@ironsourceIosAdapterClass@",
			POD_PROPERTY: "@ironsourcePod@",
			POD_VERSION_PROPERTY: "@ironsourcePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @ironsourceSkAdNetworkIds@ ]
		},
	Flag.LIFTOFF: {
			FLAG_PROPERTY: Flag.LIFTOFF,
			TAG_PROPERTY: "liftoff",
			DEPENDENCY_PROPERTY: "@liftoffDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@liftoffDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@liftoffMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@liftoffAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@liftoffIosAdapterClass@",
			POD_PROPERTY: "@liftoffPod@",
			POD_VERSION_PROPERTY: "@liftoffPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @liftoffSkAdNetworkIds@ ]
		},
	Flag.LINE: {
			FLAG_PROPERTY: Flag.LINE,
			TAG_PROPERTY: "line",
			DEPENDENCY_PROPERTY: "@lineDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@lineDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@lineMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@lineAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@lineIosAdapterClass@",
			POD_PROPERTY: "@linePod@",
			POD_VERSION_PROPERTY: "@linePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @lineSkAdNetworkIds@ ]
		},
	Flag.MAIO: {
			FLAG_PROPERTY: Flag.MAIO,
			TAG_PROPERTY: "maio",
			DEPENDENCY_PROPERTY: "@maioDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@maioDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@maioMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@maioAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@maioIosAdapterClass@",
			POD_PROPERTY: "@maioPod@",
			POD_VERSION_PROPERTY: "@maioPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @maioSkAdNetworkIds@ ]
		},
	Flag.META: {
			FLAG_PROPERTY: Flag.META,
			TAG_PROPERTY: "meta",
			DEPENDENCY_PROPERTY: "@metaDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@metaDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@metaMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@metaAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@metaIosAdapterClass@",
			POD_PROPERTY: "@metaPod@",
			POD_VERSION_PROPERTY: "@metaPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @metaSkAdNetworkIds@ ]
		},
	Flag.MINTEGRAL: {
			FLAG_PROPERTY: Flag.MINTEGRAL,
			TAG_PROPERTY: "mintegral",
			DEPENDENCY_PROPERTY: "@mintegralDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@mintegralDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@mintegralMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@mintegralAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@mintegralIosAdapterClass@",
			POD_PROPERTY: "@mintegralPod@",
			POD_VERSION_PROPERTY: "@mintegralPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @mintegralSkAdNetworkIds@ ]
		},
	Flag.MOLOCO: {
			FLAG_PROPERTY: Flag.MOLOCO,
			TAG_PROPERTY: "moloco",
			DEPENDENCY_PROPERTY: "@molocoDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@molocoDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@molocoMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@molocoAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@molocoIosAdapterClass@",
			POD_PROPERTY: "@molocoPod@",
			POD_VERSION_PROPERTY: "@molocoPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @molocoSkAdNetworkIds@ ]
		},
	Flag.MYTARGET: {
			FLAG_PROPERTY: Flag.MYTARGET,
			TAG_PROPERTY: "mytarget",
			DEPENDENCY_PROPERTY: "@mytargetDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@mytargetDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@mytargetMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@mytargetAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@mytargetIosAdapterClass@",
			POD_PROPERTY: "@mytargetPod@",
			POD_VERSION_PROPERTY: "@mytargetPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @mytargetSkAdNetworkIds@ ]
		},
	Flag.PANGLE: {
			FLAG_PROPERTY: Flag.PANGLE,
			TAG_PROPERTY: "pangle",
			DEPENDENCY_PROPERTY: "@pangleDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@pangleDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@pangleMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@pangleAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@pangleIosAdapterClass@",
			POD_PROPERTY: "@panglePod@",
			POD_VERSION_PROPERTY: "@panglePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @pangleSkAdNetworkIds@ ]
		},
	Flag.UNITY: {
			FLAG_PROPERTY: Flag.UNITY,
			TAG_PROPERTY: "unity",
			DEPENDENCY_PROPERTY: "@unityDependency@",
			DEPENDENCY_VERSION_PROPERTY: "@unityDependencyVersion@",
			MAVEN_REPO_PROPERTY: "@unityMavenRepo@",
			ANDROID_ADAPTER_CLASS_PROPERTY: "@unityAndroidAdapterClass@",
			IOS_ADAPTER_CLASS_PROPERTY: "@unityIosAdapterClass@",
			POD_PROPERTY: "@unityPod@",
			POD_VERSION_PROPERTY: "@unityPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @unitySkAdNetworkIds@ ]
		}
}

const MEDIATION_NETWORK_TAGS: Dictionary = {
	"applovin": Flag.APPLOVIN,
	"chartboost": Flag.CHARTBOOST,
	"dtexchange": Flag.DTEXCHANGE,
	"imobile": Flag.IMOBILE,
	"inmobi": Flag.INMOBI,
	"ironsource": Flag.IRONSOURCE,
	"liftoff": Flag.LIFTOFF,
	"line": Flag.LINE,
	"maio": Flag.MAIO,
	"meta": Flag.META,
	"mintegral": Flag.MINTEGRAL,
	"moloco": Flag.MOLOCO,
	"mytarget": Flag.MYTARGET,
	"pangle": Flag.PANGLE,
	"unity": Flag.UNITY
}

var flag: Flag
var tag: String
var android_dependency: String
var android_dependency_version: String
var android_custom_maven_repo: String
var android_adapter_class: String
var ios_adapter_class: String
var ios_pod: String
var ios_pod_version: String
var sk_ad_network_ids: PackedStringArray


func _init(a_data: Dictionary) -> void:
	flag = a_data[FLAG_PROPERTY]
	tag = a_data[TAG_PROPERTY]
	android_dependency = a_data[DEPENDENCY_PROPERTY]
	android_dependency_version = a_data[DEPENDENCY_VERSION_PROPERTY]
	android_custom_maven_repo = a_data[MAVEN_REPO_PROPERTY]
	android_adapter_class = a_data[ANDROID_ADAPTER_CLASS_PROPERTY]
	ios_adapter_class = a_data[IOS_ADAPTER_CLASS_PROPERTY]
	ios_pod = a_data[POD_PROPERTY]
	ios_pod_version = a_data[POD_VERSION_PROPERTY]
	sk_ad_network_ids = a_data[SK_AD_NETWORK_IDS_PROPERTY]


func get_dependency_string() -> String:
	return "%s:%s" % [android_dependency, android_dependency_version]


func get_pod_string() -> String:
	return "pod '%s', '%s'" % [ios_pod, ios_pod_version]


static func is_flag_enabled(a_value: int, a_flag: Flag) -> bool:
	return a_value & a_flag


static func is_valid_tag(a_tag: String) -> bool:
	return MEDIATION_NETWORK_TAGS.has(a_tag)


static func get_by_flag(a_flag: Flag) -> MediationNetwork:
	return MediationNetwork.new(MEDIATION_NETWORKS[a_flag])


static func get_by_tag(a_tag: String) -> MediationNetwork:
	return get_by_flag(MEDIATION_NETWORK_TAGS[a_tag])


static func get_all_enabled(a_value: int) -> Array[MediationNetwork]:
	var __enabled_networks: Array[MediationNetwork] = []

	for __flag in Flag.values():
		if is_flag_enabled(a_value, __flag):
			__enabled_networks.append(get_by_flag(__flag))

	return __enabled_networks


static func get_all_enabled_tags(a_value: int) -> Array[String]:
	var __enabled_network_tags: Array[String] = []

	for __flag in Flag.values():
		if is_flag_enabled(a_value, __flag):
			var __network: MediationNetwork = get_by_flag(__flag)
			__enabled_network_tags.append(__network.tag)

	return __enabled_network_tags


static func generate_sk_ad_network_plist(a_networks: Array[MediationNetwork]) -> String:
	var __sk_ad_ids_plist_content: String

	var __unique_sk_network_ad_ids: Dictionary = { GOOGLE_SK_AD_NETWORK_ID: null }
	for __network in a_networks:
		for __network_id in __network.sk_ad_network_ids:
			if not __unique_sk_network_ad_ids.has(__network_id):
				__unique_sk_network_ad_ids.set(__network_id, null)

	for __network_id in __unique_sk_network_ad_ids.keys():
		__sk_ad_ids_plist_content += SK_AD_NETWORK_ITEM_FORMAT % __network_id

	return SK_AD_NETWORK_ITEM_LIST_FORMAT % __sk_ad_ids_plist_content


static func generate_pod_list(a_networks: Array[MediationNetwork]) -> String:
	var __pod_list_content: String = ""

	for __network in a_networks:
		__pod_list_content += "  " + __network.get_pod_string() + "\n"

	return __pod_list_content


static func generate_tag_list(a_networks: Array[MediationNetwork]) -> String:
	var __enabled_network_tags: PackedStringArray = []

	for __network in a_networks:
		__enabled_network_tags.append(__network.tag)

	return ",".join(__enabled_network_tags)
