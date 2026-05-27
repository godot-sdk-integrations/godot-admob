---
title: Native Ads
icon: fontawesome/solid/newspaper
---

# <img src="../images/icon.png" width="20"> Native Ads

Native ads are ads that match the look, feel, and function of the media format in which they appear. Unlike banner or interstitial ads, native ads are rendered by the platform's native UI layer and positioned by binding them to a Godot `Control` node. The plugin keeps the native ad view in sync with the control's position, size, and visibility every frame.

## <img src="../images/icon.png" width="18"> Loading and Displaying

Load a native ad with `load_native_ad()`, wait for the `native_ad_loaded` signal, then call `show_native_ad()` and attach the ad to a `Control` node so the plugin knows where to render it.

```gdscript
func _ready() -> void:
    $Admob.native_ad_loaded.connect(_on_native_ad_loaded)
    $Admob.native_ad_failed_to_load.connect(_on_native_ad_failed_to_load)
    $Admob.load_native_ad()

func _on_native_ad_loaded(ad_info: AdInfo, _response_info: ResponseInfo) -> void:
    $Admob.show_native_ad(ad_info.get_ad_id())
    $Admob.attach_native_ad_to_control(ad_info.get_ad_id(), $NativeAdContainer)

func _on_native_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
    print("Native ad failed to load: ", error_data)
```

!!! note
    `$NativeAdContainer` should be a `Control` node whose rect defines where the native ad is rendered on screen. The plugin scales and repositions the native view every `_process` frame to match the control's global transform.

## <img src="../images/icon.png" width="18"> Control Binding

Native ads are positioned by attaching them to a `Control` node. The plugin maps the control's canvas rect to window coordinates each frame, accounting for viewport scaling, and calls the platform's `update_native_ad_layout` accordingly.

- **`attach_native_ad_to_control(ad_id: String, control: Control)`** — Binds the native ad view to a control. If the ad was already attached to another control, it is re-attached.
- **`detach_native_ad(ad_id: String)`** — Removes the binding. The ad view will stop updating its position. Called automatically by `remove_native_ad()`.

!!! note
    If the bound `Control` node is freed, the plugin detects it on the next frame and detaches the ad automatically.

## <img src="../images/icon.png" width="18"> Showing and Hiding

Use `show_native_ad()` and `hide_native_ad()` to toggle the visibility of a loaded native ad without unloading it. Both methods accept an optional `ad_id`; if omitted, the most recently loaded ad is used.

```gdscript
# Show the most recently loaded native ad
$Admob.show_native_ad()

# Hide a specific native ad
$Admob.hide_native_ad(ad_info.get_ad_id())
```

## <img src="../images/icon.png" width="18"> Removing

Call `remove_native_ad()` to unload a native ad and free its resources. This also automatically detaches the ad from its bound control.

```gdscript
$Admob.remove_native_ad(ad_info.get_ad_id())
```

The `max_native_ad_cache` property (default `10`) controls how many native ads can be held in the cache before older ones are evicted.

## <img src="../images/icon.png" width="18"> Native Ad Options

Native ad behaviour can be customised via `LoadAdRequest` before calling `load_native_ad()`. These options are ignored for other ad types.

```gdscript
var request: LoadAdRequest = $Admob.create_native_ad_request()
request.set_native_media_aspect_ratio(LoadAdRequest.NativeMediaAspectRatio.LANDSCAPE)
request.set_native_ad_choices_placement(LoadAdRequest.NativeAdChoicesPlacement.TOP_RIGHT)
request.set_native_image_scale_type(LoadAdRequest.NativeImageScaleType.CENTER_CROP)
$Admob.load_native_ad(request)
```

### Media Aspect Ratio

Controls which aspect ratios the SDK should prefer when requesting native ad media (`NativeMediaAspectRatio` enum):

| Value | Description |
|-------|-------------|
| `UNKNOWN` | No preference — SDK default. |
| `ANY` | Any aspect ratio is acceptable. |
| `LANDSCAPE` | Prefer landscape (wider than tall) media. |
| `PORTRAIT` | Prefer portrait (taller than wide) media. |
| `SQUARE` | Prefer square (1:1) media. |

### AdChoices Placement

Controls where the AdChoices icon appears within the native ad view (`NativeAdChoicesPlacement` enum):

| Value | Description |
|-------|-------------|
| `TOP_LEFT` | Top-left corner. |
| `TOP_RIGHT` | Top-right corner — SDK default. |
| `BOTTOM_RIGHT` | Bottom-right corner. |
| `BOTTOM_LEFT` | Bottom-left corner. |

### Image Scale Type

Controls how icon and image assets are scaled inside their native `ImageView` (`NativeImageScaleType` enum). Only applies on Android.

| Value | Description |
|-------|-------------|
| `MATRIX` | Scale using the image matrix. |
| `FIT_XY` | Scale to fill bounds, ignoring aspect ratio. |
| `FIT_START` | Scale to fit within bounds, aligned top-left. |
| `FIT_CENTER` | Scale to fit within bounds, centred — Android default. |
| `FIT_END` | Scale to fit within bounds, aligned bottom-right. |
| `CENTER` | Centre image without scaling. |
| `CENTER_CROP` | Scale so the shorter dimension fits; crop the longer one. |
| `CENTER_INSIDE` | Scale to fit within bounds if larger; centre otherwise. |

### Other Options

- **`set_native_return_urls_for_image_assets(true)`** — The SDK returns image asset URLs instead of pre-fetched drawables, letting you download and manage images yourself.
- **`set_native_request_multiple_images(true)`** — The SDK may return multiple images for a single asset slot. By default only one image per slot is returned.
- **`set_native_disable_validator(true)`** — Suppresses SDK validator warnings about missing view bindings. Useful in test or custom-layout scenarios.

## <img src="../images/icon.png" width="18"> Signals

| Signal | Description |
|--------|-------------|
| `native_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)` | Emitted when a native ad has loaded successfully. |
| `native_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)` | Emitted when a native ad fails to load. |
| `native_ad_impression(ad_info: AdInfo)` | Emitted when a native ad records an impression. |
| `native_ad_size_measured(ad_info: AdInfo)` | Emitted when the native ad's size has been measured. |
| `native_ad_clicked(ad_info: AdInfo)` | Emitted when the user clicks the native ad. |
| `native_ad_swipe_gesture_clicked(ad_info: AdInfo)` | Emitted when a swipe gesture on the native ad is registered as a click. |
| `native_ad_opened(ad_info: AdInfo)` | Emitted when the native ad opens an overlay or external browser. |
| `native_ad_closed(ad_info: AdInfo)` | Emitted when the overlay or browser opened by the native ad is closed. |

## <img src="../images/icon.png" width="18"> Demo Ad Unit IDs

Use the following demo IDs during development. They are set as defaults on the `Admob` node when `is_real` is `false`.

| Platform | Demo Ad Unit ID |
|----------|-----------------|
| Android | `ca-app-pub-3940256099942544/2247696110` |
| iOS | `ca-app-pub-3940256099942544/3986624511` |
