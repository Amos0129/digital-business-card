package com.emfabro.global.utils;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Base64;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@AllArgsConstructor
@NoArgsConstructor
public class ExcelReaders {
    private boolean isSkipHeader;
    private boolean isSkipEmptyRow;
    private int sheetIndex;

    public static ExcelReaders init(boolean isSkipHeader, boolean isSkipEmptyRow, int sheetIndex) {
        return new ExcelReaders(isSkipHeader, isSkipEmptyRow, sheetIndex);
    }

    public <T> List<T> read(TransDomain<T> transFunc, File excel) throws IOException {
        try (FileInputStream stream = new FileInputStream(excel)) {
            return convert(transFunc, stream);
        }
    }

    public <T> List<T> read(TransDomain<T> transFunc, String base64) throws Exception {
        try (ByteArrayInputStream stream = new ByteArrayInputStream(Base64.getDecoder().decode(base64))) {
            return convert(transFunc, stream);
        }
    }

    private <S extends InputStream, T> List<T> convert(TransDomain<T> transFunc, S stream)
            throws IOException {
        Sheet sheet = new XSSFWorkbook(stream).getSheetAt(sheetIndex);

        return IntStream.range(isSkipHeader ? 1 : 0, sheet.getLastRowNum() + 1)
                        .mapToObj(sheet::getRow)
                        .filter(row -> !isSkipEmptyRow || row != null)
                        .map(Lambdas.ofFunc(transFunc::exec))
                        .collect(Collectors.toList());
    }

    public static class DataFormatters {
        private static final DataFormatter enFormatter = new DataFormatter(Locale.ENGLISH);
        private static final DataFormatter zhTwFormatter = new DataFormatter(Locale.TRADITIONAL_CHINESE);
        private static final DataFormatter zhCnFormatter = new DataFormatter(Locale.CHINA);

        public static String formatEnCell(Cell cell) {
            return enFormatter.formatCellValue(cell);
        }

        public static String formatZhTwCell(Cell cell) {
            return zhTwFormatter.formatCellValue(cell);
        }

        public static String formatZhCnCell(Cell cell) {
            return zhCnFormatter.formatCellValue(cell);
        }
    }

    public interface TransDomain<T> {
        T exec(Row row) throws Exception;
    }
}
