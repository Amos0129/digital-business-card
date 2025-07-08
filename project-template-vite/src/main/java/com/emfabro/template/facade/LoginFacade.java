package com.emfabro.template.facade;

import java.security.GeneralSecurityException;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import com.emfabro.global.constant.WebValues;
import com.emfabro.global.exception.BadRequestException;
import com.emfabro.global.utils.Ciphers;
import com.emfabro.global.utils.Lambdas;
import com.emfabro.system.service.Profile;
import com.emfabro.template.dao.PermissionGroupDao;
import com.emfabro.template.domain.entity.Member;
import com.emfabro.template.domain.entity.PermissionGroup;
import com.emfabro.template.domain.vo.LoginVo;
import com.emfabro.template.domain.vo.PermissionVo;
import com.emfabro.template.service.AuthService;
import com.emfabro.template.service.MemberService;
import com.emfabro.template.service.PermissionService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.Cookie;
import org.apache.commons.lang3.tuple.Pair;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import static com.emfabro.global.constant.WebValues.PREFIX_PRIV;
import static com.emfabro.global.constant.WebValues.PREFIX_PUB;
import static com.emfabro.system.constant.SystemValues.PROFILE_DEV;
import static com.emfabro.template.facade.LoginFacade.CodeBook.ACCOUNT_BLOCK;
import static com.emfabro.template.facade.LoginFacade.CodeBook.ACCOUNT_DISABLE;
import static com.emfabro.template.facade.LoginFacade.CodeBook.ACCOUNT_INVALID;
import static com.emfabro.template.facade.LoginFacade.CodeBook.ACCOUNT_IS_LOCK;
import static com.emfabro.template.facade.LoginFacade.CodeBook.ACCOUNT_NOT_MATCH;
import static com.emfabro.template.facade.LoginFacade.CodeBook.CODE_ACCOUNT_DISABLE;
import static com.emfabro.template.facade.LoginFacade.CodeBook.CODE_ACCOUNT_INVALID;
import static com.emfabro.template.facade.LoginFacade.CodeBook.CODE_ACCOUNT_LOCK;
import static com.emfabro.template.facade.LoginFacade.CodeBook.CODE_ACCOUNT_NOT_MATCH;
import static com.emfabro.template.facade.LoginFacade.CodeBook.WHISPER_IS_NONSENSE;
import static java.nio.charset.StandardCharsets.UTF_8;

@Service
public class LoginFacade {
    private static final ConcurrentHashMap<String, Integer> tryMap = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, LocalDateTime> lockMap = new ConcurrentHashMap<>();

    @Autowired
    private AuthService authService;

    @Autowired
    private MemberService memberService;

    @Autowired
    private PermissionGroupDao.Jpa permissionGroupRepo;

    @Autowired
    private PermissionService permissionService;

    @Autowired
    private Profile profile;

    public AuthService auth() {
        return authService;
    }

    public MemberService member() {
        return memberService;
    }

    public LoginVo.Header getIfVerify(String account, String armour)
            throws GeneralSecurityException, BadRequestException {
        verifyLock(account);

        String whisper = authService.decodeThenSig(account, armour);

        Member memberEntity = memberService.get(account, whisper).orElseThrow(() -> accountNotMatch(account));

        verifyStatus(memberEntity);

        removeTryCount(account);

        return LoginVo.Header.of(memberEntity);
    }

    private void verifyLock(String account) {
        Optional.ofNullable(lockMap.get(account))
                .ifPresent(Lambdas.ofConsumer(lockTime -> {
                    if (lockTime.isAfter(LocalDateTime.now())) {
                        throw new BadRequestException(String.format(ACCOUNT_IS_LOCK, account), CODE_ACCOUNT_LOCK);
                    } else {
                        removeTryCount(account);
                    }
                }));
    }

    private BadRequestException accountNotMatch(String account) {
        Pair<String, Byte> exMsg = memberService.exist(account)
                ? updateTryCount(account)
                : Pair.of(ACCOUNT_NOT_MATCH, CODE_ACCOUNT_NOT_MATCH);

        return new BadRequestException(exMsg.getLeft(), exMsg.getRight());
    }

