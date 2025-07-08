package com.emfabro.template.service;

import java.time.LocalDateTime;
import java.util.Optional;

import com.emfabro.template.dao.UserDao;
import com.emfabro.template.domain.entity.User;
import com.emfabro.template.dto.UserForgotPasswordDto;
import com.emfabro.template.dto.UserRegisterDto;
import com.emfabro.template.dto.UserLoginDto;
import com.emfabro.template.dto.UserResponseDto;
import com.emfabro.global.utils.JwtUtil;
import com.emfabro.template.dto.UserLoginResponseDto;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserDao.Jpa userJpa;
    private final GroupService groupService;
    private final JwtUtil jwtUtil;

    public Optional<User> findById(Integer userId) {
        return userJpa.findById(userId);
    }

    public UserLoginResponseDto loginWithJwt(UserLoginDto dto) {
        User user = login(dto.getEmail(), dto.getPassword());
        String token = jwtUtil.generateToken(user.getId(), user.getEmail());
        return new UserLoginResponseDto(user.getId(), user.getEmail(), user.getName(), token);
    }

    // 🔍 查詢用：依 Email 找 User 資料
    public Optional<User> findByEmail(String email) {
        return userJpa.findByEmail(email);
    }

    // ✅ 驗證 Email 是否存在
    public boolean existsByEmail(String email) {
        return userJpa.existsByEmail(email);
    }

    public void sendResetLink(UserForgotPasswordDto dto) {
        // TODO: 這裡可以實作寄送 reset link 的邏輯
        System.out.println("模擬寄送 reset link 到: " + dto.getEmail());
    }

    // ✅ 註冊邏輯：接收 DTO，回傳 ResponseDto
    public UserResponseDto register(UserRegisterDto dto) {
        String defaultName = dto.getEmail().split("@")[0]; // 暫用 email 當 name
        User user = createUser(defaultName, dto.getEmail(), dto.getPassword());
        return new UserResponseDto(user.getId(), user.getEmail(), user.getName());
    }

    // ✅ 登入邏輯：驗證密碼，成功回傳 ResponseDto
    public UserResponseDto login(UserLoginDto dto) {
        User user = login(dto.getEmail(), dto.getPassword());
        return new UserResponseDto(user.getId(), user.getEmail(), user.getName());
    }

    // 🔐 驗證帳號密碼（僅限內部使用）
    public User login(String email, String password) {
        return userJpa.findByEmail(email)
                      .filter(user -> user.getPassword().equals(password))
                      .orElseThrow(() -> new RuntimeException("帳號或密碼錯誤"));
    }

    public void updateDisplayName(Integer userId, String name) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new RuntimeException("找不到使用者"));

        user.setName(name);
        user.setUpdatedAt(LocalDateTime.now());
        userJpa.save(user);
    }

    public void changePassword(Integer userId, String oldPassword, String newPassword) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new RuntimeException("找不到使用者"));

        if (!user.getPassword().equals(oldPassword)) {
            throw new RuntimeException("舊密碼錯誤");
        }

        user.setPassword(newPassword);
        user.setUpdatedAt(LocalDateTime.now());
        userJpa.save(user);
    }

    // ➕ 建立新使用者帳號（僅限內部使用）
    public User createUser(String name, String email, String password) {
        if (userJpa.existsByEmail(email)) {
            throw new RuntimeException("此帳號已被註冊");
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(password);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        User savedUser = userJpa.save(user);

        // ✅ 建立預設群組
        String[] defaultGroups = { "客戶", "朋友", "家人" };
        for (String groupName : defaultGroups) {
            groupService.createGroup(savedUser.getId(), groupName);
        }

        return savedUser;
    }
}
