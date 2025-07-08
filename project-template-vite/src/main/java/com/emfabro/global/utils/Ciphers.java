package com.emfabro.global.utils;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Signature;
import java.security.SignatureException;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.security.spec.MGF1ParameterSpec;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.function.Function;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.OAEPParameterSpec;
import javax.crypto.spec.PSource;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.data.util.Pair;

public class Ciphers {
    private static final String KEY_GEN_AES = "AES";
    private static final String AES_GCM_MODE = "AES/GCM/NoPadding";

    public Ciphers() {
        super();
    }

    public static class GCM {
        public static String jiami(String plainText, String key) throws GeneralSecurityException {
            SecureRandom secureRandom = new SecureRandom();
            SecretKey secretKey = new SecretKeySpec(key.getBytes(), KEY_GEN_AES);

            byte[] iv = new byte[12];
            secureRandom.nextBytes(iv);

            final Cipher cipher = Cipher.getInstance(AES_GCM_MODE);
            GCMParameterSpec parameterSpec = new GCMParameterSpec(128, iv);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, parameterSpec);

            byte[] cipherText = cipher.doFinal(plainText.getBytes());

            ByteBuffer byteBuffer = ByteBuffer.allocate(4 + iv.length + cipherText.length);
            byteBuffer.putInt(iv.length);
            byteBuffer.put(iv);
            byteBuffer.put(cipherText);
            return Base64.getEncoder().encodeToString(byteBuffer.array());
        }

        public static String jiemi(String encryptText, String key) throws GeneralSecurityException {
            byte[] encrypt = Base64.getDecoder().decode(encryptText);

            ByteBuffer byteBuffer = ByteBuffer.wrap(encrypt);
            int ivLength = byteBuffer.getInt();
            byte[] iv = new byte[ivLength];
            byteBuffer.get(iv);
            byte[] cipherText = new byte[byteBuffer.remaining()];
            byteBuffer.get(cipherText);

            final Cipher cipher = Cipher.getInstance(AES_GCM_MODE);
            cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(key.getBytes(), KEY_GEN_AES),
                        new GCMParameterSpec(128, iv));

            return new String(cipher.doFinal(cipherText));
        }
    }

    public static class RSA {

        public static Pair<RSAPublicKey, RSAPrivateKey> genKeyPair() throws NoSuchAlgorithmException {
            KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("RSA");
            keyPairGenerator.initialize(2048);
            KeyPair keyPair = keyPairGenerator.generateKeyPair();

            return Pair.of((RSAPublicKey) keyPair.getPublic(), (RSAPrivateKey) keyPair.getPrivate());
        }

        public static Pair<PublicKey, PrivateKey> genPKCS8KeyPair()
                throws NoSuchAlgorithmException, InvalidKeySpecException {
            Pair<RSAPublicKey, RSAPrivateKey> pair = genKeyPair();

            X509EncodedKeySpec x509EncodedKeySpec = new X509EncodedKeySpec(pair.getFirst().getEncoded());
            PublicKey publicKey = KeyFactory.getInstance("RSA").generatePublic(x509EncodedKeySpec);

            PKCS8EncodedKeySpec pkcs8EncodedKeySpec = new PKCS8EncodedKeySpec(pair.getSecond().getEncoded());
            PrivateKey privateKey = KeyFactory.getInstance("RSA").generatePrivate(pkcs8EncodedKeySpec);

            return Pair.of(publicKey, privateKey);
        }

        private static Cipher genCipher(Key key, final int mode) throws GeneralSecurityException {
            Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding", "BC");
            OAEPParameterSpec params = new OAEPParameterSpec("SHA-256", "MGF1", MGF1ParameterSpec.SHA256,
                                                             PSource.PSpecified.DEFAULT);
            cipher.init(mode, key, params);
            return cipher;
        }

        public static byte[] jiami(Key key, String text) throws GeneralSecurityException {
            Cipher cipher = genCipher(key, Cipher.ENCRYPT_MODE);

            return cipher.doFinal(text.getBytes(StandardCharsets.UTF_8));
        }

        public static byte[] jiemi(Key key, byte[] encContent) throws GeneralSecurityException {
            Cipher cipher = genCipher(key, Cipher.DECRYPT_MODE);

            return cipher.doFinal(encContent);
        }

        public static boolean verifySig(PublicKey key, byte[] content, byte[] signature)
                throws NoSuchAlgorithmException, InvalidKeyException, SignatureException {
            Signature instance = Signature.getInstance("SHA256withRSA");

            instance.initVerify(key);
            instance.update(content);

            return instance.verify(signature);
        }

        public static String encode(Key key) {
            return Base64.getEncoder().encodeToString(key.getEncoded());
        }


        public static <RsaKey extends Key, RsaKeySpec extends KeySpec> RsaKey decode(String b64Key,
                Function<byte[], RsaKeySpec> keySpecFunc,
                Function<KeyFactory, Function<RsaKeySpec, RsaKey>> keyFunc) throws NoSuchAlgorithmException {
            byte[] keyContent = Base64.getDecoder().decode(b64Key);

            return keyFunc.apply(KeyFactory.getInstance("RSA")).apply(keySpecFunc.apply(keyContent));
        }
    }

}
