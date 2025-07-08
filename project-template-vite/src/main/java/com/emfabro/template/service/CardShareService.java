package com.emfabro.template.service;

import com.emfabro.template.dao.CardDao;
import com.emfabro.template.dao.CardShareDao;
import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.CardShare;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CardShareService {

    private final CardShareDao.Jpa cardShareJpa;
    private final CardDao cardJpa;

    public CardShare shareCard(Integer cardId, String email) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("名片不存在"));

        CardShare share = new CardShare();
        share.setCard(card);
        share.setSharedWithEmail(email);
        share.setSharedAt(LocalDateTime.now());

        return cardShareJpa.save(share);
    }

    public List<CardShare> getSharesByCard(Integer cardId) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("名片不存在"));
        return cardShareJpa.findByCardId(card);
    }

    public List<CardShare> getReceivedCardsByEmail(String email) {
        return cardShareJpa.findBySharedWithEmail(email);
    }

    public void deleteSharesByCard(Integer cardId) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("名片不存在"));
        cardShareJpa.deleteByCardId(card);
    }
}
