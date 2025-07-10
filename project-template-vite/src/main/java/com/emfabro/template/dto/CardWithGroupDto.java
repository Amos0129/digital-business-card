package com.emfabro.template.dto;

import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.Group;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class CardWithGroupDto extends CardDetailDto {
    private Integer groupId;
    private String groupName;

    public static CardWithGroupDto from(Card card, Group group) {
        CardWithGroupDto dto = new CardWithGroupDto();
        dto.setId(card.getId());
        dto.setName(card.getName());
        dto.setCompany(card.getCompany());
        dto.setPhone(card.getPhone());
        dto.setEmail(card.getEmail());
        dto.setAddress(card.getAddress());
        dto.setStyle(card.getStyle());
        dto.setFacebook(card.getFacebook());
        dto.setInstagram(card.getInstagram());
        dto.setLine(card.getLine());
        dto.setThreads(card.getThreads());
        dto.setFacebookUrl(card.getFacebookUrl());
        dto.setInstagramUrl(card.getInstagramUrl());
        dto.setLineUrl(card.getLineUrl());
        dto.setThreadsUrl(card.getThreadsUrl());

        dto.setAvatarUrl(card.getAvatarUrl());

        if (group != null) {
            dto.setGroupId(group.getId());
            dto.setGroupName(group.getName());
        }
        return dto;
    }
}
