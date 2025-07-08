package com.emfabro.template.dao;

import java.util.List;
import java.util.Optional;

import com.emfabro.template.domain.entity.Permission;
import com.emfabro.template.domain.vo.Option;
import com.emfabro.template.domain.vo.PermissionVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.SelectProvider;
import org.apache.ibatis.jdbc.SQL;
import org.springframework.data.jpa.repository.JpaRepository;

public class PermissionDao {

    public interface Jpa extends JpaRepository<Permission, Long> {
        Optional<Permission> findByName(String name);
    }

    @Mapper
    public interface Mybatis {
        @SelectProvider(type = Schema.class,
                method = "findPermission")
        List<Option> findPermission(Long ignoreId);

        @SelectProvider(type = Schema.class,
                method = "exist")
        Integer exist(String name, Long ignoreId);

        @SelectProvider(type = Schema.class,
                method = "findItem")
        List<PermissionVo.Item> findItem(Long permissionId, Byte type);

    }

    public static class Schema {
        public String findPermission(Long ignoreId) {
            return new SQL() {{
                SELECT("id", "name");
                FROM("permission");
                if (ignoreId != null) {
                    WHERE("id <> #{ignoreId}");
                }
                ORDER_BY("id");
            }}.toString();
        }

        public String exist(String name, Long ignoreId) {
            return new SQL() {{
                SELECT("count(1)");
                FROM("permission");
                WHERE("name = #{name}");
                if (ignoreId != null) {
                    WHERE("id <> #{ignoreId}");
                }
            }}.toString();
        }

        public String findItem() {
            return new SQL() {{
                SELECT("name");
                FROM("permission_item");
                WHERE("permission_id = #{permissionId}");
                WHERE("type = #{type}");
            }}.toString();
        }
    }
}
