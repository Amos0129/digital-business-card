package com.emfabro.template.service;

import com.emfabro.template.dao.CardDao;
import com.emfabro.template.dao.UserDao;
import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.User;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.dto.CardRequestDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.apache.commons.io.FilenameUtils;
import java.util.UUID;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CardService {

    private final CardDao cardJpa;
    private final UserDao.Jpa userJpa;
    private final CardDao cardRepository;

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
        existingCard.setFacebookUrl(dto.getFacebookUrl());
        existingCard.setInstagramUrl(dto.getInstagramUrl());
        existingCard.setLineUrl(dto.getLineUrl());
        existingCard.setThreadsUrl(dto.getThreadsUrl());
        existingCard.setIsPublic(dto.getIsPublic());
        existingCard.setAvatarUrl(dto.getAvatarUrl());
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
        card.setFacebookUrl(dto.getFacebookUrl());
        card.setInstagramUrl(dto.getInstagramUrl());
        card.setLineUrl(dto.getLineUrl());
        card.setThreadsUrl(dto.getThreadsUrl());

        card.setAvatarUrl(dto.getAvatarUrl());

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

        if (file.isEmpty()) {
            throw new RuntimeException("檔案為空");
        }

        try {
            // ✅ 統一檔名：card_12.jpg
            String extension = FilenameUtils.getExtension(file.getOriginalFilename());
            String fileName = "card_" + cardId + "." + extension;

            // ✅ 設定路徑
            String rootPath = System.getProperty("user.dir");
            String uploadDir = rootPath + "/uploads/avatars";
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // ✅ 覆蓋同名檔案
            Path filePath = uploadPath.resolve(fileName);
            file.transferTo(filePath.toFile());

            // ✅ 對應靜態資源路徑
            String avatarUrl = "/static/avatars/" + fileName;
            card.setAvatarUrl(avatarUrl);
            card.setUpdatedAt(LocalDateTime.now());
            cardJpa.save(card);

            return avatarUrl;

        } catch (IOException e) {
            throw new RuntimeException("檔案儲存失敗：" + e.getMessage(), e);
        }
    }

    public void clearAvatar(Integer cardId, Integer userId) {
        Card card = cardRepository.findByIdAndUserId(cardId, userId)
                                  .orElseThrow(() -> new RuntimeException("名片不存在或無權限"));

        card.setAvatarUrl(null);
        cardRepository.save(card);
    }
}
