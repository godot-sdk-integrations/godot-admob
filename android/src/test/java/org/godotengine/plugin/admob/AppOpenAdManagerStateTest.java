//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.plugin.admob;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;

import org.godotengine.plugin.admob.fixture.AdRequestFixtures;
import org.godotengine.plugin.admob.model.LoadAdRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Tests the guard-logic state machine in {@link AppOpenAdManager}.
 *
 * <p>Each test creates a fresh manager and a Mockito-mocked {@link Activity}. No real Ad SDK
 * calls are made; we verify that {@link Activity#runOnUiThread} is (or is not) invoked, and
 * that the manager's public state flags transition correctly.
 */
@ExtendWith(MockitoExtension.class)
public class AppOpenAdManagerStateTest {

	private Activity activity;
	private AppOpenListener listener;
	private AppOpenAdManager manager;

	@BeforeEach
	public void setUp() {
		activity = mock(Activity.class);
		listener = mock(AppOpenListener.class);
		manager = new AppOpenAdManager(activity, listener);
	}

	// -- initial state ---------------------------------------------------------

	@Test
	public void isAdAvailable_initially_returnsFalse() {
		assertFalse(manager.isAdAvailable());
	}

	@Test
	public void isLoadingAd_initially_isFalse() {
		assertFalse(manager.isLoadingAd);
	}

	@Test
	public void isShowingAd_initially_isFalse() {
		assertFalse(manager.isShowingAd);
	}

	@Test
	public void autoShowOnResume_initially_isFalse() {
		assertFalse(manager.autoShowOnResume);
	}

	// -- loadAd guards ---------------------------------------------------------

	@Test
	public void loadAd_whenAlreadyLoading_doesNotInvokeRunOnUiThread() {
		manager.isLoadingAd = true;

		manager.loadAd(new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()));

		verify(activity, never()).runOnUiThread(any());
	}

	@Test
	public void loadAd_whenAlreadyLoading_keepsFlagTrue() {
		manager.isLoadingAd = true;

		manager.loadAd(new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()));

		// The guard exits early; flag must still be true (not reset to false by guard body).
		assertTrue(manager.isLoadingAd);
	}

	@Test
	public void loadAd_whenActivityIsNull_doesNotCrash() {
		AppOpenAdManager nullActivityManager = new AppOpenAdManager(null, listener);
		nullActivityManager.loadAd(new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()));
		assertFalse(nullActivityManager.isLoadingAd);
	}

	@Test
	public void loadAd_whenActivityIsNull_isLoadingAdSetFalse() {
		AppOpenAdManager nullActivityManager = new AppOpenAdManager(null, listener);
		nullActivityManager.loadAd(new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()));
		assertFalse(nullActivityManager.isLoadingAd);
	}

	@Test
	public void loadAd_whenActivityIsFinishing_doesNotInvokeRunOnUiThread() {
		when(activity.isFinishing()).thenReturn(true);

		manager.loadAd(new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()));

		verify(activity, never()).runOnUiThread(any());
	}

	@Test
	public void loadAd_whenActivityIsFinishing_isLoadingAdSetFalse() {
		when(activity.isFinishing()).thenReturn(true);

		manager.loadAd(new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()));

		assertFalse(manager.isLoadingAd);
	}

	@Test
	public void loadAd_happyPath_invokesRunOnUiThread() {
		when(activity.isFinishing()).thenReturn(false);

		manager.loadAd(new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()));

		verify(activity).runOnUiThread(any());
	}

	@Test
	public void loadAd_happyPath_setsIsLoadingAdTrue() {
		when(activity.isFinishing()).thenReturn(false);

		manager.loadAd(new LoadAdRequest(AdRequestFixtures.minimalBannerRequest()));

		assertTrue(manager.isLoadingAd);
	}

	// -- showAd guards ---------------------------------------------------------

	@Test
	public void showAd_whenAlreadyShowing_doesNotInvokeRunOnUiThread() {
		manager.isShowingAd = true;

		manager.showAd();

		verify(activity, never()).runOnUiThread(any());
	}

	@Test
	public void showAd_whenAdNotAvailable_doesNotInvokeRunOnUiThread() {
		// isAdAvailable() is false because appOpenAd field is null (fresh manager).
		manager.showAd();

		verify(activity, never()).runOnUiThread(any());
	}

	// -- autoShowOnResume flag -------------------------------------------------

	@Test
	public void autoShowOnResume_canBeSetToTrue() {
		manager.autoShowOnResume = true;
		assertTrue(manager.autoShowOnResume);
	}

	// -- onStart / onStop lifecycle – no crashes -------------------------------

	@Test
	public void onStart_withAutoShowOnResumeFalse_doesNotInvokeRunOnUiThread() {
		manager.autoShowOnResume = false;
		manager.onStart(mock(androidx.lifecycle.LifecycleOwner.class));
		// No runOnUiThread call expected when autoShowOnResume is false.
		verify(activity, never()).runOnUiThread(any());
	}

	@Test
	public void onStop_doesNotThrow() {
		// Smoke-test that the method can be called without crashing.
		manager.onStop(mock(androidx.lifecycle.LifecycleOwner.class));
	}
}