    private Pair<String, Byte> updateTryCount(String account) {
        Integer tryCount = Optional.ofNullable(tryMap.get(account))
                                   .map(integer -> integer + 1)
                                   .orElse(1);

        tryMap.put(account, tryCount);

        if (tryCount >= 3) {
            lockMap.put(account, LocalDateTime.now().plusMinutes(15));
            return Pair.of(String.format(ACCOUNT_BLOCK, account), CODE_ACCOUNT_LOCK);
        } else {
            return Pair.of(String.format(WHISPER_IS_NONSENSE, account, tryCount), CODE_ACCOUNT_NOT_MATCH);
        }
    }

    private void verifyStatus(Member member) throws BadRequestException {
        if (member.getStatus().equals(Member.Status.DISABLED)) {
            throw new BadRequestException(String.format(ACCOUNT_DISABLE, member.getAccount()), CODE_ACCOUNT_DISABLE);
        } else if (member.getStatus().equals(Member.Status.INVALID)) {
            throw new BadRequestException(String.format(ACCOUNT_INVALID, member.getAccount()), CODE_ACCOUNT_INVALID);
        }
    }

    private void removeTryCount(String account) {
        tryMap.remove(account);
        lockMap.remove(account);
    }

    public Cookie[] genToken(LoginVo.Header header) throws JsonProcessingException, GeneralSecurityException {
        byte[] jsonBinary = new ObjectMapper().writeValueAsString(header).getBytes(UTF_8);

        String b64AccountVo = Base64.getEncoder().encodeToString(jsonBinary);

        String token = Ciphers.GCM.jiami(b64AccountVo, WebValues.TOKEN_AGENT);

        return new Cookie[]{register(token, PREFIX_PUB), register(token, PREFIX_PRIV)};
    }

    public LoginVo.Payload genPayload(LoginVo.Header header) {
        PermissionGroup permissionGroup = permissionGroupRepo.findByMemberId(header.getId());

        PermissionVo permissionVo = permissionService.get(permissionGroup.getPermissionId());

        return new LoginVo.Payload(header, permissionVo);
    }

    private Cookie register(String token, String path) {
        Cookie cookie = new Cookie(WebValues.COOKIE_TOKEN, token);
        cookie.setHttpOnly(true);
        cookie.setSecure(profile.hasntProfile(PROFILE_DEV));
        cookie.setPath(path);
        cookie.setMaxAge(-1);

        return cookie;
    }

    public Cookie expiredCookie(String path) {
        Cookie cookie = new Cookie(WebValues.COOKIE_TOKEN, null);
        cookie.setHttpOnly(true);
        cookie.setSecure(profile.hasntProfile(PROFILE_DEV));
        cookie.setPath(path);
        cookie.setMaxAge(0);
        return cookie;
    }

    public interface CodeBook {
        Byte CODE_ACCOUNT_NOT_MATCH = 1;
        String ACCOUNT_NOT_MATCH = "帳號或密碼有誤";
        String WHISPER_IS_NONSENSE = "帳號 %1$s 輸入錯誤 %2$d 次";

        Byte CODE_ACCOUNT_LOCK = 2;
        String ACCOUNT_BLOCK = "帳號 %1$s 因密碼錯誤遭暫時停用";
        String ACCOUNT_IS_LOCK = "帳號 %1$s 近期嘗試次數過多，請15分鐘後再試";

        Byte CODE_ACCOUNT_DISABLE = 3;
        String ACCOUNT_DISABLE = "帳號 %1$s 被停用";

        Byte CODE_ACCOUNT_INVALID = 4;
        String ACCOUNT_INVALID = "帳號 %1$s 尚未啟用";
    }

    public Cookie renewCookie(String token, String path){
        Cookie cookie = new Cookie(WebValues.COOKIE_TOKEN, token);
        cookie.setHttpOnly(true);
        cookie.setSecure(profile.hasntProfile(PROFILE_DEV));
        cookie.setPath(path);
        cookie.setMaxAge(WebValues.TOKEN_TIME_LIMIT);
        return cookie;
    }

}
