package com.emfabro.global.utils;

import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.Group;
import org.springframework.stereotype.Component;

@Component
public class OwnershipValidator {

    public void checkCardOwner(Card card, Integer userId) {
        if (!card.getUser().getId().equals(userId)) {
            throw new ForbiddenException("這張名片不屬於該使用者");
        }
    }

    public void checkGroupOwner(Group group, Integer userId) {
        if (!group.getUser().getId().equals(userId)) {
            throw new ForbiddenException("這個群組不屬於該使用者");
        }
    }
}
