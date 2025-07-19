package com.emfabro.template.api;

import com.emfabro.template.domain.entity.CardGroup;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.dto.CardGroupDto;
import com.emfabro.template.dto.CardWithGroupDto;
import com.emfabro.template.service.CardGroupService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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

    @PostMapping("/change")  // 修正：改為 POST 並接收 JSON
    public void changeCardGroup(@RequestBody Map<String, Integer> request,
                                @RequestAttribute("userId") Integer userId) {
        Integer cardId = request.get("cardId");
        Integer groupId = request.get("groupId");
        cardGroupService.changeCardGroup(cardId, groupId, userId);
    }

    @PostMapping("/add-to-default")
    public void addToDefaultGroup(@RequestBody Map<String, Integer> request,
                                  @RequestAttribute("userId") Integer userId) {
        Integer cardId = request.get("cardId");
        cardGroupService.addCardToDefaultGroup(cardId, userId);
    }

    @PostMapping("/add")
    public CardGroup addCardToGroup(@RequestBody Map<String, Integer> request,
                                    @RequestAttribute("userId") Integer userId) {
        Integer cardId = request.get("cardId");
        Integer groupId = request.get("groupId");
        return cardGroupService.addCardToGroup(cardId, groupId, userId);
    }

    @PostMapping("/remove")  // 修正：改為 POST 並接收 JSON
    public void removeCardFromGroup(@RequestBody Map<String, Integer> request,
                                    @RequestAttribute("userId") Integer userId) {
        Integer cardId = request.get("cardId");
        Integer groupId = request.get("groupId");
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
    public List<CardWithGroupDto> getCardsByUser(@RequestAttribute("userId") Integer userId) {
        return cardGroupService.getCardDetailsByUser(userId);
    }
}