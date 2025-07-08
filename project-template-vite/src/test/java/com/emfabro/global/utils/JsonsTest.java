package com.emfabro.global.utils;

import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;

@Slf4j
public class JsonsTest {
    private static final String JSON_OBJECT =
            "{\"arrParm\":\"arrValue\",\"testElms\": [{\"elmParm1\":\"elm1-1Value\",\"elmParm2\":\"elm1-2Value\"},{\"elmParm1\":\"elm2-1Value\",\"elmParm2\":\"elm2-2Value\"}]}";
    private static final String JSON_LIST =
            "[{\"elmParm1\":\"elm1-1Value\",\"elmParm2\":\"elm1-2Value\"},{\"elmParm1\":\"elm2-1Value\",\"elmParm2\":\"elm2-2Value\"}]";

    @Test
    public void testToObject() throws JsonProcessingException {
        TestArr objectWithList = Jsons.toObject(JSON_OBJECT, TestArr.class);

        log.info(Jsons.toJson(objectWithList));
    }

    @Test
    public void testToObjects() throws JsonProcessingException {
        List<TestElm> testElms = Jsons.toObjects(JSON_LIST, TestElm.class);

        log.info(Jsons.toJson(testElms));
    }

    @NoArgsConstructor
    @AllArgsConstructor
    @Data
    private static class TestArr {
        private String arrParm;
        private List<TestElm> testElms;
    }

    @NoArgsConstructor
    @AllArgsConstructor
    @Data
    private static class TestElm {
        private String elmParm1;
        private String elmParm2;
    }

}
