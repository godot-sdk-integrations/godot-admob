//
// © 2026-present https://github.com/cengiz-pz
//

import kotlinx.serialization.Serializable

@Serializable
data class SpmDependency(
    val url: String,
    val version: String,
    val products: List<String>,
)
