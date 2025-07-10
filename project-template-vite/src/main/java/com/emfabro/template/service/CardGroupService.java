package com.emfabro.template.service;

import com.emfabro.template.dao.CardDao;
import com.emfabro.template.dao.CardGroupDao;
import com.emfabro.template.dao.GroupDao;
import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.CardGroup;
import com.emfabro.template.domain.entity.Group;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.dto.CardGroupDto;
import com.emfabro.template.dto.CardWithGroupDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CardGroupService {

    private final CardGroupDao.Jpa cardGroupJpa;
    private final CardDao cardJpa;
    private final GroupDao.Jpa groupJpa;
    private final GroupService groupService;

    public CardGroupDto getGroupOfCardForUser(Integer userId, Integer cardId) {
        List<CardGroup> groups = cardGroupJpa.findByCardAndUser(cardId, userId);

        // if (groups.isEmpty()) {
        //     throw new RuntimeException("找不到這張卡在使用者的群組中");
        // }

        // ✅ 改成這樣，讓它回傳 null（表示未加入任何群組）
        if (groups.isEmpty()) {
            return null;
        }

        Group group = groups.get(0).getGroup();
        return new CardGroupDto(group.getId(), group.getName());
    }

    public void changeCardGroup(Integer cardId, Integer newGroupId, Integer userId) {
        List<CardGroup> oldGroups = cardGroupJpa.findByCardAndUser(cardId, userId);
        if (oldGroups.isEmpty()) {
            throw new RuntimeException("這張卡片不屬於該使用者（沒有幫這張卡分組過）");
        }

        oldGroups.forEach(cardGroupJpa::delete);

        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("名片不存在"));

        Group group = getGroupOwnedByUser(newGroupId, userId);

        CardGroup newRelation = new CardGroup();
        newRelation.setCard(card);
        newRelation.setGroup(group);
        newRelation.setUser(group.getUser());

        cardGroupJpa.save(newRelation);
    }

    public void addCardToDefaultGroup(Integer cardId, Integer userId) {
        Group defaultGroup = groupService.getDefaultGroup(userId);
        addCardToGroup(cardId, defaultGroup.getId(), userId);
    }

    public CardGroup addCardToGroup(Integer cardId, Integer groupId, Integer userId) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("名片不存在"));
        Group group = getGroupOwnedByUser(groupId, userId);

        CardGroup cardGroup = new CardGroup();
        cardGroup.setCard(card);
        cardGroup.setGroup(group);
        cardGroup.setUser(group.getUser()); // ✅ 補上這一行：設定持有這張卡的人

        return cardGroupJpa.save(cardGroup);
    }

    public void removeCardFromGroup(Integer cardId, Integer groupId, Integer userId) {
        Group group = getGroupOwnedByUser(groupId, userId);
        List<CardGroup> matches = cardGroupJpa.findByCardIdAndGroupId(cardId, groupId);
        matches.forEach(cardGroupJpa::delete);
    }

    public List<CardGroup> getGroupsByCard(Integer cardId) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("名片不存在"));
        return cardGroupJpa.findByCard(card);
    }

    public List<CardGroup> getCardsByGroup(Integer groupId) {
        Group group = groupJpa.findById(groupId)
                              .orElseThrow(() -> new RuntimeException("群組不存在"));
        return cardGroupJpa.findByGroup(group);
    }

    public List<CardWithGroupDto> getCardDetailsByUser(Integer userId) {
        List<CardGroup> cardGroups = cardGroupJpa.findCardGroupsByUserId(userId); // 改成你剛加的！
        return cardGroups.stream()
                         .map(cg -> CardWithGroupDto.from(cg.getCard(), cg.getGroup()))
                         .toList();
    }

    // 🛡️ 私有方法：確保群組歸屬正確
    private Group getGroupOwnedByUser(Integer groupId, Integer userId) {
        Group group = groupJpa.findById(groupId)
                              .orElseThrow(() -> new RuntimeException("群組不存在"));

        if (!group.getUser().getId().equals(userId)) {
            throw new RuntimeException("這個群組不屬於該使用者");
        }

        return group;
    }

    private Card getCardOwnedByUser(Integer cardId, Integer userId) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new RuntimeException("名片不存在"));

        if (!card.getUser().getId().equals(userId)) {
            throw new RuntimeException("這張名片不屬於該使用者");
        }

        return card;
    }
}