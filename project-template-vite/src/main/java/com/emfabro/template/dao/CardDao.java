package com.emfabro.template.dao;

import java.util.List;

import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CardDao extends JpaRepository<Card, Integer> {
    List<Card> findByUser(User user);
    List<Card> findByUserAndIsPublicTrue(User user);
}
