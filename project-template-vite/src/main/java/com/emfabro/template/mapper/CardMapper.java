package com.emfabro.template.mapper;

import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.User;
import com.emfabro.template.dto.CardRequestDto;

public class CardMapper {

    public static void updateEntity(Card card, CardRequestDto dto) {
        card.setName(dto.getName());
        card.setCompany(dto.getCompany());
        card.setPhone(dto.getPhone());
        card.setEmail(dto.getEmail());
        card.setAddress(dto.getAddress());
        card.setPosition(dto.getPosition());
        card.setStyle(dto.getStyle());
        card.setFacebook(dto.getFacebook());
        card.setInstagram(dto.getInstagram());
        card.setLine(dto.getLine());
        card.setThreads(dto.getThreads());
        card.setFacebookUrl(dto.getFacebookUrl());
        card.setInstagramUrl(dto.getInstagramUrl());
        card.setLineUrl(dto.getLineUrl());
        card.setThreadsUrl(dto.getThreadsUrl());
        card.setIsPublic(dto.getIsPublic());
        card.setAvatarUrl(dto.getAvatarUrl());
    }

    public static Card toEntity(CardRequestDto dto, User user) {
        Card card = new Card();
        card.setUser(user);
        updateEntity(card, dto);
        return card;
    }
}
