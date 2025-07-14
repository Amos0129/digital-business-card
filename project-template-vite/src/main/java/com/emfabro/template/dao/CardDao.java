package com.emfabro.template.dao;

import java.util.List;
import java.util.Optional;

import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.User;
import org.apache.ibatis.annotations.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface CardDao extends JpaRepository<Card, Integer> {
    List<Card> findByUser(User user);
    List<Card> findByUserAndIsPublicTrue(User user);
    Optional<Card> findByIdAndUserId(Integer cardId, Integer userId);

    @Query("SELECT c FROM Card c " +
           "WHERE c.isPublic = true AND " +
           "(LOWER(c.name) LIKE :keyword OR LOWER(c.company) LIKE :keyword)")
    List<Card> searchPublicCardsByKeyword(@Param("keyword") String keyword);

    // ✅ 撈出所有公開名片（無搜尋條件）
    List<Card> findByIsPublicTrue();
}
