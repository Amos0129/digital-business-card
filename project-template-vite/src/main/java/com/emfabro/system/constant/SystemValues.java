package com.emfabro.system.constant;

public interface SystemValues {
    String BASE_COMPONENT = "com.emfabro";
    String BASE_DOMAIN = BASE_COMPONENT + ".**.domain";
    String BASE_DAO = BASE_COMPONENT + ".**.dao";
    String BASE_TYPE_HANDLER = BASE_COMPONENT + ".**.typehandler";

    String PROFILE_DEV = "dev";
    String PROFILE_LOCAL = "local";
    String PROFILE_TEST = "test";
    String PROFILE_UAT = "uat";
    String PROFILE_PROD = "prod";

    String PREFIX_COMMAND = "command.datasource";
    String CQRS_COMMAND = "command";
    String CQRS_SYMBOL = "CQRS";

    String ENTITY_MANAGER_FACTORY = "entityManagerFactory";
    String TRANSACTION_MANAGER = "transactionManager";
}
