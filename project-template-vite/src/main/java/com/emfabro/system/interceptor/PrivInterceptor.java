package com.emfabro.system.interceptor;

import java.util.Base64;
import java.util.Optional;

import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.system.filter.wrapper.CustomWrapper;
import com.emfabro.template.service.AuthService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import static com.emfabro.global.constant.AdviceValues.PERMISSION_DENIED;
import static com.emfabro.global.constant.AdviceValues.TOKEN_NOT_FOUND;
import static com.emfabro.global.constant.WebValues.CSRF_TOKEN;

@Component
public class PrivInterceptor implements HandlerInterceptor {

    @Autowired
    private AuthService authService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws ForbiddenException {
        try {
            CustomWrapper wrapper = new CustomWrapper(request, response);

            Cookie cookie = authService.findToken(wrapper.customReq.getCookies())
                                       .orElseThrow(() -> new ForbiddenException(TOKEN_NOT_FOUND));

            String sigTokenPayload = new String(authService.detectSigToken(cookie.getValue()));

            String csrfPayload = detectCsrfToken(wrapper.customReq.getHeader(CSRF_TOKEN));

            return sigTokenPayload.equals(csrfPayload);
        } catch (ForbiddenException e) {
            throw e;
        } catch (Exception e) {
            throw new ForbiddenException(e);
        }
    }

    private String detectCsrfToken(String csrfToken) throws ForbiddenException {
        String b64Csrf = Optional.ofNullable(csrfToken)
                                 .orElseThrow(() -> new ForbiddenException(PERMISSION_DENIED));

        return new String(Base64.getDecoder().decode(b64Csrf));
    }
}
