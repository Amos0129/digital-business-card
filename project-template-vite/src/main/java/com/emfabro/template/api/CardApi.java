package com.emfabro.template.api;

import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.dto.CardRequestDto;
import com.emfabro.template.dto.UploadResultDto;
import com.emfabro.template.service.CardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/cards")
@RequiredArgsConstructor
public class CardApi {

    private final CardService cardService;

    // 取得目前登入者的名片清單
    @GetMapping("/my")
    public List<CardDetailDto> getMyCards(@RequestAttribute("userId") Integer userId) {
        return cardService.getCardsByUserId(userId);
    }

    // 建立目前登入者的名片
    @PostMapping("/my")
    public CardDetailDto createMyCard(@RequestAttribute("userId") Integer userId,
            @RequestBody CardRequestDto cardDto) {
        return cardService.createCard(cardDto, userId);
    }

    // 更新指定名片
    @PutMapping("/{cardId}")
    public CardDetailDto updateCard(@PathVariable Integer cardId,
            @RequestBody CardRequestDto cardDto,
            @RequestAttribute("userId") Integer userId) {
        return cardService.updateCard(cardId, cardDto, userId);
    }

    // 刪除名片
    @DeleteMapping("/{cardId}")
    public void deleteCard(@PathVariable Integer cardId,
            @RequestAttribute("userId") Integer userId) {
        cardService.deleteCard(cardId, userId);
    }

    // ✅ 查詢公開的名片（可給其他人看）
    @GetMapping("/user/{userId}/public")
    public List<CardDetailDto> getPublicCardsByUserId(@PathVariable Integer userId) {
        return cardService.getPublicCardsByUserId(userId);
    }

    // ✅ 查詢單一名片（用於掃描 QR code 或分享）
    @GetMapping("/{cardId}")
    public CardDetailDto getCardById(@PathVariable Integer cardId) {
        return cardService.getCardById(cardId);
    }

    @PostMapping("/{cardId}/avatar")
    public UploadResultDto uploadAvatar(
            @PathVariable Integer cardId,
            @RequestParam("file") MultipartFile file,
            @RequestAttribute("userId") Integer userId) {
        String avatarUrl = cardService.uploadAvatar(cardId, file, userId);
        return new UploadResultDto(avatarUrl);
    }

    @PatchMapping("/{cardId}/clear-avatar")
    public void clearAvatar(@PathVariable Integer cardId, @RequestAttribute("userId") Integer userId) {
        cardService.clearAvatar(cardId, userId);
    }
}