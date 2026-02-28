---
title: Banner ads
---

## <img src="../images/icon.png" width="20"> Banner Ads

Banner ads can be categorized as:

- Adaptive Banner Ads
- Fixed-size Banner Ads
- Collapsible Banner Ads

## <img src="../images/icon.png" width="18"> Banner Position

Banner position can be set to the following values:

- TOP
- BOTTOM
- LEFT
- RIGHT
- TOP-LEFT
- TOP-RIGHT
- BOTTOM-LEFT
- BOTTOM-RIGHT
- CENTER

!!! note
     Use `LoadAdRequest`'s `set_anchor_to_safe_area` method to position banner ads within the device’s safe area, leaving space at the top or bottom to avoid UI elements such as notches, rounded corners, and home indicator bars. When set to `false`, the banner will be anchored directly to the top or bottom edge of the screen, ignoring safe area insets._

## <img src="../images/icon.png" width="18"> Banner Size

- The following methods return the size of a Banner ad:
	- `get_banner_dimension()`
	- `get_banner_dimension_in_pixels()`
- These methods are not supported for `FLUID` sized ads. For banner ads of size `FLUID`, the `get_banner_dimension()` method will return `(-3, -4)` and the `get_banner_dimension_in_pixels()` method will return `(-1, -1)`.

## <img src="../images/icon.png" width="18"> Collapsible Banner Ads

Collapsible banner ads are banner ads that are initially presented as a larger overlay with a button to collapse them to their originally-requested banner size. Collapsible banner ads can be requested by setting the `collapsible position` value to `TOP` or `BOTTOM`.

!!! note
    if `collapsible position` value is in conflict with the [`banner position`](#banner-position) value, then the collapsible banner ad may not function as intended. Set `banner position` and `collapsible position` to the same value for the best experience.