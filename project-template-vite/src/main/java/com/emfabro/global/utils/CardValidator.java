package com.emfabro.global.utils;

import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.global.exception.NotFoundException;
import com.emfabro.template.dao.CardDao;
import com.emfabro.template.dao.UserDao;
import com.emfabro.template.domain.entity.Card;
import com.emfabro.template.domain.entity.User;

public class CardValidator {

    public static User getUserOrThrow(UserDao.Jpa userDao, Integer userId) {
        return userDao.findById(userId)
                      .orElseThrow(() -> new NotFoundException("使用者不存在"));
    }

    public static Card getCardOrThrow(CardDao cardDao, Integer cardId) {
        return cardDao.findById(cardId)
                      .orElseThrow(() -> new NotFoundException("名片不存在"));
    }

    public static void assertOwned(Card card, Integer userId) {
        if (!card.getUser().getId().equals(userId)) {
            throw new ForbiddenException("無權限操作該名片");
        }
    }
}
