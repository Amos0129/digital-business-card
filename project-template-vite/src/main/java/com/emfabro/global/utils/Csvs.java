package com.emfabro.global.utils;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Base64;
import java.util.List;
import java.util.stream.Stream;

import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

public class Csvs {
    private static final String DATETIME_FORMAT = "yyyy-MM-dd HH:mm:ss";

    public interface CsvDomain<T> {
        T exec(CSVRecord csvRecord);
    }

    public static <T> List<T> read(File file, CsvDomain<T> transFunc, Charset charset, boolean isSkipHeader)
            throws IOException {
        try (FileInputStream fis = new FileInputStream(file);
                ByteArrayInputStream bis = new ByteArrayInputStream(fis.readAllBytes());
                CSVParser parser = CSVParser.parse(bis, charset, CSVFormat.DEFAULT)) {
            return convert(transFunc, parser, isSkipHeader);
        }
    }

    public static <T> List<T> read(String base64, CsvDomain<T> transFunc, Charset charset, boolean isSkipHeader)
            throws IOException {
        try (CSVParser parser = CSVParser.parse(new ByteArrayInputStream(Base64.getDecoder().decode(base64)),
                                                charset, CSVFormat.DEFAULT)) {
            return convert(transFunc, parser, isSkipHeader);
        }
    }

    private static <T> List<T> convert(CsvDomain<T> transFunc, CSVParser parser, boolean isSkipHeader) {
        return preProcess(parser.getRecords().stream(), isSkipHeader)
                .map(Lambdas.ofFunc(transFunc::exec))
                .toList();
    }

    private static <T> Stream<T> preProcess(Stream<T> stream, boolean isSkipHeader) {
        return isSkipHeader ? stream.skip(1) : stream;
    }

    public static <T> void write(List<T> target, File output, Class<T> claz) throws IOException {
        try (SequenceWriter writer = createWriter(claz).writeValues(output)) {

            writer.writeAll(target);
        }
    }

    private static <T> ObjectWriter createWriter(Class<T> claz) {
        CsvMapper csvMapper = new CsvMapper();

        csvMapper.setDateFormat(new SimpleDateFormat(DATETIME_FORMAT));

        return csvMapper.writerFor(claz).with(createSchema(claz));
    }

    private static <T> CsvSchema createSchema(Class<T> claz) {
        CsvSchema.Builder builder = CsvSchema.builder();

        Arrays.stream(claz.getDeclaredFields())
              .forEach(field -> builder.addColumn(field.getName()));

        return builder.build().withHeader();
    }
}
