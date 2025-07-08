package com.emfabro.global.exception;

public class ForbiddenException extends Exception {

    public ForbiddenException() {
    }

    public ForbiddenException(String message) {
        super(message);
    }

    public ForbiddenException(Throwable cause) {
        super(cause);
    }
}
