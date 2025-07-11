package com.emfabro.template.service;

import com.emfabro.global.exception.NotFoundException;
import com.emfabro.global.utils.OwnershipValidator;
import com.emfabro.template.dao.GroupDao;
import com.emfabro.template.dao.UserDao;
import com.emfabro.template.dao.CardGroupDao;
import com.emfabro.template.domain.entity.Group;
import com.emfabro.template.domain.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GroupService {

    private final GroupDao.Jpa groupJpa;
    private final UserDao.Jpa userJpa;
    private final CardGroupDao.Jpa cardGroupJpa;
    private final OwnershipValidator ownershipValidator;

    public Group getDefaultGroup(Integer userId) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new NotFoundException("使用者不存在"));

        return groupJpa.findByUserAndName(user, "全部")
                       .orElseThrow(() -> new NotFoundException("找不到預設群組"));
    }

    public Group createGroup(Integer userId, String groupName) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new NotFoundException("使用者不存在"));

        Group group = new Group();
        group.setUser(user);
        group.setName(groupName);

        return groupJpa.save(group);
    }

    public Group renameGroup(Integer groupId, String newName, Integer userId) {
        Group group = groupJpa.findById(groupId)
                              .orElseThrow(() -> new NotFoundException("群組不存在"));

        ownershipValidator.checkGroupOwner(group, userId);

        group.setName(newName);
        return groupJpa.save(group);
    }

    public List<Group> getGroupsByUser(Integer userId) {
        User user = userJpa.findById(userId)
                           .orElseThrow(() -> new NotFoundException("使用者不存在"));
        return groupJpa.findByUser(user);
    }

    public void deleteGroup(Integer groupId, Integer userId) {
        Group group = groupJpa.findById(groupId)
                              .orElseThrow(() -> new NotFoundException("群組不存在"));

        ownershipValidator.checkGroupOwner(group, userId);

        cardGroupJpa.deleteByGroup(group);
        groupJpa.delete(group);
    }
}
