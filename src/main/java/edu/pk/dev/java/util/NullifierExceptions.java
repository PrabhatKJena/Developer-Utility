package edu.pk.dev.java.util;

import static java.util.Objects.requireNonNull;

/**
 * Created by IntelliJ IDEA.
 * User: prajena
 * Date: 3/15/18
 * Time: 4:43 PM
 * To change this template use File | Settings | File and Code Templates.
 */
public final class NullifierExceptions {

    /**
     * <p>Throws any type of {@link Throwable} as an unchecked type.</p>
     * Usage:
     * <pre><code>
     *   void foo(Closeable c) {
     *     try {
     *       c.close();
     *     } catch(IOException e) {
     *       throw NullifierExceptions.throwChecked(e);
     *     }
     *   }
     * </code></pre>
     *
     * @param t the (non-null) type to throw
     * @return an unchecked throwable type for syntax reasons
     */
    public static <T extends Throwable> UncheckedMarker throwChecked(Throwable t) {
        NullifierExceptions.throwIt(requireNonNull(t, "throwable"));
        return null;// This will not return at all in any circumstance, before that throwIt() will throw the exception. This is only to convince the compiler (syntax purpose)
    }

    @SuppressWarnings("unchecked")
    private static <T extends Throwable> Throwable throwIt(Throwable t) throws T {
        throw (T) t;
    }

    /**
     * This error type cannot be thrown; it exists to allow
     * callers of
     * {@link NullifierExceptions#throwChecked(Throwable)}
     * to express intent with the {@code throw} keyword.
     *
     * @see NullifierExceptions#throwChecked(Throwable)
     */
    private static final class UncheckedMarker extends Error {

        private UncheckedMarker() {
        }
    }
}
