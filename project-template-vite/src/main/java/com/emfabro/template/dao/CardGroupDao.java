package com.emfabro.template.dao;

import java.util.List;
import java.util.Optional;

import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.CardGroup;
import com.emfabro.template.domain.entity.Group;
import com.emfabro.template.dto.CardDetailDto;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public class CardGroupDao {

    public interface Jpa extends JpaRepository<CardGroup, Integer> {
        List<CardGroup> findByGroup_User_Id(Integer userId);
        List<CardGroup> findByCard(Card card); // 查詢某張名片所屬的群組
        List<CardGroup> findByGroup(Group group); // 查詢某個群組有的名片
        void deleteByCard(Card card); // 刪除某張名片所屬的所有群組關聯
        void deleteByGroup(Group group); // 刪除某個群組所屬的所有名片關聯

        List<CardGroup> findByCardIdAndGroupId(Integer cardId, Integer groupId);

        @Query("""
    SELECT new com.emfabro.template.dto.CardDetailDto(
        c.id, c.name, c.company, c.phone,
        c.email, c.address, c.style,
        c.facebook, c.instagram, c.line, c.threads
    )
    FROM CardGroup cg
    JOIN cg.card c
    WHERE cg.group.user.id = :userId
""")
        List<CardDetailDto> findCardDetailsByUserId(@Param("userId") Integer userId);

        @Query("""
    SELECT cg
    FROM CardGroup cg
    WHERE cg.card.id = :cardId AND cg.group.user.id = :userId
""")
        List<CardGroup> findByCardAndUser(@Param("cardId") Integer cardId, @Param("userId") Integer userId);

        @Query("""
    SELECT cg.group
    FROM CardGroup cg
    WHERE cg.card.id = :cardId
""")
        Optional<Group> findGroupByCardId(@Param("cardId") Integer cardId);
    }
}
