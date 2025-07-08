package com.emfabro.template.domain.vo;

import com.emfabro.template.domain.Page;
import com.emfabro.template.domain.entity.Member;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;


public class MemberVo {
    private MemberVo() {
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Query {
        private Long id;
        private String account;
        private String name;
        private Byte status;

        public static MemberVo.Query of(Member member) {
            return new Query(member.getId(), member.getAccount(), member.getName(), member.getStatus());
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Args extends Page.Args {
        private String account;
        private String name;
        private Byte status;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Profile {
        private String account;
        private String name;
        private Byte status;
        private Long permissionId;
    }


    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Save {
        private String account;
        private String name;
        private String armour;
        private Long permissionId;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Update {
        private String account;
        private String name;
        private Byte status;
        private Long permissionId;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ChangeWhisper {
        private String account;
        private String armour1;
        private String armour2;
    }
}
