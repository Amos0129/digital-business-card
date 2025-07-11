package com.emfabro.template.api;

import com.emfabro.template.domain.entity.User;
import com.emfabro.template.dto.ResetPasswordRequestDto;
import com.emfabro.template.dto.UserForgotPasswordDto;
import com.emfabro.template.dto.UserLoginDto;
import com.emfabro.template.dto.UserLoginResponseDto;
import com.emfabro.template.dto.UserRegisterDto;
import com.emfabro.template.dto.UserResponseDto;
import com.emfabro.template.service.UserService;
import lombok.RequiredArgsConstructor;
import jakarta.validation.Valid;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@Validated
@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserApi {

    private final UserService userService;

    @GetMapping("/me")
    public UserResponseDto me(@RequestAttribute("userId") Integer userId) {
        return userService.findById(userId)
                          .map(user -> new UserResponseDto(user.getId(), user.getEmail(), user.getName()))
                          .orElseThrow(() -> new RuntimeException("使用者不存在"));
    }

    @PostMapping("/register")
    public UserResponseDto register(@RequestBody @Valid UserRegisterDto dto) {
        return userService.register(dto);
    }

    @PostMapping("/login")
    public UserLoginResponseDto login(@RequestBody UserLoginDto dto) {
        return userService.loginWithJwt(dto);
    }

    @PostMapping("/forgot-password")
    public void forgotPassword(@RequestBody UserForgotPasswordDto dto) {
        userService.sendResetLink(dto);
    }

    @PutMapping("/reset-password")
    public void resetPassword(@RequestBody @Valid ResetPasswordRequestDto dto) {
        userService.resetPassword(dto.getToken(), dto.getNewPassword());
    }

    @GetMapping("/by-email")
    public Optional<User> findByEmail(@RequestParam String email) {
        return userService.findByEmail(email);
    }

    @GetMapping("/exists")
    public boolean exists(@RequestParam String email) {
        return userService.existsByEmail(email);
    }

    @PutMapping("/display-name")
    public void updateDisplayName(@RequestAttribute("userId") Integer userId,
            @RequestParam String name) {
        userService.updateDisplayName(userId, name);
    }

    @PutMapping("/password")
    public void changePassword(@RequestAttribute("userId") Integer userId,
            @RequestParam String oldPassword,
            @RequestParam String newPassword) {
        userService.changePassword(userId, oldPassword, newPassword);
    }
}