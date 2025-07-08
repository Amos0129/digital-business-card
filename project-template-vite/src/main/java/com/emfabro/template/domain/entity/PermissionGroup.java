package com.emfabro.template.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "permission_group")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PermissionGroup extends BaseEntity.CreateFull {

    @Column(name = "member_id")
    private Long memberId;

    @Column(name = "permission_id")
    private Long permissionId;

}
