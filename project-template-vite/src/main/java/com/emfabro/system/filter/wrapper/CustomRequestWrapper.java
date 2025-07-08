package com.emfabro.system.filter.wrapper;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ReadListener;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import org.springframework.http.HttpMethod;

//TODO: review here
public class CustomRequestWrapper extends HttpServletRequestWrapper {
    private ByteArrayOutputStream buffer;
    private final Boolean isGET = super.getMethod().equals(HttpMethod.GET.name());
    private final Boolean isDELETE = super.getMethod().equals(HttpMethod.DELETE.name());
    private final Boolean isPOST = super.getMethod().equals(HttpMethod.POST.name());
    private final Boolean isPUT = super.getMethod().equals(HttpMethod.PUT.name());
    private static final String[] HEADERS_TO_TRY = {
            "X-Forwarded-For",
            "Proxy-Client-IP",
            "WL-Proxy-Client-IP",
            "HTTP_X_FORWARDED_FOR",
            "HTTP_X_FORWARDED",
            "HTTP_X_CLUSTER_CLIENT_IP",
            "HTTP_CLIENT_IP",
            "HTTP_FORWARDED_FOR",
            "HTTP_FORWARDED",
            "HTTP_VIA",
            "REMOTE_ADDR"
    };


    public CustomRequestWrapper(HttpServletRequest request) {
        super(request);
    }

    @Override
    public ServletInputStream getInputStream() throws IOException {
        if (buffer == null) {
            buffer = new ByteArrayOutputStream();
            super.getInputStream().transferTo(buffer);
        }

        return new CustomServletInputStream(buffer.toByteArray());
    }

    public String getJson() throws IOException {
        Object object;
        if (isGET || isDELETE) {
            object = getParams();
        } else if (isPOST || isPUT) {
            object = getBody();
        } else {
            object = new HashMap();
        }

        return new ObjectMapper().writeValueAsString(object);
    }

    private Object getParams() {
        Function<String[], Object> singleOrNot = strings -> strings.length > 1 ? strings : strings[0];

        return Optional.of(super.getParameterMap())
                       .filter(map -> map.size() > 0)
                       .map(params -> params.entrySet()
                                            .stream()
                                            .collect(Collectors.toMap(Map.Entry::getKey,
                                                                      entry -> singleOrNot
                                                                              .apply(entry.getValue()))))
                       .orElse(new HashMap<>());
    }

    @SuppressWarnings("unchecked")
    private Object getBody() throws IOException {
        try (ByteArrayOutputStream buffer = new ByteArrayOutputStream()) {
            boolean isEmpty = buffer.toByteArray().length == 0;

            if (isEmpty) {
                return new HashMap<>();
            } else {
                ObjectMapper objectMapper = new ObjectMapper();

                Class reflection = objectMapper.readTree(buffer.toByteArray()).isArray() ? List.class : Map.class;

                return objectMapper.readValue(buffer.toByteArray(), reflection);
            }
        }
    }

    public <T> T getBody(Class<T> tClass) throws IOException, IllegalAccessException, InstantiationException,
            NoSuchMethodException, InvocationTargetException {
        try (ByteArrayOutputStream buffer = new ByteArrayOutputStream()) {
            boolean isEmpty = buffer.toByteArray().length == 0;

            if (isEmpty) {
                return tClass.getDeclaredConstructor().newInstance();
            } else {
                return new ObjectMapper().readValue(buffer.toByteArray(), tClass);
            }
        }
    }

    public String getIpAddress() {
        for (String header : HEADERS_TO_TRY) {
            String ip = getHeader(header);
            if (ip != null && ip.length() != 0 && !"unknown".equalsIgnoreCase(ip)) {
                return ip;
            }
        }
        return getRemoteAddr();
    }

    @Override
    public BufferedReader getReader() throws IOException {
        return new BufferedReader(new InputStreamReader(getInputStream()));
    }

    private static class CustomServletInputStream extends ServletInputStream {
        private final ByteArrayInputStream input;

        public CustomServletInputStream(byte[] binary) {
            this.input = new ByteArrayInputStream(binary);
        }

        @Override
        public boolean isFinished() {
            return false;
        }

        @Override
        public boolean isReady() {
            return false;
        }

        @Override
        public void setReadListener(ReadListener listener) {

        }

        @Override
        public int read() {
            return input.read();
        }
    }
}