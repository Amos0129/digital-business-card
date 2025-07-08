package com.emfabro.template.domain.entity;

import java.sql.Timestamp;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import lombok.Data;

@Data
@MappedSuperclass
public class BaseEntity {

    @Id
    @Column(insertable = false,
            updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Data
    @MappedSuperclass
    public static class CreatePart extends BaseEntity {
        @Column(name = "created_date")
        private Timestamp createdDate;

        public void create() {
            Timestamp now = Timestamp.valueOf(LocalDateTime.now());

            setCreatedDate(now);
        }
    }

    @Data
    @MappedSuperclass
    public static class CreateFull extends CreatePart {
        @Column(name = "created_user")
        private String createdUser;

        public void create(String account) {
            super.create();

            setCreatedUser(account);
        }
    }

    @Data
    @MappedSuperclass
    public static class Full extends CreateFull {
        @Column(name = "modified_user")
        private String modifiedUser;

        @Column(name = "modified_date")
        private Timestamp modifiedDate;

        public void create(String account) {
            super.create(account);
            this.modifiedUser = getCreatedUser();
            this.modifiedDate = getCreatedDate();
        }

        public void update(String account) {
            this.modifiedUser = account;
            this.modifiedDate = Timestamp.valueOf(LocalDateTime.now());
        }
    }
}
