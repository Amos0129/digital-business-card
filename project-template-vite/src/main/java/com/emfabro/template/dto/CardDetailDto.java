package com.emfabro.template.dto;

import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.Group;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class CardDetailDto {
    private Integer id;
    private String name;
    private String company;
    private String phone;
    private String email;
    private String address;
    private String style;
    private String avatarUrl;
    private String facebookUrl;
    private String instagramUrl;
    private String lineUrl;
    private String threadsUrl;
    private Boolean facebook;
    private Boolean instagram;
    private Boolean line;
    private Boolean threads;

    // ✅ 這段就是你要加的
    public CardDetailDto(
            Integer id,
            String name,
            String company,
            String phone,
            String email,
            String address,
            String style,
            Boolean facebook,
            Boolean instagram,
            Boolean line,
            Boolean threads
    ) {
        this.id = id;
        this.name = name;
        this.company = company;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.style = style;
        this.facebook = facebook;
        this.instagram = instagram;
        this.line = line;
        this.threads = threads;
    }

    public static CardDetailDto fromEntity(Card card) {
        CardDetailDto dto = new CardDetailDto();
        dto.setId(card.getId());
        dto.setName(card.getName());
        dto.setCompany(card.getCompany());
        dto.setPhone(card.getPhone());
        dto.setEmail(card.getEmail());
        dto.setAddress(card.getAddress());
        dto.setStyle(card.getStyle());
        dto.setAvatarUrl(card.getAvatarUrl());
        dto.setFacebookUrl(card.getFacebookUrl());
        dto.setInstagramUrl(card.getInstagramUrl());
        dto.setLineUrl(card.getLineUrl());
        dto.setThreadsUrl(card.getThreadsUrl());
        dto.setFacebook(card.getFacebook());
        dto.setInstagram(card.getInstagram());
        dto.setLine(card.getLine());
        dto.setThreads(card.getThreads());
        return dto;
    }
}