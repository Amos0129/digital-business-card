package com.emfabro.template.api;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;

import com.emfabro.global.exception.BadRequestException;
import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.template.domain.Page;
import com.emfabro.template.domain.entity.Member;
import com.emfabro.template.domain.vo.LoginVo;
import com.emfabro.template.domain.vo.MemberVo;
import com.emfabro.template.service.AuthService;
import com.emfabro.template.service.MemberService;
import com.emfabro.template.service.PermissionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
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
public class MemberApi {

    @Autowired
    private MemberService memberService;

    @Autowired
    private AuthService authService;

    @Autowired
    private PermissionService permissionService;

    @GetMapping("/members")
    public Page.Result<List<MemberVo.Query>> query(MemberVo.Args args) {
        return memberService.getList(args);
    }

    @GetMapping("/member")
    public Boolean existByName(@RequestParam String account) {
        return memberService.exist(account);
    }

    @GetMapping("/member/{memberId}")
    public MemberVo.Profile queryOne(@PathVariable Long memberId) {
        return memberService.getProfile(memberId);
    }

    @PostMapping("/member")
    public void create(@RequestHeader(CSRF_TOKEN) String csrfToken, @RequestBody MemberVo.Save save)
            throws IOException, ForbiddenException, GeneralSecurityException {
        String account = LoginVo.Header.of(csrfToken).getAccount();

        String whisper = authService.decodeThenSig(save.getAccount(), save.getArmour());

        createMember(save, whisper, account);
    }

    @Transactional
    public void createMember(MemberVo.Save save, String whisper, String account) {
        Member newEntity = memberService.create(save, whisper, account);

        permissionService.reInsertGroup(newEntity.getId(), save.getPermissionId(), account);
    }

    @PutMapping("/member/{memberId}")
    public void update(@RequestHeader(CSRF_TOKEN) String csrfToken, @PathVariable Long memberId,
            @RequestBody MemberVo.Update update) throws IOException, ForbiddenException {
        String account = LoginVo.Header.of(csrfToken).getAccount();

        updateMember(memberId, update, account);
    }

    @Transactional
    public void updateMember(Long memberId, MemberVo.Update update, String account) {
        memberService.update(memberId, update, account);

        permissionService.reInsertGroup(memberId, update.getPermissionId(), account);
    }

    @PutMapping("/member/{memberId}/whisper")
    public void updateWhisper(@RequestHeader(CSRF_TOKEN) String csrfToken, @PathVariable Long memberId,
            @RequestBody MemberVo.ChangeWhisper update) throws IOException, ForbiddenException,
            GeneralSecurityException, BadRequestException {
        String account = LoginVo.Header.of(csrfToken).getAccount();

        Member entity = memberService.get(memberId).orElseThrow(() -> new NullPointerException("帳號不存在"));

        String oldWhisper = authService.decodeThenSig(update.getAccount(), update.getArmour1());

        if (entity.getWhisper().equals(oldWhisper)) {
            String newWhisper = authService.decodeThenSig(update.getAccount(), update.getArmour2());
            memberService.updateWhisper(entity, newWhisper, account);
        } else {
            throw new BadRequestException("舊密碼錯誤");
        }
    }
}
