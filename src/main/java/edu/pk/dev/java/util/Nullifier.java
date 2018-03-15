package edu.pk.dev.java.util;

/**
 * Created by IntelliJ IDEA.
 * User: prajena
 * Date: 3/14/18
 * Time: 4:53 PM
 * To change this template use File | Settings | File and Code Templates.
 */
@FunctionalInterface
public interface Nullifier<I, O> {
    default O apply(I i) {
        try {
            return (i == null) ? null : _apply(i);
        } catch (Throwable e) {
            throw NullifierExceptions.throwChecked(e);
        }
    }

    O _apply(I i) throws Exception;


    /**
     * Convenience method for evaluating a chain of method calls.
     * A number of overloaded methods are provided with varying argument counts.
     *
     * @param a   the root object in the object graph (may be null)
     * @param f0  is passed "a"; MUST NOT be null
     * @param f1  is passed the result of "f0"; MUST NOT be null
     * @param <A> the root type
     * @param <B> an intermediary type
     * @param <C> the result type
     * @return the result of the function chain or null
     */
    static <A, B, C> C eval(A a,
                            Nullifier<? super A, ? extends B> f0, Nullifier<? super B, ? extends C> f1) {
        B b = f0.apply(a);
        C c = f1.apply(b);
        return c;
    }

    static <A, B, C, D> D eval(A a,
                               Nullifier<? super A, ? extends B> f0,
                               Nullifier<? super B, ? extends C> f1,
                               Nullifier<? super C, ? extends D> f2) {
        C c = eval(a, f0, f1);
        D d = f2.apply(c);
        return d;
    }

    static <A, B, C, D, E> E eval(A a,
                                  Nullifier<? super A, ? extends B> f0,
                                  Nullifier<? super B, ? extends C> f1,
                                  Nullifier<? super C, ? extends D> f2,
                                  Nullifier<? super D, ? extends E> f3) {
        D d = eval(a, f0, f1, f2);
        E e = f3.apply(d);
        return e;
    }

    static <A, B, C, D, E, F> F eval(A a,
                                     Nullifier<? super A, ? extends B> f0,
                                     Nullifier<? super B, ? extends C> f1,
                                     Nullifier<? super C, ? extends D> f2,
                                     Nullifier<? super D, ? extends E> f3,
                                     Nullifier<? super E, ? extends F> f4) {
        E e = eval(a, f0, f1, f2, f3);
        F f = f4.apply(e);
        return f;
    }

    static <A, B, C, D, E, F, G> G eval(A a,
                                        Nullifier<? super A, ? extends B> f0,
                                        Nullifier<? super B, ? extends C> f1,
                                        Nullifier<? super C, ? extends D> f2,
                                        Nullifier<? super D, ? extends E> f3,
                                        Nullifier<? super E, ? extends F> f4,
                                        Nullifier<? super F, ? extends G> f5) {
        F f = eval(a, f0, f1, f2, f3, f4);
        G g = f5.apply(f);
        return g;
    }

    /**
     * <p>Convenience method for evaluating a chain of method calls to see if any link is null.</p>
     * <p>A number of overloaded methods are provided with varying argument counts.</p>
     * <p>Equivalent to:</p>
     * <pre>boolean isNull = (Nullifier.eval(a, f0, f1) == null);</pre>
     *
     * @param a   the root object in the object graph (may be null)
     * @param f0  is passed "a"; MUST NOT be null
     * @param f1  is passed the result of "f0"; MUST NOT be null
     * @param <A> the root type
     * @param <B> an intermediary type
     * @param <C> the result type
     * @return true if the result is null; false otherwise
     */
    static <A, B, C> boolean isNull(A a,
                                    Nullifier<? super A, ? extends B> f0,
                                    Nullifier<? super B, ? extends C> f1) {
        return eval(a, f0, f1) == null;
    }

    static <A, B, C, D> boolean isNull(A a,
                                       Nullifier<? super A, ? extends B> f0,
                                       Nullifier<? super B, ? extends C> f1,
                                       Nullifier<? super C, ? extends D> f2) {
        return eval(a, f0, f1, f2) == null;
    }

    static <A, B, C, D, E> boolean isNull(A a,
                                          Nullifier<? super A, ? extends B> f0,
                                          Nullifier<? super B, ? extends C> f1,
                                          Nullifier<? super C, ? extends D> f2,
                                          Nullifier<? super D, ? extends E> f3) {
        return eval(a, f0, f1, f2, f3) == null;
    }

    static <A, B, C, D, E, F> boolean isNull(A a,
                                             Nullifier<? super A, ? extends B> f0,
                                             Nullifier<? super B, ? extends C> f1,
                                             Nullifier<? super C, ? extends D> f2,
                                             Nullifier<? super D, ? extends E> f3,
                                             Nullifier<? super E, ? extends F> f4) {
        return eval(a, f0, f1, f2, f3, f4) == null;
    }

    static <A, B, C, D, E, F, G> boolean isNull(A a,
                                                Nullifier<? super A, ? extends B> f0,
                                                Nullifier<? super B, ? extends C> f1,
                                                Nullifier<? super C, ? extends D> f2,
                                                Nullifier<? super D, ? extends E> f3,
                                                Nullifier<? super E, ? extends F> f4,
                                                Nullifier<? super F, ? extends G> f5) {
        return eval(a, f0, f1, f2, f3, f4, f5) == null;
    }

}

