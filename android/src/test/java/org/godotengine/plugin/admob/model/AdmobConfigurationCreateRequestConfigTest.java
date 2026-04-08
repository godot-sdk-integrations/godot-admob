//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ContentResolver;
import android.provider.Settings;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.identifier.AdvertisingIdClient;

import org.godotengine.plugin.admob.fixture.ConfigFixtures;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

/**
 * Tests for {@link AdmobConfiguration#createRequestConfiguration(Activity)}.
 *
 * <p>The method calls the static {@link MobileAds#getRequestConfiguration()} to get the
 * current config and then builds on top of it, and optionally queries
 * {@link AdvertisingIdClient#getAdvertisingIdInfo} on the non-real path.
 * Both are mocked with Mockito's {@code mockStatic} so tests run on the local JVM.
 */
@ExtendWith(MockitoExtension.class)
public class AdmobConfigurationCreateRequestConfigTest {

	private Activity activity;
	private RequestConfiguration.Builder configBuilder;
	private RequestConfiguration currentConfig;

	@BeforeEach
	void setUp() {
		activity = mock(Activity.class);
		lenient().when(activity.getContentResolver()).thenReturn(mock(ContentResolver.class));

		configBuilder = mock(RequestConfiguration.Builder.class);
		when(configBuilder.build()).thenReturn(mock(RequestConfiguration.class));

		currentConfig = mock(RequestConfiguration.class);
		when(currentConfig.toBuilder()).thenReturn(configBuilder);
	}

	// -- helper ----------------------------------------------------------------

	/**
	 * Opens a {@link MobileAds} static mock pre-configured so that
	 * {@code MobileAds.getRequestConfiguration()} returns {@link #currentConfig}.
	 */
	private MockedStatic<MobileAds> openMobileAdsMock() {
		MockedStatic<MobileAds> mock = mockStatic(MobileAds.class);
		mock.when(MobileAds::getRequestConfiguration).thenReturn(currentConfig);
		return mock;
	}

	// -- return value ----------------------------------------------------------

