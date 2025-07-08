package com.emfabro.template.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "permission_item")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PermissionItem extends BaseEntity.CreateFull {

    @Column(name = "permission_id")
    private Long permissionId;

    @Column
    private String name;

    @Column
    private Byte type;

    public interface ItemType {
        Byte PAGE = 0;
        Byte FEATURE = 1;
    }
}
