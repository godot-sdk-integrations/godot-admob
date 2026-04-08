//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.ump.FormError;

import org.godotengine.godot.Dictionary;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Unit tests for {@link GodotConverter}.
 *
 * <p>{@link GodotConverter#getAdMobDeviceId} requires an Android {@link android.app.Activity}
 * and a real {@link android.provider.Settings.Secure} provider; that method is covered by
 * the instrumented test suite. All other public methods are tested here with Mockito stubs
 * for GMS/UMP types.
 */
@ExtendWith(MockitoExtension.class)
public class GodotConverterTest {

	// -- convert(FormError) – null path ----------------------------------------

	@Test
	public void convert_nullFormError_returnsZeroCode() {
		Dictionary result = GodotConverter.convert((FormError) null);
		assertEquals(0, result.get("code"));
	}

	@Test
	public void convert_nullFormError_returnsEmptyMessage() {
		Dictionary result = GodotConverter.convert((FormError) null);
		assertEquals("", result.get("message"));
	}

	@Test
	public void convert_nullFormError_dictionaryHasExactlyTwoKeys() {
		Dictionary result = GodotConverter.convert((FormError) null);
		assertEquals(2, result.size());
	}

	// -- convert(FormError) – non-null path -----------------------------------

	@Test
	public void convert_formError_codeMatchesGetErrorCode() {
		FormError error = mock(FormError.class);
		when(error.getErrorCode()).thenReturn(5);
		when(error.getMessage()).thenReturn("Network error");

		Dictionary result = GodotConverter.convert(error);

		assertEquals(5, result.get("code"));
	}

	@Test
	public void convert_formError_messageMatchesGetMessage() {
		FormError error = mock(FormError.class);
		when(error.getErrorCode()).thenReturn(3);
		when(error.getMessage()).thenReturn("Consent form unavailable");

		Dictionary result = GodotConverter.convert(error);

		assertEquals("Consent form unavailable", result.get("message"));
	}

	@Test
	public void convert_formError_zeroCodeAndEmptyMessage() {
		FormError error = mock(FormError.class);
		when(error.getErrorCode()).thenReturn(0);
		when(error.getMessage()).thenReturn("");

		Dictionary result = GodotConverter.convert(error);

		assertEquals(0, result.get("code"));
		assertEquals("", result.get("message"));
	}

	@Test
	public void convert_formError_dictionaryHasExactlyTwoKeys() {
		FormError error = mock(FormError.class);
		when(error.getErrorCode()).thenReturn(1);
		when(error.getMessage()).thenReturn("msg");

		Dictionary result = GodotConverter.convert(error);

		assertEquals(2, result.size());
	}

	// -- convert(RewardItem) ---------------------------------------------------

	@Test
	public void convert_rewardItem_amountMatchesGetAmount() {
		RewardItem item = mock(RewardItem.class);
		when(item.getAmount()).thenReturn(100);
		when(item.getType()).thenReturn("coins");

		Dictionary result = GodotConverter.convert(item);

		assertEquals(100, result.get("amount"));
	}

	@Test
	public void convert_rewardItem_typeMatchesGetType() {
		RewardItem item = mock(RewardItem.class);
		when(item.getAmount()).thenReturn(50);
		when(item.getType()).thenReturn("gems");

		Dictionary result = GodotConverter.convert(item);

		assertEquals("gems", result.get("type"));
	}

	@Test
	public void convert_rewardItem_dictionaryHasExactlyTwoKeys() {
		RewardItem item = mock(RewardItem.class);
		when(item.getAmount()).thenReturn(1);
		when(item.getType()).thenReturn("star");

		Dictionary result = GodotConverter.convert(item);

		assertEquals(2, result.size());
	}

	@Test
	public void convert_rewardItem_zeroAmountEmptyType() {
		RewardItem item = mock(RewardItem.class);
		when(item.getAmount()).thenReturn(0);
		when(item.getType()).thenReturn("");

		Dictionary result = GodotConverter.convert(item);

		assertEquals(0, result.get("amount"));
		assertEquals("", result.get("type"));
	}

	@Test
	public void convert_rewardItem_largeAmount() {
		RewardItem item = mock(RewardItem.class);
		when(item.getAmount()).thenReturn(Integer.MAX_VALUE);
		when(item.getType()).thenReturn("XP");

		Dictionary result = GodotConverter.convert(item);

		assertEquals(Integer.MAX_VALUE, result.get("amount"));
	}

	// -- return type guarantees ------------------------------------------------

	@Test
	public void convert_formError_returnsNonNullDictionary() {
		assertNotNull(GodotConverter.convert((FormError) null));
	}

	@Test
	public void convert_rewardItem_returnsNonNullDictionary() {
		RewardItem item = mock(RewardItem.class);
		when(item.getAmount()).thenReturn(1);
		when(item.getType()).thenReturn("gold");
		assertNotNull(GodotConverter.convert(item));
	}

	// -- key names are stable --------------------------------------------------

	@Test
	public void convert_formError_containsCodeKey() {
		Dictionary result = GodotConverter.convert((FormError) null);
		assertTrue(result.containsKey("code"));
	}

	@Test
	public void convert_formError_containsMessageKey() {
		Dictionary result = GodotConverter.convert((FormError) null);
		assertTrue(result.containsKey("message"));
	}

	@Test
	public void convert_rewardItem_containsAmountKey() {
		RewardItem item = mock(RewardItem.class);
		when(item.getAmount()).thenReturn(1);
		when(item.getType()).thenReturn("g");
		assertTrue(GodotConverter.convert(item).containsKey("amount"));
	}

	@Test
	public void convert_rewardItem_containsTypeKey() {
		RewardItem item = mock(RewardItem.class);
		when(item.getAmount()).thenReturn(1);
		when(item.getType()).thenReturn("g");
		assertTrue(GodotConverter.convert(item).containsKey("type"));
	}
}
