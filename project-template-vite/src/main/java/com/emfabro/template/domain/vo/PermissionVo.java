package com.emfabro.template.domain.vo;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PermissionVo {
    private List<Item> page;
    private List<Item> feature;

    @Getter
    @Setter
    public static class Save {
        private String name;
        private List<Item> page;
        private List<Item> feature;
    }

    @Getter
    @Setter
    public static class Item {
        private String name;
    }
}
