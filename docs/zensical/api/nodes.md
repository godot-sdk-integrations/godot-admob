---
title: Nodes
---

# <img src="../images/icon.png" width="20"> Nodes

## <img src="../images/icon.png" width="16"> InlıneAdaptiveBanner

`InlıneAdaptiveBanner` is a custom Godot node that provides support for loading and showing AdMob inline adaptive banners. Place it inside a Godot Container node such as the `ScrollContainer` and set its `ad_unit_id` and `custom_minimum_size.x` properties.

**Properties:**

- `ad_unit_id` - Ad unit ID of the inline adaptive banner ad to be loaded.
- `max_ad_height` - Maximum pixel height of the requested ad. If set to -1, height will be determined automatically.
- `clip_threshold` - Minimum portion of the banner’s area (as a percentage) that must be clipped before the banner is considered hidden.
- `resize_threshold` - Width-change threshold (in pixels) that triggers a banner reload when the ad container is resized by this amount or more.
- `admob_path` - Path to `Admob` node. Alternatively, the `initialize()` method can be used to provide a reference to the `Admob` node.

**Methods:**

- `initialize(admob_node)` - An alternative to initializing with the `admob_path` property.