package com.emfabro.template.dao;

import com.emfabro.template.domain.entity.PermissionItem;
import org.springframework.data.jpa.repository.JpaRepository;

public class PermissionItemDao {

    public interface Jpa extends JpaRepository<PermissionItem, Long> {
        void deleteByPermissionId(Long permissionId);
    }
}
