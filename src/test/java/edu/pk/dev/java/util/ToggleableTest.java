package edu.pk.dev.java.util;

import org.junit.Assert;
import org.junit.Test;

/**
 * Created by IntelliJ IDEA.
 * User: prajena
 * Date: 2019-07-16
 * Time: 19:09
 * To change this template use File | Settings | File and Code Templates.
 */

interface Toggleable<T extends Enum<T>> {
	default T toggle() {
		final T[] enumConstants = (T[]) this.getClass().getEnumConstants();
		if (enumConstants == null) {
			throw new UnsupportedOperationException("Only enum can support toggling");
		}
		if (enumConstants.length != 2) {
			throw new UnsupportedOperationException("Enum must have 2 objects to support toggling");
		}
		return enumConstants[0] == this ? enumConstants[1] : enumConstants[0];
	}
}

enum DebitCreditCode implements Toggleable<DebitCreditCode> {
	DEBIT,
	CREDIT
}

class State implements Toggleable {
	public static State OFF = new State();
	public static State ON = new State();
	
}

enum Status implements Toggleable<Status> {
	IN_PROGRESS,
	COMPLETED,
	CANCELLED
}

public class ToggleableTest {
	
	@Test
	public void testDebitCreditCodeToggle() {
		final DebitCreditCode toggled = DebitCreditCode.DEBIT.toggle();
		Assert.assertEquals(DebitCreditCode.CREDIT, toggled);
		final DebitCreditCode original = toggled.toggle();
		Assert.assertEquals(DebitCreditCode.DEBIT, original);
	}
	
	/**
	 * Testing if class implements @{@link Toggleable} and UnsupportedOperationException is expected
	 */
	@Test
	public void testStateToggle() {
		try {
			State.OFF.toggle();
			Assert.fail();
		} catch (UnsupportedOperationException e) {
			Assert.assertEquals("Only enum can support toggling", e.getMessage());
		}
	}
	
	/**
	 * Testing when enum has more than 2 objects, UnsupportedOperationException is expected
	 */
	@Test
	public void testStatusToggle() {
		try {
			Status.COMPLETED.toggle();
			Assert.fail();
		} catch (UnsupportedOperationException e) {
			Assert.assertEquals("Enum must have 2 objects to support toggling", e.getMessage());
		}
	}
}
