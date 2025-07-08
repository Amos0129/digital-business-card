package com.emfabro.template.api;

import java.io.IOException;
import java.util.List;

import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.template.domain.vo.LoginVo;
import com.emfabro.template.domain.vo.Option;
import com.emfabro.template.domain.vo.PermissionVo;
import com.emfabro.template.service.PermissionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static com.emfabro.global.constant.WebValues.CSRF_TOKEN;
import static com.emfabro.global.constant.WebValues.PREFIX_PRIV;

@RestController
@RequestMapping(PREFIX_PRIV)
public class PermissionApi {

    @Autowired
    private PermissionService service;

    @GetMapping("/permissions")
    public List<Option> getOptions(@RequestParam(required = false) Long ignoreId) {
        return service.getOptions(ignoreId);
    }

    @GetMapping("/permission/exist")
    public boolean existByName(@RequestParam String name, @RequestParam(required = false) Long ignoreId) {
        return service.isNameExist(name, ignoreId);
    }

    @GetMapping("/permission/{permissionId}")
    public PermissionVo getById(@PathVariable Long permissionId) {
        return service.get(permissionId);
    }

    @PostMapping("/permission")
    public void create(@RequestHeader(CSRF_TOKEN) String csrfToken, @RequestBody PermissionVo.Save save)
            throws IOException, ForbiddenException {
        String account = LoginVo.Header.of(csrfToken).getAccount();

        service.create(save, account);
    }

    @PutMapping("/permission/{permissionId}")
    public void update(@RequestHeader(CSRF_TOKEN) String csrfToken, @PathVariable Long permissionId,
            @RequestBody PermissionVo.Save save) throws IOException, ForbiddenException {
        String account = LoginVo.Header.of(csrfToken).getAccount();

        service.update(permissionId, save, account);
    }

    @DeleteMapping("/permission")
    public void concat(@RequestHeader(CSRF_TOKEN) String csrfToken, @RequestParam Long srcId, @RequestParam Long destId)
            throws IOException, ForbiddenException {
        String account = LoginVo.Header.of(csrfToken).getAccount();

        service.concat(srcId, destId, account);
    }

}
