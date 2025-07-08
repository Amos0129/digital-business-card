package com.emfabro.global.utils;


import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.client5.http.impl.io.BasicHttpClientConnectionManager;
import org.apache.hc.client5.http.ssl.DefaultClientTlsStrategy;
import org.apache.hc.client5.http.ssl.HostnameVerificationPolicy;
import org.apache.hc.client5.http.ssl.NoopHostnameVerifier;
import org.apache.hc.client5.http.ssl.TlsSocketStrategy;
import org.apache.hc.core5.http.config.Registry;
import org.apache.hc.core5.http.config.RegistryBuilder;
import org.apache.hc.core5.ssl.SSLContextBuilder;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.boot.web.client.RestTemplateCustomizer;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import javax.net.ssl.SSLContext;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.time.Duration;
import java.util.Collections;
import java.util.Map;

@Slf4j
@AllArgsConstructor
@NoArgsConstructor
public class RestClients {
    private RestTemplate template;

    private interface Config {
        long TIMEOUT_SEC = 60;
        HttpHeaders JSON_HEADER = new HttpHeaders() {{
            setContentType(MediaType.APPLICATION_JSON);
            setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        }};
    }

    public static RestClients create() {
        return create(new RestTemplateBuilder());
    }

    public static RestClients create(File ks, String jian) {
        return create(new RestTemplateBuilder(new SSLRestTemplate(ks, jian)));
    }

    private static RestClients create(RestTemplateBuilder builder) {
        return new RestClients(builder.connectTimeout(Duration.ofSeconds(Config.TIMEOUT_SEC))
                .readTimeout(Duration.ofSeconds(Config.TIMEOUT_SEC))
                .build());
    }

    public <D, T> T post(String url, D data, Class<T> rspClass) {
        return this.template.postForEntity(url,
                new HttpEntity<>(data != null ? convertForPost(data) : null, Config.JSON_HEADER),
                rspClass).getBody();
    }

    public <T> T get(String url, Class<T> rspClass) {
        return template.getForEntity(toUri(url), rspClass).getBody();
    }

    public <T> T get(String url, Class<T> rspClass, String token) {
        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.AUTHORIZATION, "Bearer " + token);
        HttpEntity<Void> requestEntity = new HttpEntity<>(headers);

        return template.exchange(toUri(url), HttpMethod.GET, requestEntity, rspClass).getBody();
    }

    public <T> T get(String url, Class<T> rspClass, HttpHeaders headers) {
        HttpEntity<Void> requestEntity = new HttpEntity<>(headers);

        return template.exchange(toUri(url), HttpMethod.GET, requestEntity, rspClass).getBody();
    }

    public <D, T> T get(String url, D data, Class<T> rspClass) {
        return this.template.getForEntity(toUriWithParams(url, data), rspClass)
                .getBody();
    }

    public static URI toUri(String url) {
        return UriComponentsBuilder.fromUriString(url).encode(StandardCharsets.UTF_8).build().toUri();
    }

    public static URI toUri(String url, Integer port) {
        return UriComponentsBuilder.fromUriString(url).port(port).encode(StandardCharsets.UTF_8).build().toUri();
    }

    public static <D> URI toUriWithParams(String url, D data) {
        URI uri = toUri(url);

        return UriComponentsBuilder.newInstance().uri(uri)
                .queryParams(convertForQuery(data))
                .encode(StandardCharsets.UTF_8)
                .build()
                .toUri();
    }

    @SuppressWarnings("unchecked")
    private static <D> LinkedMultiValueMap<String, String> convertForQuery(D domain) {
        LinkedMultiValueMap<String, String> map = new LinkedMultiValueMap<>();

        map.setAll(new ObjectMapper().convertValue(domain, Map.class));

        return map;
    }

    @SuppressWarnings("unchecked")
    private static <D> Map<String, String> convertForPost(D domain) {
        return new ObjectMapper().convertValue(domain, Map.class);
    }


    @NoArgsConstructor
    @AllArgsConstructor
    @Component
    public static class SSLRestTemplate implements RestTemplateCustomizer {
        private File ks;
        private String jian;

        @Override
        public void customize(RestTemplate restTemplate) {
            if (isSettingSSL()) {
                createSSL(restTemplate);
            }
        }

        private boolean isSettingSSL() {
            return ks != null && jian != null;
        }

        private void createSSL(RestTemplate restTemplate) {
            try (CloseableHttpClient httpClient = HttpClients.custom()
                    .setConnectionManager(createManager())
                    .setConnectionManagerShared(true)
                    .build()) {

                HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory(httpClient);

                restTemplate.setRequestFactory(factory);
            } catch (GeneralSecurityException | IOException e) {
                log.error(e.getMessage());
            }
        }

        private BasicHttpClientConnectionManager createManager() throws GeneralSecurityException {
            DefaultClientTlsStrategy tlsStrategy =
                    new DefaultClientTlsStrategy(configureSecurity(),
                            HostnameVerificationPolicy.CLIENT,
                            NoopHostnameVerifier.INSTANCE);

            Registry<TlsSocketStrategy> tlsRegistry = RegistryBuilder.<TlsSocketStrategy>create()
                    .register("https", tlsStrategy)
                    .build();

            return BasicHttpClientConnectionManager.create(tlsRegistry);
        }

        private SSLContext configureSecurity() throws GeneralSecurityException {
            try {
                return SSLContextBuilder.create()
                        .loadTrustMaterial(ks, jian.toCharArray(), (x509Certificates, authType) -> true)
                        .setProtocol("TLSv1.2")
                        .build();
            } catch (GeneralSecurityException e) {
                throw new GeneralSecurityException("匯入SSL金鑰發生錯誤");
            } catch (IOException e) {
                throw new GeneralSecurityException("找不到.p12相關檔案");
            }
        }
    }

}


