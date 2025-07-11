package com.emfabro.template.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class UserRegisterDto {

    @Email(message = "請輸入有效的 Email 格式")
    @NotBlank(message = "Email 不可為空")
    private String email;

    @NotBlank(message = "密碼不可為空")
    @Size(min = 6, message = "密碼長度至少為 6 碼")
    private String password;
}
