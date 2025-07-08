package com.emfabro.template.domain.vo;

import java.io.IOException;
import java.util.Base64;
import java.util.Optional;
import java.util.UUID;

import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.template.domain.entity.Member;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import static com.emfabro.global.constant.AdviceValues.PERMISSION_DENIED;

@Getter
@Setter
public class LoginVo {
    private String account;
    private String armour;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Header {
        private UUID seed;
        private Long id;
        private String account;
        private String name;

        public Header(Long id, String account, String name) {
            this.seed = UUID.randomUUID();
            this.id = id;
            this.account = account;
            this.name = name;
        }

        public static Header of(String csrfToken) throws ForbiddenException, IOException {
            String b64Csrf = Optional.ofNullable(csrfToken)
                                     .orElseThrow(() -> new ForbiddenException(PERMISSION_DENIED));

            return new ObjectMapper().readValue(Base64.getDecoder().decode(b64Csrf), Header.class);
        }

        public static Header of(Member member) {
            return new LoginVo.Header(member.getId(), member.getAccount(), member.getName());
        }
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Payload {
        private Header userInfo;
        private PermissionVo permission;
    }
}
