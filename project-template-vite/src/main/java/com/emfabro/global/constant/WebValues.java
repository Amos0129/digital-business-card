package com.emfabro.global.constant;

public interface WebValues {
    String PREFIX_PRIV = "/priv";
    String PREFIX_PUB = "/pub";

    //TODO: 記得修改 token name
    String CSRF_TOKEN = "x-template-csrf";
    String COOKIE_TOKEN = "x-template-sig";

    //TODO: 記得要修改加密用的密碼
    String TOKEN_AGENT = "0123456789012345";
    String WHISPER_AGENT = "otaku-here";

    //TODO:登入Token的時限(單位:秒)
    Integer TOKEN_TIME_LIMIT = 60 * 30; //30分鐘

}
