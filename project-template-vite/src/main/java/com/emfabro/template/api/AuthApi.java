package com.emfabro.template.api;

import java.security.GeneralSecurityException;
import java.util.Arrays;

import com.emfabro.global.constant.WebValues;
import com.emfabro.global.exception.BadRequestException;
import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.global.utils.Lambdas;
import com.emfabro.template.domain.vo.LoginVo;
import com.emfabro.template.domain.vo.MemberVo;
import com.emfabro.template.facade.AuthFacade;
import com.emfabro.template.facade.LoginFacade;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static com.emfabro.global.constant.WebValues.PREFIX_PRIV;
import static com.emfabro.global.constant.WebValues.PREFIX_PUB;
import static com.emfabro.global.constant.AdviceValues.TOKEN_NOT_FOUND;

@RestController
@RequestMapping
public class AuthApi {

    @Autowired
    private LoginFacade facade;

    @Autowired
    private AuthFacade authFacade;

    @PostMapping("/pub/login")
    public LoginVo.Payload login(HttpServletResponse resp, @RequestBody LoginVo loginVo)
            throws GeneralSecurityException, BadRequestException, JsonProcessingException {
        LoginVo.Header header = facade.getIfVerify(loginVo.getAccount(), loginVo.getArmour());

        for (Cookie cookie : facade.genToken(header)) {
            resp.addCookie(cookie);
        }

        return facade.genPayload(header);
    }

    @GetMapping("/priv/logout")
    public void logout(HttpServletResponse resp) {
        resp.addCookie(facade.expiredCookie(PREFIX_PUB));
        resp.addCookie(facade.expiredCookie(PREFIX_PRIV));
    }

    @Scheduled(fixedDelay = 5000L)
    public void cleanKeyPair() {
        facade.auth().removeAuthPairIfExpired();
    }

    @GetMapping("/pub/steel")
    public String getPubKey(@RequestParam String account) {
        return facade.auth().genKeyPair(account).getPub();
    }

    @GetMapping("/pub/token/knock")
    public LoginVo.Payload knockSelf(HttpServletRequest req, HttpServletResponse resp) {
        return facade.auth()
                     .findToken(req.getCookies())
                     .map(Lambdas.ofFunc(cookie -> {
                         byte[] content = facade.auth().detectSigToken(cookie.getValue());

                         return new ObjectMapper().readValue(content, LoginVo.Header.class);
                     }))
                     .filter(header -> facade.member().exist(header.getAccount()))
                     .map(facade::genPayload)
                     .orElseGet(() -> {
                         resp.addCookie(facade.expiredCookie(PREFIX_PUB));
                         resp.addCookie(facade.expiredCookie(PREFIX_PRIV));
                         return null;
                     });
    }

    @GetMapping("/pub/account/count")
    public Long countAccount() {
        return authFacade.countMember();
    }

    @PostMapping("/pub/account/init")
    public void initialNecessaryData(@RequestBody MemberVo.Save params)
            throws GeneralSecurityException, BadRequestException {

        if(authFacade.countMember() == 0) {
            authFacade.initialBasicData(params);
        } else {
            throw new BadRequestException("fail");
        }
    }

    @GetMapping("/priv/keepHeartBeat")
    public void keepHeartBeat(HttpServletRequest req, HttpServletResponse resp) throws ForbiddenException {
        Cookie cookie =
                Arrays.stream(req.getCookies())
                      .filter(p -> p.getName()
                                    .equals(WebValues.COOKIE_TOKEN))
                      .findFirst()
                      .orElseThrow(() -> new ForbiddenException(TOKEN_NOT_FOUND));
        String token = cookie.getValue();
        resp.addCookie(facade.renewCookie(token , PREFIX_PRIV));
        resp.addCookie(facade.renewCookie(token , PREFIX_PUB));
    }

}
