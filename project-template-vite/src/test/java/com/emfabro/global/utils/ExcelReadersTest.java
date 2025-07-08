package com.emfabro.global.utils;

import java.io.File;
import java.util.List;

import com.emfabro.test.utils.Commons;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.Row;
import org.junit.jupiter.api.Test;

@Slf4j
public class ExcelReadersTest {
    @Test
    public void test() throws Exception {
        File excelFile = Commons.getTestResource().resolve("xlsx").resolve("test.xlsx").toFile();

        List<TestClass> classes = ExcelReaders.init(true, true , 0)
                                              .read(this::trans, excelFile);

      log.info(Jsons.toJson(classes));
    }

    public TestClass trans(Row row) {
        return TestClass.builder()
                        .serial(ExcelReaders.DataFormatters.formatZhTwCell(row.getCell(0)))
                        .name(ExcelReaders.DataFormatters.formatZhTwCell(row.getCell(1)))
                        .stock((int) row.getCell(2).getNumericCellValue())
                        .safetyStock((int) row.getCell(3).getNumericCellValue())
                        .build();
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TestClass {
        private String serial;
        private String name;
        private Integer stock;
        private Integer safetyStock;
    }
}

