package com.emfabro.template.service;

import com.emfabro.global.utils.OwnershipValidator;
import com.emfabro.template.dao.CardDao;
import com.emfabro.template.dao.CardGroupDao;
import com.emfabro.template.dao.GroupDao;
import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.CardGroup;
import com.emfabro.template.domain.entity.Group;
import com.emfabro.template.dto.CardGroupDto;
import com.emfabro.template.dto.CardWithGroupDto;
import com.emfabro.global.exception.NotFoundException;
import com.emfabro.global.exception.ForbiddenException;
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
    private final OwnershipValidator ownershipValidator;

    public CardGroupDto getGroupOfCardForUser(Integer userId, Integer cardId) {
        List<CardGroup> groups = cardGroupJpa.findByCardAndUser(cardId, userId);
        if (groups.isEmpty()) {
            return null;
        }

        Group group = groups.get(0).getGroup();
        return new CardGroupDto(group.getId(), group.getName());
    }

    public void changeCardGroup(Integer cardId, Integer newGroupId, Integer userId) {
        List<CardGroup> oldGroups = cardGroupJpa.findByCardAndUser(cardId, userId);
        if (oldGroups.isEmpty()) {
            throw new ForbiddenException("這張卡片不屬於該使用者（沒有幫這張卡分組過）");
        }

        oldGroups.forEach(cardGroupJpa::delete);

        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new NotFoundException("名片不存在"));

        Group group = groupJpa.findById(newGroupId)
                              .orElseThrow(() -> new NotFoundException("群組不存在"));

        ownershipValidator.checkGroupOwner(group, userId);

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
                           .orElseThrow(() -> new NotFoundException("名片不存在"));
        Group group = groupJpa.findById(groupId)
                              .orElseThrow(() -> new NotFoundException("群組不存在"));

        ownershipValidator.checkGroupOwner(group, userId);

        CardGroup cardGroup = new CardGroup();
        cardGroup.setCard(card);
        cardGroup.setGroup(group);
        cardGroup.setUser(group.getUser());

        return cardGroupJpa.save(cardGroup);
    }

    public void removeCardFromGroup(Integer cardId, Integer groupId, Integer userId) {
        Group group = groupJpa.findById(groupId)
                              .orElseThrow(() -> new NotFoundException("群組不存在"));

        ownershipValidator.checkGroupOwner(group, userId);

        List<CardGroup> matches = cardGroupJpa.findByCardIdAndGroupId(cardId, groupId);
        matches.forEach(cardGroupJpa::delete);
    }

    public List<CardGroup> getGroupsByCard(Integer cardId) {
        Card card = cardJpa.findById(cardId)
                           .orElseThrow(() -> new NotFoundException("名片不存在"));
        return cardGroupJpa.findByCard(card);
    }

    public List<CardGroup> getCardsByGroup(Integer groupId) {
        Group group = groupJpa.findById(groupId)
                              .orElseThrow(() -> new NotFoundException("群組不存在"));
        return cardGroupJpa.findByGroup(group);
    }

    public List<CardWithGroupDto> getCardDetailsByUser(Integer userId) {
        List<CardGroup> cardGroups = cardGroupJpa.findCardGroupsByUserId(userId);
        return cardGroups.stream()
                         .map(cg -> CardWithGroupDto.from(cg.getCard(), cg.getGroup()))
                         .toList();
    }
}