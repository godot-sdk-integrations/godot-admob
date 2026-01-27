#
# © 2024-present https://github.com/cengiz-pz
#

class_name MediationNetwork extends RefCounted

enum Flag {
	APPLOVIN =		1 << 0,		## AppLovin
	CHARTBOOST =	1 << 1,		## Chartboost
	DTEXCHANGE =	1 << 2,		## DT Exchange (previously Fyber)
	IMOBILE =		1 << 3,		## i-mobile
	INMOBI =		1 << 4,		## InMobi
	IRONSOURCE =	1 << 5,		## ironSource
	LIFTOFF =		1 << 6,		## Liftoff Monetize (previously Vungle)
	LINE =			1 << 7,		## LINE Ads Network
	MAIO =			1 << 8,		## maio
	META =			1 << 9,		## Meta Audience Network (previously Facebook)
	MINTEGRAL =		1 << 10,	## Mintegral
	MOLOCO =		1 << 11,	## Moloco
	MYTARGET =		1 << 12,	## myTarget
	PANGLE =		1 << 13,	## Pangle
	UNITY =			1 << 14,	## Unity Ads
}

const FLAG_PROPERTY: String = "flag"
const TAG_PROPERTY: String = "tag"
const DEPENDENCIES_PROPERTY: String = "dependencies"
const MAVEN_REPO_PROPERTY: String = "maven_repo"
const POD_PROPERTY: String = "pod"
const POD_VERSION_PROPERTY: String = "pod_version"
const SK_AD_NETWORK_IDS_PROPERTY: String = "sk_ad_network_ids"

