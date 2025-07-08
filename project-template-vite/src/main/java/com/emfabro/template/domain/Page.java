package com.emfabro.template.domain;

import java.util.function.Function;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;
import org.apache.commons.lang3.StringUtils;
import org.apache.ibatis.jdbc.SQL;

import static org.apache.commons.lang3.StringUtils.EMPTY;


public class Page {
    private Page() {}

    @Data
    public static class Args {
        private Integer perPage;
        private Integer current;
        private String order;
        private Boolean desc;

        public String ORDER_BY(String defaultOrder) {
            if (StringUtils.isNotEmpty(order)) {
                order = order.replaceAll("-", EMPTY)
                        .replaceAll(";", EMPTY)
                        .replaceAll("'", EMPTY)
                        .replaceAll("\"", EMPTY);

                return String.format(" ORDER BY %s %s ", order, orderRule());
            } else {
                return String.format(" ORDER BY %s ", defaultOrder);
            }
        }

        public SQL ORDER_BY(SQL sql, String defaultOrder) {
            if (StringUtils.isNotEmpty(order)) {
                order = order.replaceAll("-", EMPTY)
                        .replaceAll(";", EMPTY)
                        .replaceAll("'", EMPTY)
                        .replaceAll("\"", EMPTY);
                sql.ORDER_BY(order + " " + orderRule());
            } else {
                sql.ORDER_BY(defaultOrder);
            }
            return sql;
        }

        public String LIMIT() {
            return " LIMIT #{perPage} OFFSET (#{perPage} * #{current}) ";
        }

        public String LIMIT(SQL sql) {
            return sql.toString() + LIMIT();
        }

        private String orderRule() {
            return desc ? "DESC" : "ASC";
        }

        public String ORDER_BY_THEN_LIMIT(SQL sql, String defaultOrder) {
            return LIMIT(ORDER_BY(sql, defaultOrder));
        }
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Result<ResultVo> {
        private Long count;
        private ResultVo body;

        public static <T, ResultVo> Result<ResultVo> create(T t, Function<T, Long> count, Function<T, ResultVo> body) {
            return new Result<>(count.apply(t), body.apply(t));
        }
    }
}
