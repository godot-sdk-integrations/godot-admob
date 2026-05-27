//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.google.android.gms.ads.nativead.NativeAdOptions;

import org.godotengine.godot.Dictionary;
import org.godotengine.plugin.admob.fixture.AdRequestFixtures;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.MockedConstruction;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Tests for {@link LoadAdRequest#createNativeAdOptions()}.
 *
 * <p>The production method constructs a {@link NativeAdOptions.Builder} internally and calls
 * setter methods only for keys present in the request dictionary. We intercept construction
 * via Mockito's {@code mockConstruction} — the same pattern used in
 * {@link LoadAdRequestCreateAdRequestTest} — and verify that:
 * <ul>
 *   <li>each option setter is called (or not called) depending on which keys are present;</li>
 *   <li>each setter receives the correct SDK constant or boolean value; and</li>
 *   <li>every path completes without throwing.</li>
 * </ul>
 *
 * <p>The GMS Ads library is a real jar on the test classpath, so {@link NativeAdOptions}
 * integer constants have their true values:
 * <ul>
 *   <li>NATIVE_MEDIA_ASPECT_RATIO_UNKNOWN = 0</li>
 *   <li>NATIVE_MEDIA_ASPECT_RATIO_ANY = 1</li>
 *   <li>NATIVE_MEDIA_ASPECT_RATIO_LANDSCAPE = 2</li>
 *   <li>NATIVE_MEDIA_ASPECT_RATIO_PORTRAIT = 3</li>
 *   <li>NATIVE_MEDIA_ASPECT_RATIO_SQUARE = 4</li>
 *   <li>ADCHOICES_TOP_LEFT = 0</li>
 *   <li>ADCHOICES_TOP_RIGHT = 1</li>
 *   <li>ADCHOICES_BOTTOM_RIGHT = 2</li>
 *   <li>ADCHOICES_BOTTOM_LEFT = 3</li>
 * </ul>
 */
@ExtendWith(MockitoExtension.class)
public class LoadAdRequestCreateNativeAdOptionsTest {

	// -- helper ----------------------------------------------------------------

	/**
	 * Opens a {@code mockConstruction} scope that stubs
	 * {@link NativeAdOptions.Builder#build()} to return a non-null {@link NativeAdOptions}.
	 */
	private MockedConstruction<NativeAdOptions.Builder> openBuilderMock() {
		return mockConstruction(NativeAdOptions.Builder.class, (mock, ctx) ->
				when(mock.build()).thenReturn(mock(NativeAdOptions.class)));
	}

	/** Convenience: returns the single captured {@link NativeAdOptions.Builder} mock. */
	private NativeAdOptions.Builder capturedBuilder(MockedConstruction<NativeAdOptions.Builder> mock) {
		return mock.constructed().get(0);
	}

	// -- build() is always called ----------------------------------------------

	@Test
	void createNativeAdOptions_always_returnsNonNull() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalNativeRequest());
			assertNotNull(request.createNativeAdOptions());
		}
	}

	@Test
	void createNativeAdOptions_always_callsBuildOnBuilder() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalNativeRequest()).createNativeAdOptions();
			verify(capturedBuilder(builderMock)).build();
		}
	}

	// -- no options set → no setters called -----------------------------------

	@Test
	void createNativeAdOptions_withNoNativeOptions_doesNotCallSetMediaAspectRatio() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalNativeRequest()).createNativeAdOptions();
			verify(capturedBuilder(builderMock), never()).setMediaAspectRatio(anyInt());
		}
	}

	@Test
	void createNativeAdOptions_withNoNativeOptions_doesNotCallSetReturnUrlsForImageAssets() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalNativeRequest()).createNativeAdOptions();
			verify(capturedBuilder(builderMock), never()).setReturnUrlsForImageAssets(anyBoolean());
		}
	}

	@Test
	void createNativeAdOptions_withNoNativeOptions_doesNotCallSetRequestMultipleImages() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalNativeRequest()).createNativeAdOptions();
			verify(capturedBuilder(builderMock), never()).setRequestMultipleImages(anyBoolean());
		}
	}

	@Test
	void createNativeAdOptions_withNoNativeOptions_doesNotCallSetAdChoicesPlacement() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalNativeRequest()).createNativeAdOptions();
			verify(capturedBuilder(builderMock), never()).setAdChoicesPlacement(anyInt());
		}
	}

	// -- media aspect ratio ----------------------------------------------------

	@Test
	void createNativeAdOptions_withMediaAspectRatioUnknown_callsSetMediaAspectRatioWithZero() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithMediaAspectRatio("UNKNOWN"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_UNKNOWN);
		}
	}

	@Test
	void createNativeAdOptions_withMediaAspectRatioAny_callsSetMediaAspectRatioAny() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithMediaAspectRatio("ANY"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_ANY);
		}
	}

	@Test
	void createNativeAdOptions_withMediaAspectRatioLandscape_callsSetMediaAspectRatioLandscape() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithMediaAspectRatio("LANDSCAPE"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_LANDSCAPE);
		}
	}

	@Test
	void createNativeAdOptions_withMediaAspectRatioPortrait_callsSetMediaAspectRatioPortrait() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithMediaAspectRatio("PORTRAIT"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_PORTRAIT);
		}
	}

	@Test
	void createNativeAdOptions_withMediaAspectRatioSquare_callsSetMediaAspectRatioSquare() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithMediaAspectRatio("SQUARE"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_SQUARE);
		}
	}

	@Test
	void createNativeAdOptions_withUnknownMediaAspectRatioString_fallsBackToUnknownConstant() {
		// The production switch default branch maps unrecognised strings to UNKNOWN (0).
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			Dictionary d = AdRequestFixtures.minimalNativeRequest();
			d.put("native_media_aspect_ratio", "NOT_A_REAL_RATIO");
			new LoadAdRequest(d).createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_UNKNOWN);
		}
	}

	@Test
	void createNativeAdOptions_withoutMediaAspectRatio_doesNotCallSetMediaAspectRatio() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithAdChoicesPlacement("TOP_LEFT"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock), never()).setMediaAspectRatio(anyInt());
		}
	}

	// -- return URLs for image assets ------------------------------------------

	@Test
	void createNativeAdOptions_withReturnUrlsTrue_callsSetReturnUrlsForImageAssetsTrue() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithReturnUrlsForImageAssets(true))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock)).setReturnUrlsForImageAssets(true);
		}
	}

	@Test
	void createNativeAdOptions_withReturnUrlsFalse_callsSetReturnUrlsForImageAssetsFalse() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithReturnUrlsForImageAssets(false))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock)).setReturnUrlsForImageAssets(false);
		}
	}

	@Test
	void createNativeAdOptions_withoutReturnUrls_doesNotCallSetReturnUrlsForImageAssets() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalNativeRequest()).createNativeAdOptions();
			verify(capturedBuilder(builderMock), never()).setReturnUrlsForImageAssets(anyBoolean());
		}
	}

	// -- request multiple images -----------------------------------------------

	@Test
	void createNativeAdOptions_withRequestMultipleImagesTrue_callsSetRequestMultipleImagesTrue() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithRequestMultipleImages(true))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock)).setRequestMultipleImages(true);
		}
	}

	@Test
	void createNativeAdOptions_withRequestMultipleImagesFalse_callsSetRequestMultipleImagesFalse() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithRequestMultipleImages(false))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock)).setRequestMultipleImages(false);
		}
	}

	@Test
	void createNativeAdOptions_withoutRequestMultipleImages_doesNotCallSetRequestMultipleImages() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalNativeRequest()).createNativeAdOptions();
			verify(capturedBuilder(builderMock), never()).setRequestMultipleImages(anyBoolean());
		}
	}

	// -- AdChoices placement ---------------------------------------------------

	@Test
	void createNativeAdOptions_withAdChoicesTopLeft_callsSetAdChoicesPlacementTopLeft() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithAdChoicesPlacement("TOP_LEFT"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setAdChoicesPlacement(NativeAdOptions.ADCHOICES_TOP_LEFT);
		}
	}

	@Test
	void createNativeAdOptions_withAdChoicesTopRight_callsSetAdChoicesPlacementTopRight() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithAdChoicesPlacement("TOP_RIGHT"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setAdChoicesPlacement(NativeAdOptions.ADCHOICES_TOP_RIGHT);
		}
	}

	@Test
	void createNativeAdOptions_withAdChoicesBottomRight_callsSetAdChoicesPlacementBottomRight() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithAdChoicesPlacement("BOTTOM_RIGHT"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setAdChoicesPlacement(NativeAdOptions.ADCHOICES_BOTTOM_RIGHT);
		}
	}

	@Test
	void createNativeAdOptions_withAdChoicesBottomLeft_callsSetAdChoicesPlacementBottomLeft() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithAdChoicesPlacement("BOTTOM_LEFT"))
					.createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setAdChoicesPlacement(NativeAdOptions.ADCHOICES_BOTTOM_LEFT);
		}
	}

	@Test
	void createNativeAdOptions_withUnknownAdChoicesPlacementString_fallsBackToTopRight() {
		// The production switch default branch falls back to ADCHOICES_TOP_RIGHT (the SDK default).
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			Dictionary d = AdRequestFixtures.minimalNativeRequest();
			d.put("native_ad_choices_placement", "CENTRE"); // common misspelling, not a valid key
			new LoadAdRequest(d).createNativeAdOptions();
			verify(capturedBuilder(builderMock))
					.setAdChoicesPlacement(NativeAdOptions.ADCHOICES_TOP_RIGHT);
		}
	}

	@Test
	void createNativeAdOptions_withoutAdChoicesPlacement_doesNotCallSetAdChoicesPlacement() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalNativeRequest()).createNativeAdOptions();
			verify(capturedBuilder(builderMock), never()).setAdChoicesPlacement(anyInt());
		}
	}

	// -- isolation: each option is independent --------------------------------

	@Test
	void createNativeAdOptions_withOnlyReturnUrls_doesNotCallOtherSetters() {
		// Setting one option must not trigger any other setter — options are independent.
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithReturnUrlsForImageAssets(true))
					.createNativeAdOptions();
			NativeAdOptions.Builder builder = capturedBuilder(builderMock);
			verify(builder).setReturnUrlsForImageAssets(true);
			verify(builder, never()).setMediaAspectRatio(anyInt());
			verify(builder, never()).setRequestMultipleImages(anyBoolean());
			verify(builder, never()).setAdChoicesPlacement(anyInt());
		}
	}

	@Test
	void createNativeAdOptions_withOnlyMultipleImages_doesNotCallOtherSetters() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithRequestMultipleImages(true))
					.createNativeAdOptions();
			NativeAdOptions.Builder builder = capturedBuilder(builderMock);
			verify(builder).setRequestMultipleImages(true);
			verify(builder, never()).setMediaAspectRatio(anyInt());
			verify(builder, never()).setReturnUrlsForImageAssets(anyBoolean());
			verify(builder, never()).setAdChoicesPlacement(anyInt());
		}
	}

	@Test
	void createNativeAdOptions_withOnlyAdChoicesPlacement_doesNotCallOtherSetters() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.nativeRequestWithAdChoicesPlacement("BOTTOM_LEFT"))
					.createNativeAdOptions();
			NativeAdOptions.Builder builder = capturedBuilder(builderMock);
			verify(builder).setAdChoicesPlacement(NativeAdOptions.ADCHOICES_BOTTOM_LEFT);
			verify(builder, never()).setMediaAspectRatio(anyInt());
			verify(builder, never()).setReturnUrlsForImageAssets(anyBoolean());
			verify(builder, never()).setRequestMultipleImages(anyBoolean());
		}
	}

	// -- combined: all options set --------------------------------------------

	@Test
	void createNativeAdOptions_withAllOptionsSet_callsAllFourSetters() {
		// fullNativeRequest() sets: LANDSCAPE, returnUrls=true, multipleImages=true, BOTTOM_LEFT.
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.fullNativeRequest()).createNativeAdOptions();

			NativeAdOptions.Builder builder = capturedBuilder(builderMock);
			verify(builder).setMediaAspectRatio(NativeAdOptions.NATIVE_MEDIA_ASPECT_RATIO_LANDSCAPE);
			verify(builder).setReturnUrlsForImageAssets(true);
			verify(builder).setRequestMultipleImages(true);
			verify(builder).setAdChoicesPlacement(NativeAdOptions.ADCHOICES_BOTTOM_LEFT);
			verify(builder).build();
		}
	}

	@Test
	void createNativeAdOptions_withAllOptionsSet_returnsNonNull() {
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			assertNotNull(
					new LoadAdRequest(AdRequestFixtures.fullNativeRequest())
							.createNativeAdOptions());
		}
	}

	// -- banner request carries no native keys --------------------------------

	@Test
	void createNativeAdOptions_onBannerRequest_callsNoSetters() {
		// createNativeAdOptions() is only meaningful for native ads, but it must be safe
		// to call on any request type — banner requests carry no native option keys.
		try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()).createNativeAdOptions();

			NativeAdOptions.Builder builder = capturedBuilder(builderMock);
			verify(builder, never()).setMediaAspectRatio(anyInt());
			verify(builder, never()).setReturnUrlsForImageAssets(anyBoolean());
			verify(builder, never()).setRequestMultipleImages(anyBoolean());
			verify(builder, never()).setAdChoicesPlacement(anyInt());
			verify(builder).build();
		}
	}

	// -- aspect ratio all-values round-trip -----------------------------------

	@Test
	void createNativeAdOptions_allAspectRatioValues_eachCallsSetMediaAspectRatioExactlyOnce() {
		// Each GDScript enum key must resolve to exactly one setMediaAspectRatio() call.
		String[] ratios = {"UNKNOWN", "ANY", "LANDSCAPE", "PORTRAIT", "SQUARE"};
		for (String ratio : ratios) {
			try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
				new LoadAdRequest(
						AdRequestFixtures.nativeRequestWithMediaAspectRatio(ratio))
						.createNativeAdOptions();
				// We don't repeat the exact-value assertions here (covered above);
				// this loop verifies the setter is called exactly once per value.
				verify(capturedBuilder(builderMock)).setMediaAspectRatio(anyInt());
			}
		}
	}

	@Test
	void createNativeAdOptions_allAdChoicesPlacementValues_eachCallsSetAdChoicesPlacementExactlyOnce() {
		String[] placements = {"TOP_LEFT", "TOP_RIGHT", "BOTTOM_RIGHT", "BOTTOM_LEFT"};
		for (String placement : placements) {
			try (MockedConstruction<NativeAdOptions.Builder> builderMock = openBuilderMock()) {
				new LoadAdRequest(
						AdRequestFixtures.nativeRequestWithAdChoicesPlacement(placement))
						.createNativeAdOptions();
				verify(capturedBuilder(builderMock)).setAdChoicesPlacement(anyInt());
			}
		}
	}
}
