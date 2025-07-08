package com.emfabro.template.service;

import com.emfabro.template.dao.CardDao;
import com.emfabro.template.dao.CardGroupDao;
import com.emfabro.template.dao.UserDao;
import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.Group;
import com.emfabro.template.domain.entity.User;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.dto.CardRequestDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CardService {

    private final CardDao cardJpa;
    private final UserDao.Jpa userJpa;
    private final CardGroupDao.Jpa cardGroupJpa;

    public List<CardDetailDto> getCardsByUserId(Integer userId) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new RuntimeException("使用者不存在"));

        return cardJpa.findByUser(user)
                      .stream()
                      .map(card -> {
                          Group group = cardGroupJpa.findGroupByCardId(card.getId()).orElse(null);
                          return CardDetailDto.fromEntity(card, group);
                      })
                      .collect(Collectors.toList());
    }

    public List<CardDetailDto> getPublicCardsByUserId(Integer userId) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new RuntimeException("使用者不存在"));
        return cardJpa.findByUserAndIsPublicTrue(user)
                      .stream()
                      .map(CardDetailDto::fromEntity)
                      .collect(Collectors.toList());
    }

    public CardDetailDto getCardById(Integer cardId) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("找不到該名片"));
        return CardDetailDto.fromEntity(card);
    }

    public CardDetailDto updateCard(Integer cardId, CardRequestDto dto, Integer userId) {
        Card existingCard = cardJpa.findById(cardId)
                                   .orElseThrow(() -> new RuntimeException("名片不存在"));

        if (!existingCard.getUser().getId().equals(userId)) {
            throw new RuntimeException("無權限修改他人的名片");
        }

        existingCard.setName(dto.getName());
        existingCard.setCompany(dto.getCompany());
        existingCard.setPhone(dto.getPhone());
        existingCard.setEmail(dto.getEmail());
        existingCard.setAddress(dto.getAddress());
        existingCard.setPosition(dto.getPosition());
        existingCard.setStyle(dto.getStyle());
        existingCard.setFacebook(dto.getFacebook());
        existingCard.setInstagram(dto.getInstagram());
        existingCard.setLine(dto.getLine());
        existingCard.setThreads(dto.getThreads());
        existingCard.setIsPublic(dto.getIsPublic());
        existingCard.setUpdatedAt(LocalDateTime.now());

        return CardDetailDto.fromEntity(cardJpa.save(existingCard));
    }

    public CardDetailDto createCard(CardRequestDto dto, Integer userId) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new RuntimeException("使用者不存在"));

        Card card = new Card();
        card.setUser(user);
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
        card.setIsPublic(dto.getIsPublic());
        card.setCreatedAt(LocalDateTime.now());
        card.setUpdatedAt(LocalDateTime.now());

        return CardDetailDto.fromEntity(cardJpa.save(card));
    }

    public void deleteCard(Integer cardId, Integer userId) {
        Card existingCard = cardJpa.findById(cardId)
                                   .orElseThrow(() -> new RuntimeException("名片不存在"));

        if (!existingCard.getUser().getId().equals(userId)) {
            throw new RuntimeException("無權限刪除他人的名片");
        }

        cardJpa.deleteById(cardId);
    }
}
