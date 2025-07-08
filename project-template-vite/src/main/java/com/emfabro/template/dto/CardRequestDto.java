package com.emfabro.template.dto;

import lombok.Data;

@Data
public class CardRequestDto {
    private String name;
    private String company;
    private String phone;
    private String email;
    private String address;
    private String position;
    private String style;
    private Boolean facebook;
    private Boolean instagram;
    private Boolean line;
    private Boolean threads;
    private Boolean isPublic;
}