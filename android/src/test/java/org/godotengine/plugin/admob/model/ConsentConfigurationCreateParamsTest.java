//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob.model;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ContentResolver;
import android.provider.Settings;

import com.google.android.ump.ConsentDebugSettings;
import com.google.android.ump.ConsentRequestParameters;

import org.godotengine.godot.Dictionary;
import org.godotengine.plugin.admob.fixture.PrivacyFixtures;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.MockedConstruction;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Tests for {@link ConsentConfiguration#createConsentRequestParameters(Activity)}.
 *
 * <p>Both {@link ConsentRequestParameters.Builder} and {@link ConsentDebugSettings.Builder}
 * are instantiated directly inside the method. We intercept their construction with
 * Mockito's {@code mockConstruction} and verify that the correct setter methods are called
 * for every input combination. The non-real path also calls
 * {@link org.godotengine.plugin.admob.GodotConverter#getAdMobDeviceId}, which reads
 * {@link Settings.Secure#ANDROID_ID}; that static call is stubbed so the test stays
 * on the local JVM.
 */
@ExtendWith(MockitoExtension.class)
public class ConsentConfigurationCreateParamsTest {

	private Activity activity;

	@BeforeEach
	void setUp() {
		activity = mock(Activity.class);
		lenient().when(activity.getContentResolver()).thenReturn(mock(ContentResolver.class));
	}

	// -- helper ----------------------------------------------------------------

	/**
	 * Opens a {@link ConsentRequestParameters.Builder} mock with {@code build()} returning
	 * a non-null stub. Use in try-with-resources.
	 */
	private MockedConstruction<ConsentRequestParameters.Builder> openParamsMock() {
		return mockConstruction(ConsentRequestParameters.Builder.class, (mock, ctx) ->
				when(mock.build()).thenReturn(mock(ConsentRequestParameters.class)));
	}

	/**
	 * Opens a {@link ConsentDebugSettings.Builder} mock with {@code build()} returning
	 * a non-null stub. Use in try-with-resources alongside {@link #openParamsMock()}.
	 */
	private MockedConstruction<ConsentDebugSettings.Builder> openDebugMock() {
		return mockConstruction(ConsentDebugSettings.Builder.class, (mock, ctx) ->
				when(mock.build()).thenReturn(mock(ConsentDebugSettings.class)));
	}

	// -- real config (no debug block) ------------------------------------------

	@Test
	void createConsentRequestParameters_realConfig_buildsSuccessfully() {
		try (MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock()) {
			new ConsentConfiguration(PrivacyFixtures.realConsentConfig())
					.createConsentRequestParameters(activity);
			verify(paramsMock.constructed().get(0)).build();
		}
	}

	@Test
	void createConsentRequestParameters_realConfig_doesNotCreateDebugBuilder() {
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock()
		) {

			new ConsentConfiguration(PrivacyFixtures.realConsentConfig())
					.createConsentRequestParameters(activity);

			assert debugMock.constructed().isEmpty();
		}
	}

	@Test
	void createConsentRequestParameters_realConfig_doesNotCallSetConsentDebugSettings() {
		try (MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock()) {
			new ConsentConfiguration(PrivacyFixtures.realConsentConfig())
					.createConsentRequestParameters(activity);
			verify(paramsMock.constructed().get(0), never())
					.setConsentDebugSettings(any());
		}
	}

	// -- no IS_REAL key -> no debug block ---------------------------------------

	@Test
	void createConsentRequestParameters_noIsRealKey_doesNotCreateDebugBuilder() {
		// The guard is: containsKey(IS_REAL_PROPERTY) && !isReal()
		// Without the key, the debug block is skipped even though isReal() defaults to false.
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock()
		) {

			new ConsentConfiguration(new Dictionary())
					.createConsentRequestParameters(activity);

			assert debugMock.constructed().isEmpty();
		}
	}

	// -- under-age of consent --------------------------------------------------

	@Test
	void createConsentRequestParameters_withUnderAgeTrue_callsSetTagForUnderAgeOfConsent() {
		try (MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock()) {
			new ConsentConfiguration(PrivacyFixtures.consentConfigWithUnderAge(true))
					.createConsentRequestParameters(activity);
			verify(paramsMock.constructed().get(0)).setTagForUnderAgeOfConsent(true);
		}
	}

	@Test
	void createConsentRequestParameters_withUnderAgeFalse_callsSetTagForUnderAgeOfConsentFalse() {
		try (MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock()) {
			new ConsentConfiguration(PrivacyFixtures.consentConfigWithUnderAge(false))
					.createConsentRequestParameters(activity);
			verify(paramsMock.constructed().get(0)).setTagForUnderAgeOfConsent(false);
		}
	}

	@Test
	void createConsentRequestParameters_withoutUnderAgeKey_doesNotCallSetter() {
		try (MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock()) {
			new ConsentConfiguration(PrivacyFixtures.realConsentConfig())
					.createConsentRequestParameters(activity);
			verify(paramsMock.constructed().get(0), never())
					.setTagForUnderAgeOfConsent(any(Boolean.class));
		}
	}

	// -- debug config — debug settings builder is created ---------------------

	@Test
	void createConsentRequestParameters_debugConfig_createsDebugSettingsBuilder() {
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			new ConsentConfiguration(PrivacyFixtures.debugConsentConfig(1))
					.createConsentRequestParameters(activity);

			assert !debugMock.constructed().isEmpty();
		}
	}

	@Test
	void createConsentRequestParameters_debugConfig_callsSetConsentDebugSettings() {
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			new ConsentConfiguration(PrivacyFixtures.debugConsentConfig(1))
					.createConsentRequestParameters(activity);

			verify(paramsMock.constructed().get(0)).setConsentDebugSettings(any());
		}
	}

	// -- debug geography -------------------------------------------------------

	@Test
	void createConsentRequestParameters_debugConfigWithGeography_callsSetDebugGeography() {
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			// debugConsentConfig(geography=1) -> EEA debug geography
			new ConsentConfiguration(PrivacyFixtures.debugConsentConfig(1))
					.createConsentRequestParameters(activity);

			verify(debugMock.constructed().get(0)).setDebugGeography(1);
		}
	}

	@Test
	void createConsentRequestParameters_debugConfigWithGeography2_setsCorrectValue() {
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			new ConsentConfiguration(PrivacyFixtures.debugConsentConfig(2))
					.createConsentRequestParameters(activity);

			verify(debugMock.constructed().get(0)).setDebugGeography(2);
		}
	}

	// -- test device hashed IDs ------------------------------------------------

	@Test
	void createConsentRequestParameters_debugConfigWithDeviceIds_addsEachId() {
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			new ConsentConfiguration(
					PrivacyFixtures.debugConsentConfig(1, "DEV_HASH_1", "DEV_HASH_2"))
					.createConsentRequestParameters(activity);

			ConsentDebugSettings.Builder debugBuilder = debugMock.constructed().get(0);
			verify(debugBuilder).addTestDeviceHashedId("DEV_HASH_1");
			verify(debugBuilder).addTestDeviceHashedId("DEV_HASH_2");
		}
	}

	@Test
	void createConsentRequestParameters_debugConfig_alwaysAddsCurrentDeviceHashedId() {
		// The current device's hashed ID (via getAdMobDeviceId) is always appended
		// regardless of whether test device IDs are configured.
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			// MD5("abc") = 900150983CD24FB0D6963F7D28E17F72
			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("abc");

			new ConsentConfiguration(PrivacyFixtures.debugConsentConfig(1))
					.createConsentRequestParameters(activity);

			verify(debugMock.constructed().get(0))
					.addTestDeviceHashedId("900150983CD24FB0D6963F7D28E17F72");
		}
	}

	@Test
	void createConsentRequestParameters_debugConfig_noConfiguredIds_stillAddsCurrentDevice() {
		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("abc");

			// No test_device_hashed_ids key in the dictionary
			new ConsentConfiguration(PrivacyFixtures.debugConsentConfig(1))
					.createConsentRequestParameters(activity);

			// The only addTestDeviceHashedId call is for the current device
			verify(debugMock.constructed().get(0))
					.addTestDeviceHashedId(eq("900150983CD24FB0D6963F7D28E17F72"));
		}
	}

	// -- under-age combined with debug -----------------------------------------

	@Test
	void createConsentRequestParameters_debugConfigWithUnderAge_setsUnderAgeAndCreatesDebugSettings() {
		Dictionary d = new Dictionary();
		d.put("is_real", false);
		d.put("tag_for_under_age_of_consent", true);
		d.put("debug_geography", 1L);

		try (
				MockedConstruction<ConsentRequestParameters.Builder> paramsMock = openParamsMock();
				MockedConstruction<ConsentDebugSettings.Builder> debugMock = openDebugMock();
				MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)
		) {

			secureMock.when(() -> Settings.Secure.getString(any(), any()))
					.thenReturn("mock_id");

			new ConsentConfiguration(d).createConsentRequestParameters(activity);

			verify(paramsMock.constructed().get(0)).setTagForUnderAgeOfConsent(true);
			verify(paramsMock.constructed().get(0)).setConsentDebugSettings(any());
		}
	}
}
