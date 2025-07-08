package com.emfabro.template.dao;

import java.util.List;

import com.emfabro.template.domain.entity.PermissionGroup;
import org.springframework.data.jpa.repository.JpaRepository;

public class PermissionGroupDao {

    public interface Jpa extends JpaRepository<PermissionGroup, Long> {
        List<PermissionGroup> findByPermissionId(Long permissionId);

        PermissionGroup findByMemberId(Long memberId);

        void deleteByMemberId(Long memberId);
    }
}
