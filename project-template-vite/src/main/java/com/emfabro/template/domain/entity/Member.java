package com.emfabro.template.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "member")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Member extends BaseEntity.Full {

    @Column
    private String account;

    @Column
    private String whisper;

    @Column
    private String name;

    @Column
    private Byte status;

    public interface Status {
        Byte INVALID = -1;
        Byte DISABLED = 0;
        Byte ENABLED = 1;
    }
}
