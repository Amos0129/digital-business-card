package com.emfabro.global.exception;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ExpectationFailedException extends RuntimeException {

    public ExpectationFailedException(String message) {
        super(message);
    }

    public ExpectationFailedException(Throwable cause) {
        super(cause);
    }
}
