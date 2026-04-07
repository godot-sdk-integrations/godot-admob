//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.when;

import android.content.ContentResolver;
import android.app.Activity;
import android.provider.Settings;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Tests for {@link GodotConverter#getAdMobDeviceId(Activity)}.
 *
 * <p>The method reads {@link Settings.Secure#ANDROID_ID} via the Activity's
 * ContentResolver and returns its MD5 hash in uppercase hex. We mock the static
 * {@link Settings.Secure#getString} call so tests run on the local JVM without
 * Robolectric or a real device.
 */
@ExtendWith(MockitoExtension.class)
public class GodotConverterDeviceIdTest {

	private Activity activity;
	private ContentResolver contentResolver;

	@BeforeEach
	void setUp() {
		contentResolver = mock(ContentResolver.class);
		activity = mock(Activity.class);
		when(activity.getContentResolver()).thenReturn(contentResolver);
	}

	// -- result format ---------------------------------------------------------

	@Test
	void getAdMobDeviceId_result_isExactly32Characters() {
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("any_device_id");

			String result = GodotConverter.getAdMobDeviceId(activity);

			assertEquals(32, result.length());
		}
	}

	@Test
	void getAdMobDeviceId_result_isUppercaseHex() {
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("any_device_id");

			String result = GodotConverter.getAdMobDeviceId(activity);

			assertNotNull(result);
			assertTrue(result.matches("[0-9A-F]{32}"),
					"Expected uppercase hex, got: " + result);
		}
	}

	@Test
	void getAdMobDeviceId_result_isNotNull() {
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("some_id");

			assertNotNull(GodotConverter.getAdMobDeviceId(activity));
		}
	}

	// -- known MD5 values ------------------------------------------------------

	@Test
	void getAdMobDeviceId_knownInput_abc_returnsKnownMd5() {
		// MD5("abc") = 900150983cd24fb0d6963f7d28e17f72 -> uppercase
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("abc");

			assertEquals("900150983CD24FB0D6963F7D28E17F72",
					GodotConverter.getAdMobDeviceId(activity));
		}
	}

	@Test
	void getAdMobDeviceId_emptyAndroidId_returnsMd5OfEmpty() {
		// MD5("") = d41d8cd98f00b204e9800998ecf8427e -> uppercase
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("");

			assertEquals("D41D8CD98F00B204E9800998ECF8427E",
					GodotConverter.getAdMobDeviceId(activity));
		}
	}

	@Test
	void getAdMobDeviceId_knownInput_test123_returnsKnownMd5() {
		// MD5("test123") = cc03e747a6afbbcbf8be7668acfebee5 -> uppercase
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("test123");

			assertEquals("CC03E747A6AFBBCBF8BE7668ACFEBEE5",
					GodotConverter.getAdMobDeviceId(activity));
		}
	}

	// -- determinism -----------------------------------------------------------

	@Test
	void getAdMobDeviceId_calledTwiceWithSameInput_returnsSameResult() {
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("stable_id");

			String first = GodotConverter.getAdMobDeviceId(activity);
			String second = GodotConverter.getAdMobDeviceId(activity);

			assertEquals(first, second);
		}
	}

	@Test
	void getAdMobDeviceId_differentInputs_produceDifferentOutputs() {
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("device_a");
			String resultA = GodotConverter.getAdMobDeviceId(activity);

			secureMock.when(() -> Settings.Secure.getString(eq(contentResolver), any()))
					.thenReturn("device_b");
			String resultB = GodotConverter.getAdMobDeviceId(activity);

			assertNotEquals(resultA, resultB);
		}
	}

	// -- reads ANDROID_ID specifically ----------------------------------------

	@Test
	void getAdMobDeviceId_queriesAndroidIdKey() {
		try (MockedStatic<Settings.Secure> secureMock = mockStatic(Settings.Secure.class)) {
			secureMock.when(() -> Settings.Secure.getString(
					eq(contentResolver), eq(Settings.Secure.ANDROID_ID)))
					.thenReturn("precise_id_match");
			// If the code reads a different key, getString returns null and md5(null)
			// would throw, causing the test to fail.
			String result = GodotConverter.getAdMobDeviceId(activity);

			assertNotNull(result);
			assertEquals(32, result.length());
		}
	}
}