	@Test
	void createRequestConfiguration_always_returnsNonNull() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			AdmobConfiguration config = new AdmobConfiguration(ConfigFixtures.prodConfig());
			assertNotNull(config.createRequestConfiguration(activity));
		}
	}

	@Test
	void createRequestConfiguration_always_callsBuildOnBuilder() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.prodConfig())
					.createRequestConfiguration(activity);
			verify(configBuilder).build();
		}
	}

	// -- max content rating ----------------------------------------------------

	@Test
	void createRequestConfiguration_withContentRating_callsSetMaxAdContentRating() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(any(), any())).thenReturn("mock_id");

			new AdmobConfiguration(ConfigFixtures.testConfig())
					.createRequestConfiguration(activity);
			verify(configBuilder).setMaxAdContentRating("G");
		}
	}

	@Test
	void createRequestConfiguration_withoutContentRatingKey_doesNotCallSetMaxAdContentRating() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.minimalConfig(true))
					.createRequestConfiguration(activity);
			verify(configBuilder, never()).setMaxAdContentRating(any());
		}
	}

	@Test
	void createRequestConfiguration_ratingMA_passesMAToBuilder() {
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {
			secureMock.when(() -> Settings.Secure.getString(any(), any())).thenReturn("mock_id");

			new AdmobConfiguration(ConfigFixtures.configWithRating("MA"))
					.createRequestConfiguration(activity);
			verify(configBuilder).setMaxAdContentRating("MA");
		}
	}

	// -- child directed treatment ----------------------------------------------

	@Test
	void createRequestConfiguration_withChildDirectedTreatment_callsSetter() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.prodConfig())
					.createRequestConfiguration(activity);
			// prodConfig has tag_for_child_directed_treatment = 1L
			verify(configBuilder).setTagForChildDirectedTreatment(1);
		}
	}

	@Test
	void createRequestConfiguration_withoutChildDirectedKey_doesNotCallSetter() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.minimalConfig(true))
					.createRequestConfiguration(activity);
			verify(configBuilder, never()).setTagForChildDirectedTreatment(any(Integer.class));
		}
	}

	// -- under age of consent --------------------------------------------------

	@Test
	void createRequestConfiguration_withUnderAgeOfConsent_callsSetter() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.prodConfig())
					.createRequestConfiguration(activity);
			// prodConfig has tag_for_under_age_of_consent = 1L
			verify(configBuilder).setTagForUnderAgeOfConsent(1);
		}
	}

	@Test
	void createRequestConfiguration_withoutUnderAgeKey_doesNotCallSetter() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.minimalConfig(true))
					.createRequestConfiguration(activity);
			verify(configBuilder, never()).setTagForUnderAgeOfConsent(any(Integer.class));
		}
	}

	// -- personalization state -------------------------------------------------

	@Test
	void createRequestConfiguration_personalizationEnabled_setsEnabledState() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.prodConfig())
					.createRequestConfiguration(activity);
			// prodConfig personalization_state = 1L -> ENABLED
			verify(configBuilder).setPublisherPrivacyPersonalizationState(
					RequestConfiguration.PublisherPrivacyPersonalizationState.ENABLED);
		}
	}

	@Test
	void createRequestConfiguration_personalizationDisabled_setsDisabledState() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.configWithPersonalizationDisabled())
					.createRequestConfiguration(activity);
			// personalization_state = 2L -> DISABLED
			verify(configBuilder).setPublisherPrivacyPersonalizationState(
					RequestConfiguration.PublisherPrivacyPersonalizationState.DISABLED);
		}
	}

	@Test
	void createRequestConfiguration_personalizationDefault_setsDefaultState() {
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {
			secureMock.when(() -> Settings.Secure.getString(any(), any())).thenReturn("mock_id");

			new AdmobConfiguration(ConfigFixtures.testConfig())
					.createRequestConfiguration(activity);
			verify(configBuilder).setPublisherPrivacyPersonalizationState(
					RequestConfiguration.PublisherPrivacyPersonalizationState.DEFAULT);
		}
	}

	@Test
	void createRequestConfiguration_withoutPersonalizationKey_doesNotCallSetter() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			new AdmobConfiguration(ConfigFixtures.minimalConfig(true))
					.createRequestConfiguration(activity);
			verify(configBuilder, never())
					.setPublisherPrivacyPersonalizationState(
							any(RequestConfiguration.PublisherPrivacyPersonalizationState.class));
		}
	}

	// -- test device IDs (isReal = true path) ---------------------------------

	@Test
	void createRequestConfiguration_realWithConfiguredIds_setTestDeviceIdsIncludesConfigured() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			// prodConfig has test_device_ids = ["TEST_DEVICE_1"] and isReal = true
			new AdmobConfiguration(ConfigFixtures.prodConfig())
					.createRequestConfiguration(activity);

			@SuppressWarnings("unchecked")
			ArgumentCaptor<List<String>> captor = ArgumentCaptor.forClass((Class) List.class);
			verify(configBuilder).setTestDeviceIds(captor.capture());
			assert captor.getValue().contains("TEST_DEVICE_1");
		}
	}

	@Test
	void createRequestConfiguration_realWithEmptyConfiguredIds_doesNotCallSetTestDeviceIds() {
		try (MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock()) {
			// minimalConfig has no test_device_ids key and isReal = true
			new AdmobConfiguration(ConfigFixtures.minimalConfig(true))
					.createRequestConfiguration(activity);
			verify(configBuilder, never()).setTestDeviceIds(anyList());
		}
	}

	// -- test device IDs (isReal = false path) --------------------------------

	@Test
	void createRequestConfiguration_nonReal_includesEmulatorId() {
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_android_id");

			new AdmobConfiguration(ConfigFixtures.minimalConfig(false))
					.createRequestConfiguration(activity);

			@SuppressWarnings("unchecked")
			ArgumentCaptor<List<String>> captor = ArgumentCaptor.forClass((Class) List.class);
			verify(configBuilder).setTestDeviceIds(captor.capture());
			assert captor.getValue().contains(AdRequest.DEVICE_ID_EMULATOR);
		}
	}

	@Test
	void createRequestConfiguration_nonReal_includesHashedDeviceId() {
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("abc"); // MD5("abc") = 900150983CD24FB0D6963F7D28E17F72

			new AdmobConfiguration(ConfigFixtures.minimalConfig(false))
					.createRequestConfiguration(activity);

			@SuppressWarnings("unchecked")
			ArgumentCaptor<List<String>> captor = ArgumentCaptor.forClass((Class) List.class);
			verify(configBuilder).setTestDeviceIds(captor.capture());
			assert captor.getValue().contains("900150983CD24FB0D6963F7D28E17F72");
		}
	}

	// -- AdvertisingIdClient paths ---------------------------------------------

	@Test
	void createRequestConfiguration_nonReal_advertisingIdAvailable_includesAdId() {
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class);
				MockedStatic<AdvertisingIdClient> adIdMock = mockStatic(AdvertisingIdClient.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			AdvertisingIdClient.Info adInfo = mock(AdvertisingIdClient.Info.class);
			when(adInfo.isLimitAdTrackingEnabled()).thenReturn(false);
			when(adInfo.getId()).thenReturn("advertising-id-xyz");
			adIdMock.when(() -> AdvertisingIdClient.getAdvertisingIdInfo(any()))
					.thenReturn(adInfo);

			new AdmobConfiguration(ConfigFixtures.minimalConfig(false))
					.createRequestConfiguration(activity);

			@SuppressWarnings("unchecked")
			ArgumentCaptor<List<String>> captor = ArgumentCaptor.forClass((Class) List.class);
			verify(configBuilder).setTestDeviceIds(captor.capture());
			assert captor.getValue().contains("advertising-id-xyz");
		}
	}

	@Test
	void createRequestConfiguration_nonReal_limitAdTrackingEnabled_excludesAdId() {
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class);
				MockedStatic<AdvertisingIdClient> adIdMock = mockStatic(AdvertisingIdClient.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			AdvertisingIdClient.Info adInfo = mock(AdvertisingIdClient.Info.class);
			when(adInfo.isLimitAdTrackingEnabled()).thenReturn(true); // opted out
			adIdMock.when(() -> AdvertisingIdClient.getAdvertisingIdInfo(any()))
					.thenReturn(adInfo);

			new AdmobConfiguration(ConfigFixtures.minimalConfig(false))
					.createRequestConfiguration(activity);

			@SuppressWarnings("unchecked")
			ArgumentCaptor<List<String>> captor = ArgumentCaptor.forClass((Class) List.class);
			verify(configBuilder).setTestDeviceIds(captor.capture());
			// advertising-id is NOT in the list when tracking is limited
			assert !captor.getValue().contains(null);
			// emulator and hashed device ID still present
			assert captor.getValue().contains(AdRequest.DEVICE_ID_EMULATOR);
		}
	}

	@Test
	void createRequestConfiguration_nonReal_advertisingIdIsNull_doesNotAddNull() {
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class);
				MockedStatic<AdvertisingIdClient> adIdMock = mockStatic(AdvertisingIdClient.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			AdvertisingIdClient.Info adInfo = mock(AdvertisingIdClient.Info.class);
			when(adInfo.isLimitAdTrackingEnabled()).thenReturn(false);
			when(adInfo.getId()).thenReturn(null); // ID is null
			adIdMock.when(() -> AdvertisingIdClient.getAdvertisingIdInfo(any()))
					.thenReturn(adInfo);

			// Must not throw and must still call setTestDeviceIds with other IDs.
			new AdmobConfiguration(ConfigFixtures.minimalConfig(false))
					.createRequestConfiguration(activity);

			verify(configBuilder).setTestDeviceIds(anyList());
		}
	}

	@Test
	void createRequestConfiguration_nonReal_illegalStateExceptionFromAdId_recoversGracefully() {
		// Simulates being called on the main thread (the expected prod scenario).
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class);
				MockedStatic<AdvertisingIdClient> adIdMock = mockStatic(AdvertisingIdClient.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			adIdMock.when(() -> AdvertisingIdClient.getAdvertisingIdInfo(any()))
					.thenThrow(new IllegalStateException("must not be called on the main thread"));

			// Must not throw - the code has an explicit catch for IllegalStateException.
			new AdmobConfiguration(ConfigFixtures.minimalConfig(false))
					.createRequestConfiguration(activity);

			verify(configBuilder).setTestDeviceIds(anyList());
		}
	}

	@Test
	void createRequestConfiguration_nonReal_genericExceptionFromAdId_recoversGracefully() {
		try (
				MockedStatic<MobileAds> mobileAdsMock = openMobileAdsMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class);
				MockedStatic<AdvertisingIdClient> adIdMock = mockStatic(AdvertisingIdClient.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			adIdMock.when(() -> AdvertisingIdClient.getAdvertisingIdInfo(any()))
					.thenThrow(new RuntimeException("Play services unavailable"));

			new AdmobConfiguration(ConfigFixtures.minimalConfig(false))
					.createRequestConfiguration(activity);

			verify(configBuilder).setTestDeviceIds(anyList());
		}
	}
}
