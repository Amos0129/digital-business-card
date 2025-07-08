package com.emfabro.template.api;

import com.emfabro.template.domain.entity.CardGroup;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.dto.CardGroupDto;
import com.emfabro.template.service.CardGroupService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/card-group")
@RequiredArgsConstructor
public class CardGroupApi {

    private final CardGroupService cardGroupService;

    @GetMapping("/user-group-of-card")
    public CardGroupDto getUserGroupOfCard(@RequestAttribute("userId") Integer userId,
            @RequestParam Integer cardId) {
        return cardGroupService.getGroupOfCardForUser(userId, cardId);
    }

    @PutMapping("/change")
    public void changeCardGroup(@RequestParam Integer cardId,
            @RequestParam Integer groupId,
            @RequestAttribute("userId") Integer userId) {
        cardGroupService.changeCardGroup(cardId, groupId, userId);
    }

    @PostMapping("/add-to-default")
    public void addToDefaultGroup(@RequestParam Integer cardId,
            @RequestAttribute("userId") Integer userId) {
        cardGroupService.addCardToDefaultGroup(cardId, userId);
    }

    @PostMapping("/add")
    public CardGroup addCardToGroup(@RequestParam Integer cardId,
            @RequestParam Integer groupId,
            @RequestAttribute("userId") Integer userId) {
        return cardGroupService.addCardToGroup(cardId, groupId, userId);
    }

    @DeleteMapping("/remove")
    public void removeCardFromGroup(@RequestParam Integer cardId,
            @RequestParam Integer groupId,
            @RequestAttribute("userId") Integer userId) {
        cardGroupService.removeCardFromGroup(cardId, groupId, userId);
    }

    @GetMapping("/by-card/{cardId}")
    public List<CardGroup> getGroupsByCard(@PathVariable Integer cardId) {
        return cardGroupService.getGroupsByCard(cardId);
    }

    @GetMapping("/by-group/{groupId}")
    public List<CardDetailDto> getCardsByGroup(@PathVariable Integer groupId) {
        return cardGroupService.getCardsByGroup(groupId).stream()
                               .map(cg -> CardDetailDto.fromEntity(cg.getCard()))
                               .toList();
    }

    @GetMapping("/by-user")
    public List<CardDetailDto> getCardsByUser(@RequestAttribute("userId") Integer userId) {
        return cardGroupService.getCardDetailsByUser(userId);
    }
}
