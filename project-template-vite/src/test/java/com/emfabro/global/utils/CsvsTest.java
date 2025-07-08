package com.emfabro.global.utils;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import com.emfabro.test.utils.Commons;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.csv.CSVRecord;
import org.junit.jupiter.api.Test;

@Slf4j
public class CsvsTest {
    @Test
    public void testRead() throws Exception {
        File csvFile = Commons.getTestResource().resolve("csv")
                              .resolve("test.csv")
                              .toFile();

        log.info(Jsons.toJson(Csvs.read(csvFile, this::transFunc, StandardCharsets.UTF_8, true)));
    }

    private Product transFunc(CSVRecord csvRecord) {
        return Product.builder()
                      .serial(csvRecord.get(0))
                      .name(csvRecord.get(1))
                      .stock(csvRecord.get(2))
                      .safetyStock(csvRecord.get(3))
                      .build();
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Product {
        private String serial;
        private String name;
        private String stock;
        private String safetyStock;
    }

    @Test
    public void testWrite() throws Exception {
        File output = Commons.getTestResource().resolve("csv").resolve("output.csv").toFile();

        List<Product> contents = Arrays.asList(create(), create());

        Csvs.write(contents, output, Product.class);
    }

    private Product create() {
        return Product.builder()
                      .serial(UUID.randomUUID().toString())
                      .name("測識產品")
                      .stock("17")
                      .safetyStock("10")
                      .build();
    }
}
