package com.emfabro.template.domain.vo;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AuthPair {
    private String pub;
    private String priv;
    private Long expire;

    public AuthPair(String pub, String priv) {
        this.pub = pub;
        this.priv = priv;
        this.expire = LocalDateTime.now()
                                   .plusMinutes(3)
                                   .atZone(ZoneId.systemDefault())
                                   .toInstant()
                                   .toEpochMilli();
    }

    @JsonIgnore
    public Boolean isExpired() {
        LocalDateTime expiredTime = LocalDateTime.ofInstant(Instant.ofEpochMilli(expire), ZoneId.systemDefault());

        return expiredTime.isBefore(LocalDateTime.now());
    }
}
