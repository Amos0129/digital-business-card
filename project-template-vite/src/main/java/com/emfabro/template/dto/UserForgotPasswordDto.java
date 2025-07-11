package com.emfabro.template.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UserForgotPasswordDto {

    @Email(message = "請輸入有效的 Email 格式")
    @NotBlank(message = "Email 不可為空")
    private String email;
}
