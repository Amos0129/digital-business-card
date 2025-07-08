package com.emfabro.global.utils;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Base64;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String base64Secret;

    private Key signingKey;

    private static final long EXPIRATION = 1000 * 60 * 60; // 1 小時

    @PostConstruct
    public void init() {
        byte[] keyBytes = Base64.getDecoder().decode(base64Secret);
        this.signingKey = Keys.hmacShaKeyFor(keyBytes);
    }


    public String generateToken(Integer userId, String email) {
        return Jwts.builder()
                   .setSubject(email)
                   .claim("userId", userId)
                   .setIssuedAt(new Date())
                   .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
                   .signWith(signingKey, SignatureAlgorithm.HS256)
                   .compact();
    }


    public String extractEmail(String token) {
        return Jwts.parserBuilder()
                   .setSigningKey(signingKey)
                   .build()
                   .parseClaimsJws(token)
                   .getBody()
                   .getSubject();
    }

    // ✅ 新增這裡：提取 userId
    public Integer extractUserId(String token) {
        return Jwts.parserBuilder()
                   .setSigningKey(signingKey)
                   .build()
                   .parseClaimsJws(token)
                   .getBody()
                   .get("userId", Integer.class);
    }
}