const GOOGLE_SK_AD_NETWORK_IDS = [ @googleSkAdNetworkIds@ ]
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
			DEPENDENCIES_PROPERTY: [ @applovinDependencies@ ],
			MAVEN_REPO_PROPERTY: "@applovinMavenRepo@",
			POD_PROPERTY: "@applovinPod@",
			POD_VERSION_PROPERTY: "@applovinPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @applovinSkAdNetworkIds@ ]
		},
	Flag.CHARTBOOST: {
			FLAG_PROPERTY: Flag.CHARTBOOST,
			TAG_PROPERTY: "chartboost",
			DEPENDENCIES_PROPERTY: [ @chartboostDependencies@ ],
			MAVEN_REPO_PROPERTY: "@chartboostMavenRepo@",
			POD_PROPERTY: "@chartboostPod@",
			POD_VERSION_PROPERTY: "@chartboostPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @chartboostSkAdNetworkIds@ ]
		},
	Flag.DTEXCHANGE: {
			FLAG_PROPERTY: Flag.DTEXCHANGE,
			TAG_PROPERTY: "dtexchange",
			DEPENDENCIES_PROPERTY: [ @dtexchangeDependencies@ ],
			MAVEN_REPO_PROPERTY: "@dtexchangeMavenRepo@",
			POD_PROPERTY: "@dtexchangePod@",
			POD_VERSION_PROPERTY: "@dtexchangePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @dtexchangeSkAdNetworkIds@ ]
		},
	Flag.IMOBILE: {
			FLAG_PROPERTY: Flag.IMOBILE,
			TAG_PROPERTY: "imobile",
			DEPENDENCIES_PROPERTY: [ @imobileDependencies@ ],
			MAVEN_REPO_PROPERTY: "@imobileMavenRepo@",
			POD_PROPERTY: "@imobilePod@",
			POD_VERSION_PROPERTY: "@imobilePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @imobileSkAdNetworkIds@ ]
		},
	Flag.INMOBI: {
			FLAG_PROPERTY: Flag.INMOBI,
			TAG_PROPERTY: "inmobi",
			DEPENDENCIES_PROPERTY: [ @inmobiDependencies@ ],
			MAVEN_REPO_PROPERTY: "@inmobiMavenRepo@",
			POD_PROPERTY: "@inmobiPod@",
			POD_VERSION_PROPERTY: "@inmobiPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @inmobiSkAdNetworkIds@ ]
		},
	Flag.IRONSOURCE: {
			FLAG_PROPERTY: Flag.IRONSOURCE,
			TAG_PROPERTY: "ironsource",
			DEPENDENCIES_PROPERTY: [ @ironsourceDependencies@ ],
			MAVEN_REPO_PROPERTY: "@ironsourceMavenRepo@",
			POD_PROPERTY: "@ironsourcePod@",
			POD_VERSION_PROPERTY: "@ironsourcePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @ironsourceSkAdNetworkIds@ ]
		},
	Flag.LIFTOFF: {
			FLAG_PROPERTY: Flag.LIFTOFF,
			TAG_PROPERTY: "liftoff",
			DEPENDENCIES_PROPERTY: [ @liftoffDependencies@ ],
			MAVEN_REPO_PROPERTY: "@liftoffMavenRepo@",
			POD_PROPERTY: "@liftoffPod@",
			POD_VERSION_PROPERTY: "@liftoffPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @liftoffSkAdNetworkIds@ ]
		},
	Flag.LINE: {
			FLAG_PROPERTY: Flag.LINE,
			TAG_PROPERTY: "line",
			DEPENDENCIES_PROPERTY: [ @lineDependencies@ ],
			MAVEN_REPO_PROPERTY: "@lineMavenRepo@",
			POD_PROPERTY: "@linePod@",
			POD_VERSION_PROPERTY: "@linePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @lineSkAdNetworkIds@ ]
		},
	Flag.MAIO: {
			FLAG_PROPERTY: Flag.MAIO,
			TAG_PROPERTY: "maio",
			DEPENDENCIES_PROPERTY: [ @maioDependencies@ ],
			MAVEN_REPO_PROPERTY: "@maioMavenRepo@",
			POD_PROPERTY: "@maioPod@",
			POD_VERSION_PROPERTY: "@maioPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @maioSkAdNetworkIds@ ]
		},
	Flag.META: {
			FLAG_PROPERTY: Flag.META,
			TAG_PROPERTY: "meta",
			DEPENDENCIES_PROPERTY: [ @metaDependencies@ ],
			MAVEN_REPO_PROPERTY: "@metaMavenRepo@",
			POD_PROPERTY: "@metaPod@",
			POD_VERSION_PROPERTY: "@metaPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @metaSkAdNetworkIds@ ]
		},
	Flag.MINTEGRAL: {
			FLAG_PROPERTY: Flag.MINTEGRAL,
			TAG_PROPERTY: "mintegral",
			DEPENDENCIES_PROPERTY: [ @mintegralDependencies@ ],
			MAVEN_REPO_PROPERTY: "@mintegralMavenRepo@",
			POD_PROPERTY: "@mintegralPod@",
			POD_VERSION_PROPERTY: "@mintegralPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @mintegralSkAdNetworkIds@ ]
		},
	Flag.MOLOCO: {
			FLAG_PROPERTY: Flag.MOLOCO,
			TAG_PROPERTY: "moloco",
			DEPENDENCIES_PROPERTY: [ @molocoDependencies@ ],
			MAVEN_REPO_PROPERTY: "@molocoMavenRepo@",
			POD_PROPERTY: "@molocoPod@",
			POD_VERSION_PROPERTY: "@molocoPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @molocoSkAdNetworkIds@ ]
		},
	Flag.MYTARGET: {
			FLAG_PROPERTY: Flag.MYTARGET,
			TAG_PROPERTY: "mytarget",
			DEPENDENCIES_PROPERTY: [ @mytargetDependencies@ ],
			MAVEN_REPO_PROPERTY: "@mytargetMavenRepo@",
			POD_PROPERTY: "@mytargetPod@",
			POD_VERSION_PROPERTY: "@mytargetPodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @mytargetSkAdNetworkIds@ ]
		},
	Flag.PANGLE: {
			FLAG_PROPERTY: Flag.PANGLE,
			TAG_PROPERTY: "pangle",
			DEPENDENCIES_PROPERTY: [ @pangleDependencies@ ],
			MAVEN_REPO_PROPERTY: "@pangleMavenRepo@",
			POD_PROPERTY: "@panglePod@",
			POD_VERSION_PROPERTY: "@panglePodVersion@",
			SK_AD_NETWORK_IDS_PROPERTY: [ @pangleSkAdNetworkIds@ ]
		},
	Flag.UNITY: {
			FLAG_PROPERTY: Flag.UNITY,
			TAG_PROPERTY: "unity",
			DEPENDENCIES_PROPERTY: [ @unityDependencies@ ],
			MAVEN_REPO_PROPERTY: "@unityMavenRepo@",
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
var android_dependencies: Array
var android_custom_maven_repo: String
var ios_pod: String
var ios_pod_version: String
var sk_ad_network_ids: PackedStringArray


func _init(a_data: Dictionary) -> void:
	flag = a_data[FLAG_PROPERTY]
	tag = a_data[TAG_PROPERTY]
	android_dependencies = a_data[DEPENDENCIES_PROPERTY]
	android_custom_maven_repo = a_data[MAVEN_REPO_PROPERTY]
	ios_pod = a_data[POD_PROPERTY]
	ios_pod_version = a_data[POD_VERSION_PROPERTY]
	sk_ad_network_ids = a_data[SK_AD_NETWORK_IDS_PROPERTY]


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

	var __unique_sk_network_ad_ids: Dictionary = {}

	# Add Google-required SK Ad Network IDs
	for __network_id in GOOGLE_SK_AD_NETWORK_IDS:
		if not __unique_sk_network_ad_ids.has(__network_id):
			__unique_sk_network_ad_ids.set(__network_id, null)

	# Add SK Ad Network IDs required by other networks
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
