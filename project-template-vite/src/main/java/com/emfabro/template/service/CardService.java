package com.emfabro.template.service;

import com.emfabro.template.dao.CardDao;
import com.emfabro.template.dao.UserDao;
import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.User;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.dto.CardRequestDto;
import com.emfabro.template.mapper.CardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CardService {

    private final CardDao cardJpa;
    private final UserDao.Jpa userJpa;
    private final CardDao cardRepository;
    private final AvatarStorageService avatarStorageService;

    public List<CardDetailDto> getCardsByUserId(Integer userId) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new RuntimeException("使用者不存在"));
        return cardJpa.findByUser(user)
                      .stream()
                      .map(CardDetailDto::fromEntity)
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

        CardMapper.updateEntity(existingCard, dto);
        existingCard.setUpdatedAt(LocalDateTime.now());

        return CardDetailDto.fromEntity(cardJpa.save(existingCard));
    }

    public CardDetailDto createCard(CardRequestDto dto, Integer userId) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new RuntimeException("使用者不存在"));

        Card card = CardMapper.toEntity(dto, user);
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

    public String uploadAvatar(Integer cardId, MultipartFile file, Integer userId) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("名片不存在"));

        if (!card.getUser().getId().equals(userId)) {
            throw new RuntimeException("無權限上傳此名片的頭像");
        }

        String avatarUrl = avatarStorageService.save(cardId, file);

        card.setAvatarUrl(avatarUrl);
        card.setUpdatedAt(LocalDateTime.now());
        cardJpa.save(card);

        return avatarUrl;
    }

    public void clearAvatar(Integer cardId, Integer userId) {
        Card card = cardRepository.findByIdAndUserId(cardId, userId)
                                  .orElseThrow(() -> new RuntimeException("名片不存在或無權限"));

        card.setAvatarUrl(null);
        cardRepository.save(card);
    }
}
