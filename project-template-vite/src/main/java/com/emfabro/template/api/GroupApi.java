package com.emfabro.template.api;

import java.util.List;

import com.emfabro.template.domain.entity.Group;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.service.CardGroupService;
import com.emfabro.template.service.GroupService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/group")
@RequiredArgsConstructor
public class GroupApi {

    private final GroupService groupService;
    private final CardGroupService cardGroupService;

    @GetMapping("/default")
    public Group getDefaultGroup(@RequestAttribute("userId") Integer userId) {
        return groupService.getDefaultGroup(userId);
    }

    @PostMapping("/create")
    public Group create(@RequestAttribute("userId") Integer userId,
            @RequestParam String name) {
        return groupService.createGroup(userId, name);
    }

    @PutMapping("/rename/{groupId}")
    public Group rename(@PathVariable Integer groupId,
            @RequestParam String newName,
            @RequestAttribute("userId") Integer userId) {
        return groupService.renameGroup(groupId, newName, userId);
    }

    @GetMapping("/by-user")
    public List<Group> list(@RequestAttribute("userId") Integer userId) {
        return groupService.getGroupsByUser(userId);
    }

    @DeleteMapping("/{groupId}")
    public void delete(@PathVariable Integer groupId,
            @RequestAttribute("userId") Integer userId) {
        groupService.deleteGroup(groupId, userId);
    }
}
