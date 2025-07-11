package com.emfabro.global.advice;


import java.util.Map;

import com.emfabro.global.exception.BadRequestException;
import com.emfabro.global.exception.ExpectationFailedException;
import com.emfabro.global.exception.ForbiddenException;
import com.emfabro.system.service.Profile;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.InvalidMediaTypeException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import static com.emfabro.global.constant.AdviceValues.PERMISSION_DENIED;
import static com.emfabro.global.constant.AdviceValues.UNKNOWN_FAIL;
import static com.emfabro.system.constant.SystemValues.PROFILE_DEV;
import static com.emfabro.system.constant.SystemValues.PROFILE_LOCAL;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @Autowired
    private Profile profile;

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Object> handleValidationExceptions(MethodArgumentNotValidException ex) {
        String errorMessage = ex.getBindingResult().getFieldErrors().stream()
                                .map(error -> error.getDefaultMessage())
                                .findFirst()
                                .orElse("參數驗證失敗");

        printMsg("參數驗證失敗: {}", ex);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                             .body(Map.of("error", errorMessage));
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<Object> badRequest(BadRequestException e) {
        printMsg("請求失敗: {}", e);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                             .body(Map.of("error", e.getMessage()));
    }

    @ExceptionHandler(ForbiddenException.class)
    public ResponseEntity<Object> forbidden(ForbiddenException e) {
        printMsg("存取被拒: {}", e);

        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                             .body(Map.of("error", PERMISSION_DENIED));
    }

    @ExceptionHandler(ExpectationFailedException.class)
    public ResponseEntity<Object> expectationFailed(ExpectationFailedException e) {
        printMsg("執行失敗: {}", e);

        return ResponseEntity.status(HttpStatus.EXPECTATION_FAILED)
                             .body(Map.of("error", e.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Object> internalServiceError(Exception e) {
        printMsg("未知錯誤: {}", e);

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                             .body(Map.of("error", UNKNOWN_FAIL));
    }

    /**
     * 這是為了避免四科 webInspect 弱掃才加上的
     */
    @ExceptionHandler(InvalidMediaTypeException.class)
    public void internalServiceError(HttpServletResponse response) {
        response.setStatus(HttpStatus.UNSUPPORTED_MEDIA_TYPE.value());
    }

    public void printMsg(String format, Exception e) {
        debugStackTrace(e);
        log.error(format, e.getMessage());
    }

    public void debugStackTrace(Exception e) {
        if (profile.hasProfile(PROFILE_DEV) || profile.hasProfile(PROFILE_LOCAL)) {
            e.printStackTrace();
        }
    }
}
