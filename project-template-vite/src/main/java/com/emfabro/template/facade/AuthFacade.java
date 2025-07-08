package com.emfabro.template.facade;

import java.security.GeneralSecurityException;

import com.emfabro.template.domain.entity.Member;
import com.emfabro.template.domain.entity.Permission;
import com.emfabro.template.domain.vo.MemberVo;
import com.emfabro.template.service.AuthService;
import com.emfabro.template.service.MemberService;
import com.emfabro.template.service.PermissionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthFacade {
    private final static String CREATOR = "system";

    @Autowired
    private PermissionService permissionService;

    @Autowired
    private MemberService memberService;

    @Autowired
    private AuthService authService;

    @Transactional
    public void initialBasicData(MemberVo.Save params) throws GeneralSecurityException {
        MemberVo.Save save = MemberVo.Save.builder()
                                          .account(params.getAccount())
                                          .name(params.getName())
                                          .build();

        Member member = memberService.create(save, authService.decodeThenSig(params.getAccount(),
                params.getArmour()),
                "system");

        initialPermission(member.getId());

    }

    @Transactional
    public void initialPermission(Long accountId) {
        Permission permission = permissionService.createDefaultPermission();
        permissionService.combinePermissionAndAccount(CREATOR, permission.getId(), accountId);
    }

    public Long countMember() {
        return memberService.countMember();
    }
}
