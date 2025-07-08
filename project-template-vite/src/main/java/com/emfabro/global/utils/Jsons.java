package com.emfabro.global.utils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.List;
import java.util.stream.IntStream;

public abstract class Jsons {
    private static final String DATETIME_FORMAT = "yyyy-MM-dd HH:mm:ss";

    private Jsons() {
    }

    public static ObjectMapper jsonMapper() {
        return new ObjectMapper().findAndRegisterModules()
                                 .setDateFormat(new SimpleDateFormat(DATETIME_FORMAT))
                                 .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
    }

    public static String toJson(Object obj) throws JsonProcessingException {
        return jsonMapper().writeValueAsString(obj);
    }

    public static JsonNode readTree(String json) throws JsonProcessingException {
        return jsonMapper().readTree(json);
    }

    public static <T> T toObject(String json, Class<T> claz) throws JsonProcessingException {
        return jsonMapper().readValue(json, claz);
    }

    public static <T> T toObject(JsonNode tree, Class<T> claz) throws JsonProcessingException {
        return jsonMapper().treeToValue(tree, claz);
    }

    public static <T> List<T> toObjects(String json, Class<T> claz) throws JsonProcessingException {
        JsonNode tree = jsonMapper().readTree(json);

        return tree.isArray() ? transTolist(tree, claz) :
                Collections.singletonList(toObject(tree, claz));
    }

    public static <T> T getObjectByJsonFile(File jsonFile, Class<T> claz) throws IOException {
        byte[] ex = Files.readAllBytes(jsonFile.toPath());
        return jsonMapper().readValue(ex, claz);
    }

    private static <T> List<T> transTolist(JsonNode tree, Class<T> claz) {
        return IntStream.range(0, tree.size())
                        .mapToObj(Lambdas.ofIntFunc(index -> toObject(tree.get(index), claz)))
                        .toList();
    }
}
