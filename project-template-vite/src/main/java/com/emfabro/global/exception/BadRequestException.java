package com.emfabro.global.exception;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class BadRequestException extends Exception {
    private Object code;

    public BadRequestException(String message) {
        super(message);
    }

    public BadRequestException(String message, Byte code) {
        super(message);
        this.code = code;
    }

    public BadRequestException(Throwable cause) {
        super(cause);
    }

}
