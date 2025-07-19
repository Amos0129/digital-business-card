package com.emfabro.template.api;

import java.util.List;
import java.util.Map;

import com.emfabro.template.domain.entity.Group;
import com.emfabro.template.dto.CardDetailDto;
import com.emfabro.template.service.CardGroupService;
import com.emfabro.template.service.GroupService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/group")  // 確保路徑一致
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
                        @RequestBody Map<String, String> request) {  // 修正：接收 JSON body
        String name = request.get("name");
        return groupService.createGroup(userId, name);
    }

    @PutMapping("/rename/{groupId}")
    public Group rename(@PathVariable Integer groupId,
                        @RequestBody Map<String, String> request,  // 修正：接收 JSON body
                        @RequestAttribute("userId") Integer userId) {
        String newName = request.get("name");
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
