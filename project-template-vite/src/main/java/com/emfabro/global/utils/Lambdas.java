package com.emfabro.global.utils;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.function.BiFunction;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.IntFunction;
import java.util.function.Predicate;
import java.util.function.Supplier;
import java.util.stream.Collector;
import java.util.stream.Collectors;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.BeanUtils;

public class Lambdas {
    public Lambdas() {
        super();
    }

    public static <T> T mapUUID(String uuid, Function<UUID, T> func) {
        return func.apply(UUID.fromString(uuid));
    }

    public static void mapUUID(String uuid, Consumer<UUID> consumer) {
        consumer.accept(UUID.fromString(uuid));
    }

    public static <T> T last(List<T> list, Supplier<T> supp) {
        Function<List<T>, T> last = collect -> CollectionUtils.isNotEmpty(collect) ?
                collect.get(collect.size() - 1) : supp.get();

        return last.apply(list);
    }

    public static <T, K, U> Collector<T, ?, Map<K, U>> toLinkedMap(Function<? super T, ? extends K> keyMapper,
            Function<? super T, ? extends U> valueMapper) {
        return Collectors.toMap(keyMapper, valueMapper,
                                (u, v) -> {
                                    throw new IllegalStateException(String.format("Duplicate key %s", u));
                                },
                                LinkedHashMap::new
        );
    }

    public static <T> T copyDomain(Class<T> clazz, Object orig)
            throws IllegalAccessException, InstantiationException, NoSuchMethodException, InvocationTargetException {
        T t = clazz.getDeclaredConstructor().newInstance();

        BeanUtils.copyProperties(orig, t);

        return t;
    }

    public static <T, U> List<T> copyDomains(Class<T> clazz, List<U> objects) {
        return Optional.ofNullable(objects)
                       .orElse(new ArrayList<>())
                       .stream()
                       .map(ofFunc(u -> copyDomain(clazz, u)))
                       .collect(Collectors.toList());
    }

    @FunctionalInterface
    public interface ExIntFunction<R> {
        R apply(Integer t) throws Exception;
    }

    @FunctionalInterface
    public interface IoFunction<T, R> {
        R apply(T t) throws IOException;
    }

    @FunctionalInterface
    public interface IoBiFuncation<T, N, R> {
        R apply(T t, N n) throws IOException;
    }

    @FunctionalInterface
    public interface ExFunction<T, R> {
        R apply(T t) throws Exception;
    }

    @FunctionalInterface
    public interface ExSupplier<T> {
        T get() throws Exception;
    }

    @FunctionalInterface
    public interface IoSupplier<T> {
        T get() throws IOException;
    }

    @FunctionalInterface
    public interface IoConsumer<T> {
        void accept(T t) throws IOException;
    }

    @FunctionalInterface
    public interface ExConsumer<T> {
        void accept(T t) throws Exception;
    }

    @FunctionalInterface
    public interface ExPredicate<T> {
        boolean test(T t) throws Exception;
    }

    @SuppressWarnings("unchecked")
    private static <E extends Throwable> void throwIOException(IOException exception) throws E {
        throw (E) exception;
    }

    @SuppressWarnings("unchecked")
    private static <E extends Throwable> void throwException(Exception ex) throws E {
        throw (E) ex;
    }

    public static <T, R> Function<T, R> ofIoFunc(IoFunction<T, R> func) {
        return t -> {
            try {
                return func.apply(t);
            } catch (IOException e) {
                throwIOException(e);
                return null;
            }
        };
    }

    public static <T, N, R> BiFunction<T, N, R> ofIoBiFunc(IoBiFuncation<T, N, R> ioFunc) {
        return (t, n) -> {
            try {
                return ioFunc.apply(t, n);
            } catch (IOException e) {
                throwIOException(e);
                return null;
            }
        };
    }

    public static <T> Consumer<T> ofIoConsumer(IoConsumer<T> consumer) throws IOException {
        return t -> {
            try {
                consumer.accept(t);
            } catch (IOException e) {
                throwIOException(e);
            }
        };
    }

    public static <T, R> Function<T, R> ofFunc(ExFunction<T, R> func) {
        return t -> {
            try {
                return func.apply(t);
            } catch (Exception e) {
                throwException(e);
                return null;
            }
        };
    }

    public static <R> IntFunction<R> ofIntFunc(ExIntFunction<R> func) {
        return t -> {
            try {
                return func.apply(t);
            } catch (Exception e) {
                throwException(e);
                return null;
            }
        };
    }

    public static <T> Consumer<T> ofConsumer(ExConsumer<T> consumer) {
        return t -> {
            try {
                consumer.accept(t);
            } catch (Exception e) {
                throwException(e);
            }
        };
    }


    public static <T> Supplier<T> ofSupplier(ExSupplier<T> supplier) {
        return () -> {
            try {
                return supplier.get();
            } catch (Exception e) {
                throwException(e);
                return null;
            }
        };
    }

    public static <T> Supplier<T> ofIoSupplier(IoSupplier<T> supplier) {
        return () -> {
            try {
                return supplier.get();
            } catch (IOException e) {
                throwIOException(e);
                return null;
            }
        };
    }

    public static <T> Predicate<T> ofPredicate(ExPredicate<T> pre) {
        return t -> {
            try {
                return pre.test(t);
            } catch (Exception e) {
                throwException(e);
                return false;
            }
        };
    }

}
