package com.emfabro.template.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ResetPasswordRequestDto {

    @NotBlank(message = "Token 不可為空")
    private String token;

    @NotBlank(message = "新密碼不可為空")
    private String newPassword;
}
