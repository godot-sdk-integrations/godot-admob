//
// © 2026-present https://github.com/cengiz-pz
//

import kotlinx.serialization.Serializable

/**
 * Represents a single Swift Package Manager dependency entry decoded from
 * `ios/config/spm_dependencies.json`.
 *
 * JSON shape:
 * ```json
 * {
 *   "url": "https://github.com/owner/repo",
 *   "version": "1.2.3",
 *   "products": ["ProductOne", "ProductTwo"]
 * }
 * ```
 *
 * @property url     Git repository URL of the Swift package.
 * @property version Minimum version (passed to `spm_manager.rb` as the package requirement).
 * @property products List of SPM product names to link against.
 */
@Serializable
data class SpmDependency(
    val url: String,
    val version: String,
    val products: List<String>,
)
