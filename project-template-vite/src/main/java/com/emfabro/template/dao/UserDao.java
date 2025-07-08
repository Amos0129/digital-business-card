package com.emfabro.template.dao;

import java.util.Optional;

import com.emfabro.template.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public class UserDao {

    public interface Jpa extends JpaRepository<User, Integer> {

        Optional<User> findByEmail(String email); // 根據電子郵件查找使用者
        Boolean existsByEmail(String email); // 檢查電子郵件是否已存在
    }
}
