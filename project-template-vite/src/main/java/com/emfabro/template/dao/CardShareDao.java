package com.emfabro.template.dao;

import java.util.List;

import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.CardShare;
import org.springframework.data.jpa.repository.JpaRepository;

public class CardShareDao {

    public interface Jpa extends JpaRepository<CardShare, Integer> {

        List<CardShare> findByCardId(Card card); // 查這張名片被誰分享
        List<CardShare> findBySharedWithEmail(String sharedWithMail); // 這個人收到哪些名片
        void deleteByCardId(Card card); // 刪除某張名片的所有分享紀錄
    }
}
