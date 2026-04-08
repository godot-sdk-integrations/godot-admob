//
// © 2026-present https://github.com/cengiz-pz
//

package org.godotengine.godot;

import java.util.HashMap;

/**
 * Minimal stub that lets unit tests create and interrogate Dictionary instances
 * without the godot-lib AAR being present on the local JVM test classpath.
 */
public class Dictionary extends HashMap<String, Object> {
	public Dictionary() {
		super();
	}
}
