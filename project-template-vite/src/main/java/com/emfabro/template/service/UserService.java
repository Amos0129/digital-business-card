package com.emfabro.template.service;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.emfabro.global.exception.BadRequestException;
import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.global.exception.NotFoundException;
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
    private final PasswordEncoder passwordEncoder;
    private final JavaMailSender mailSender;

    public Optional<User> findById(Integer userId) {
        return userJpa.findById(userId);
    }

    public UserLoginResponseDto loginWithJwt(UserLoginDto dto) {
        User user = login(dto.getEmail(), dto.getPassword());
        String token = jwtUtil.generateToken(user.getId(), user.getEmail());
        return new UserLoginResponseDto(user.getId(), user.getEmail(), user.getName(), token);
    }

    public Optional<User> findByEmail(String email) {
        return userJpa.findByEmail(email);
    }

    public boolean existsByEmail(String email) {
        return userJpa.existsByEmail(email);
    }

    public void sendResetLink(UserForgotPasswordDto dto) {
        User user = userJpa.findByEmail(dto.getEmail())
                           .orElseThrow(() -> new BadRequestException("找不到該帳號"));

        String resetToken = jwtUtil.generatePasswordResetToken(user.getId());
        String resetUrl = "http://192.168.205.58:5566/reset-password?token=" + resetToken;

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(user.getEmail());
        message.setSubject("密碼重設連結");
        message.setText("請點擊以下連結重設密碼：\n" + resetUrl + "\n此連結15分鐘內有效。");

        mailSender.send(message);

        System.out.println("已發送密碼重設信至：" + user.getEmail());
    }

    public void resetPassword(String token, String newPassword) {
        Integer userId;
        try {
            userId = jwtUtil.validatePasswordResetToken(token);
        } catch (RuntimeException e) {
            throw new BadRequestException("重設密碼連結無效或已過期");
        }

        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new NotFoundException("找不到使用者"));

        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(LocalDateTime.now());
        userJpa.save(user);
    }

    public UserResponseDto register(UserRegisterDto dto) {
        String defaultName = dto.getEmail().split("@")[0];
        User user = createUser(defaultName, dto.getEmail(), dto.getPassword());
        return new UserResponseDto(user.getId(), user.getEmail(), user.getName());
    }

    public UserResponseDto login(UserLoginDto dto) {
        User user = login(dto.getEmail(), dto.getPassword());
        return new UserResponseDto(user.getId(), user.getEmail(), user.getName());
    }

    public User login(String email, String password) {
        return userJpa.findByEmail(email)
                      .filter(user -> passwordEncoder.matches(password, user.getPassword()))
                      .orElseThrow(() -> new BadRequestException("帳號或密碼錯誤"));
    }

    public void updateDisplayName(Integer userId, String name) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new NotFoundException("找不到使用者"));

        user.setName(name);
        user.setUpdatedAt(LocalDateTime.now());
        userJpa.save(user);
    }

    public void changePassword(Integer userId, String oldPassword, String newPassword) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new NotFoundException("找不到使用者"));

        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new ForbiddenException("舊密碼錯誤");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdatedAt(LocalDateTime.now());
        userJpa.save(user);
    }

    public User createUser(String name, String email, String password) {
        if (userJpa.existsByEmail(email)) {
            throw new BadRequestException("此帳號已被註冊");
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        User savedUser = userJpa.save(user);

        String[] defaultGroups = { "客戶", "朋友", "家人" };
        for (String groupName : defaultGroups) {
            groupService.createGroup(savedUser.getId(), groupName);
        }

        return savedUser;
    }
}

