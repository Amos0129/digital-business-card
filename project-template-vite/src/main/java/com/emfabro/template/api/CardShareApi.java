package com.emfabro.template.api;

import com.emfabro.template.domain.entity.CardShare;
import com.emfabro.template.service.CardShareService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/share")
@RequiredArgsConstructor
public class CardShareApi {

    private final CardShareService cardShareService;

    @PostMapping("/send")
    public CardShare shareCard(@RequestParam Integer cardId,
            @RequestParam String email) {
        return cardShareService.shareCard(cardId, email);
    }

    @GetMapping("/by-card/{cardId}")
    public List<CardShare> getSharesByCard(@PathVariable Integer cardId) {
        return cardShareService.getSharesByCard(cardId);
    }

    @GetMapping("/by-email")
    public List<CardShare> getReceivedCardsByEmail(@RequestParam String email) {
        return cardShareService.getReceivedCardsByEmail(email);
    }

    @DeleteMapping("/by-card/{cardId}")
    public void deleteSharesByCard(@PathVariable Integer cardId) {
        cardShareService.deleteSharesByCard(cardId);
    }
}
