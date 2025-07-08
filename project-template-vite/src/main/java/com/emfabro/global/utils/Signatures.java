package com.emfabro.global.utils;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import static java.nio.charset.StandardCharsets.UTF_8;

public class Signatures {

    public Signatures() {
        super();
    }

    public static String sig(String sigMode, String data, String key)
            throws NoSuchAlgorithmException, InvalidKeyException {
        Mac hmac = Mac.getInstance(sigMode);
        SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(), sigMode);
        hmac.init(secretKey);

        return Base64.getUrlEncoder()
                     .encodeToString(hmac.doFinal(data.getBytes(UTF_8)));
    }

    public interface Mode {
        String SIG_MODE_HMAC_SHA256 = "HmacSHA256";
    }
}
