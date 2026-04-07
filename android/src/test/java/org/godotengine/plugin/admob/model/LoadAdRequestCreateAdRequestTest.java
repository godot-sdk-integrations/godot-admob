//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.os.Bundle;

import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.AdRequest;

import org.godotengine.godot.Dictionary;
import org.godotengine.plugin.admob.fixture.AdRequestFixtures;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedConstruction;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Tests for {@link LoadAdRequest#createAdRequest()}.
 *
 * <p>The production method creates an {@link AdRequest.Builder} internally and calls various
 * builder methods based on the {@link org.godotengine.godot.Dictionary} it was given.
 * We intercept both {@code AdRequest.Builder} and {@link Bundle} construction via Mockito's
 * {@code mockConstruction}, then verify that each input path calls the correct builder
 * method with the correct arguments.
 */
@ExtendWith(MockitoExtension.class)
public class LoadAdRequestCreateAdRequestTest {

	// -- helper ----------------------------------------------------------------

	/** Opens a mockConstruction scope that stubs builder.build() to return a non-null AdRequest. */
	private MockedConstruction<AdRequest.Builder> openBuilderMock() {
		return mockConstruction(AdRequest.Builder.class, (mock, ctx) ->
				when(mock.build()).thenReturn(mock(AdRequest.class)));
	}

	// -- build() is always called ----------------------------------------------

	@Test
	void createAdRequest_always_returnsNonNull() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			LoadAdRequest request = new LoadAdRequest(AdRequestFixtures.minimalBannerRequest());
			assertNotNull(request.createAdRequest());
		}
	}

	@Test
	void createAdRequest_always_callsBuildOnBuilder() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()).createAdRequest();
			verify(builderMock.constructed().get(0)).build();
		}
	}

	// -- request agent ---------------------------------------------------------

	@Test
	void createAdRequest_withRequestAgent_callsSetRequestAgent() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			Dictionary d = AdRequestFixtures.minimalBannerRequest();
			d.put("request_agent", "godot-admob-plugin");
			new LoadAdRequest(d).createAdRequest();

			verify(builderMock.constructed().get(0)).setRequestAgent("godot-admob-plugin");
		}
	}

	@Test
	void createAdRequest_withEmptyRequestAgent_doesNotCallSetRequestAgent() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			Dictionary d = AdRequestFixtures.minimalBannerRequest();
			d.put("request_agent", "");
			new LoadAdRequest(d).createAdRequest();

			verify(builderMock.constructed().get(0), never()).setRequestAgent(any());
		}
	}

	@Test
	void createAdRequest_withoutRequestAgent_doesNotCallSetRequestAgent() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()).createAdRequest();

			verify(builderMock.constructed().get(0), never()).setRequestAgent(any());
		}
	}

	// -- keywords --------------------------------------------------------------

	@Test
	void createAdRequest_withKeywords_callsAddKeywordForEach() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.requestWithKeywords("game", "puzzle", "casual"))
					.createAdRequest();

			AdRequest.Builder builder = builderMock.constructed().get(0);
			verify(builder).addKeyword("game");
			verify(builder).addKeyword("puzzle");
			verify(builder).addKeyword("casual");
		}
	}

	@Test
	void createAdRequest_withSingleKeyword_callsAddKeywordOnce() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.requestWithKeywords("sports"))
					.createAdRequest();

			verify(builderMock.constructed().get(0), times(1)).addKeyword("sports");
		}
	}

	@Test
	void createAdRequest_withoutKeywords_neverCallsAddKeyword() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()).createAdRequest();

			verify(builderMock.constructed().get(0), never()).addKeyword(any());
		}
	}

	// -- collapsible banner ----------------------------------------------------

	@Test
	void createAdRequest_collapsibleBottom_putsCorrectValueInBundle() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock();
			 MockedConstruction<Bundle> bundleMock = mockConstruction(Bundle.class)) {

			new LoadAdRequest(AdRequestFixtures.collapsibleBannerRequest("BOTTOM"))
					.createAdRequest();

			Bundle capturedBundle = bundleMock.constructed().get(0);
			verify(capturedBundle).putString("collapsible", "BOTTOM");
		}
	}

	@Test
	void createAdRequest_collapsibleBottom_callsAddNetworkExtrasBundleWithAdMobAdapter() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock();
			 MockedConstruction<Bundle> bundleMock = mockConstruction(Bundle.class)) {

			new LoadAdRequest(AdRequestFixtures.collapsibleBannerRequest("BOTTOM"))
					.createAdRequest();

			AdRequest.Builder builder = builderMock.constructed().get(0);
			Bundle capturedBundle = bundleMock.constructed().get(0);
			verify(builder).addNetworkExtrasBundle(eq(AdMobAdapter.class), eq(capturedBundle));
		}
	}

	@Test
	void createAdRequest_collapsibleTop_putsTopValueInBundle() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock();
			 MockedConstruction<Bundle> bundleMock = mockConstruction(Bundle.class)) {

			new LoadAdRequest(AdRequestFixtures.collapsibleBannerRequest("TOP"))
					.createAdRequest();

			verify(bundleMock.constructed().get(0)).putString("collapsible", "TOP");
		}
	}

	@Test
	void createAdRequest_nonCollapsible_neverCallsAddNetworkExtrasBundle() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()).createAdRequest();

			verify(builderMock.constructed().get(0), never())
					.addNetworkExtrasBundle(any(), any());
		}
	}

	// -- network extras --------------------------------------------------------

	@Test
	void createAdRequest_withUnknownNetworkTag_doesNotThrow() {
		// Factory returns null for unknown tags; code logs and skips.
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			Dictionary d = AdRequestFixtures.requestWithNetworkExtras(
					"unknown_network_xyz", "key", "value");
			new LoadAdRequest(d).createAdRequest();
			// Must complete without exception; build() still called.
			verify(builderMock.constructed().get(0)).build();
		}
	}

	@Test
	void createAdRequest_withKnownNetworkTagButMissingAdapterJar_doesNotThrow() {
		// The applovin adapter class is not on the test classpath -> ClassNotFoundException,
		// which the code catches and logs as a warning.
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			Dictionary d = AdRequestFixtures.requestWithNetworkExtras(
					"applovin", "some_param", "some_value");
			new LoadAdRequest(d).createAdRequest();
			verify(builderMock.constructed().get(0)).build();
		}
	}

	@Test
	void createAdRequest_withNetworkExtrasNotAnArray_doesNotThrow() {
		// network_extras must be an Object[]; if it's the wrong type the code logs and skips.
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			Dictionary d = new Dictionary();
			d.put("ad_unit_id", AdRequestFixtures.TEST_AD_UNIT_ID);
			d.put("network_extras", "this is a string, not an array");
			new LoadAdRequest(d).createAdRequest();
			verify(builderMock.constructed().get(0)).build();
		}
	}

	// -- serverside verification options (createAdRequest does NOT set these) --

	@Test
	void createAdRequest_withSsvFields_doesNotThrow() {
		// SSV fields (user_id, custom_data) are handled by createServerSideVerificationOptions(),
		// not by createAdRequest(). The latter should simply ignore them.
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(
					AdRequestFixtures.rewardedRequestWithSsv("user-99", "level=10"))
					.createAdRequest();
			verify(builderMock.constructed().get(0)).build();
		}
	}

	// -- combined --------------------------------------------------------------

	@Test
	void createAdRequest_fullBannerRequest_callsAllRelevantBuilderMethods() {
		try (MockedConstruction<AdRequest.Builder> builderMock = openBuilderMock()) {
			new LoadAdRequest(AdRequestFixtures.fullBannerRequest()).createAdRequest();

			AdRequest.Builder builder = builderMock.constructed().get(0);
			verify(builder).setRequestAgent("godot-admob-plugin");
			verify(builder).addKeyword("game");
			verify(builder).addKeyword("puzzle");
			verify(builder).build();
		}
	}
}
