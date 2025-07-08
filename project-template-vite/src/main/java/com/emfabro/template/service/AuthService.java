package com.emfabro.template.service;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.PrivateKey;
import java.security.Security;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Arrays;
import java.util.Base64;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import com.emfabro.global.constant.WebValues;
import com.emfabro.global.utils.Ciphers;
import com.emfabro.global.utils.Ciphers.RSA;
import com.emfabro.global.utils.Lambdas;
import com.emfabro.global.utils.Signatures;
import com.emfabro.template.domain.vo.AuthPair;
import jakarta.servlet.http.Cookie;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.springframework.data.util.Pair;
import org.springframework.stereotype.Service;

import static com.emfabro.global.utils.Signatures.Mode.SIG_MODE_HMAC_SHA256;


@Service
public class AuthService {
    private static final String PAIR_NOT_FOUNT = "無對應金鑰";
    private static ConcurrentHashMap<String, AuthPair> authPairs = new ConcurrentHashMap<>();


    public AuthPair genKeyPair(String account) {
        Security.addProvider(new BouncyCastleProvider());

        return Optional.ofNullable(authPairs.get(account)).orElseGet(Lambdas.ofSupplier(() -> {
            Pair<RSAPublicKey, RSAPrivateKey> keyPair = RSA.genKeyPair();

            AuthPair authPair = new AuthPair(RSA.encode(keyPair.getFirst()), RSA.encode(keyPair.getSecond()));

            authPairs.put(account, authPair);

            return authPair;
        }));
    }

    public String decodeThenSig(String account, String armour) throws GeneralSecurityException {
        Security.addProvider(new BouncyCastleProvider());

        AuthPair authPair = getIfNotExpired(account);

        PrivateKey privateKey = RSA.decode(authPair.getPriv(), PKCS8EncodedKeySpec::new,
                                           keyFactory -> Lambdas.ofFunc(keyFactory::generatePrivate));

        byte[] bytes = RSA.jiemi(privateKey, Base64.getDecoder().decode(armour.getBytes()));

        String whisper = new String(bytes, StandardCharsets.UTF_8);

        return Signatures.sig(SIG_MODE_HMAC_SHA256, whisper, WebValues.WHISPER_AGENT);
    }

    private AuthPair getIfNotExpired(String account) throws GeneralSecurityException {
        AuthPair authPair = Optional.ofNullable(authPairs.get(account))
                                    .orElseThrow(() -> new GeneralSecurityException(PAIR_NOT_FOUNT));

        if (authPair.isExpired()) {
            authPairs.remove(account);
            throw new GeneralSecurityException(PAIR_NOT_FOUNT);
        }

        return authPair;
    }

    public void removeAuthPairIfExpired() {
        authPairs.entrySet()
                 .stream()
                 .filter(entry -> entry.getValue().isExpired())
                 .forEach(entry -> authPairs.remove(entry.getKey()));
    }

    public Optional<Cookie> findToken(Cookie[] cookies) {
        return Arrays.stream(cookies != null ? cookies : new Cookie[]{})
                     .filter(member -> member.getName().equalsIgnoreCase(WebValues.COOKIE_TOKEN))
                     .findFirst();
    }

    public byte[] detectSigToken(String sigToken) throws GeneralSecurityException {
        String b64Json = Ciphers.GCM.jiemi(sigToken, WebValues.TOKEN_AGENT);

        return Base64.getDecoder().decode(b64Json);
    }
}
