package com.emfabro.template.dao;

import java.util.List;
import java.util.Optional;
import java.util.function.Function;

import com.emfabro.template.domain.entity.Member;
import com.emfabro.template.domain.vo.MemberVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.SelectProvider;
import org.apache.ibatis.jdbc.SQL;
import org.springframework.data.jpa.repository.JpaRepository;

public class MemberDao {

    public interface Jpa extends JpaRepository<Member, Long> {
        Boolean existsByAccount(String account);

        Optional<Member> findByAccountAndWhisper(String account, String whisper);
    }

    @Mapper
    public interface Mybatis {

        @SelectProvider(type = Schema.class, method = "count")
        Long count(MemberVo.Args args);

        @SelectProvider(type = Schema.class, method = "find")
        List<MemberVo.Query> find(MemberVo.Args args);

        @SelectProvider(type = Schema.class, method = "findById")
        MemberVo.Profile findById(Long memberId);

    }

    public static class Schema {

        public String count(MemberVo.Args args) {
            return query(args).apply("count(1)").toString();
        }

        public String find(MemberVo.Args args) {
            SQL sql = query(args).apply("id, account, name, status");

            return args.ORDER_BY_THEN_LIMIT(sql, "id");
        }

        private Function<String, SQL> query(MemberVo.Args args) {
            return columns -> new SQL() {{
                SELECT(columns);
                FROM("member");
                if (null != args.getAccount()) {
                    WHERE("account LIKE '%' || #{account} || '%'");
                }
                if (null != args.getName()) {
                    WHERE("name LIKE '%' || #{name} || '%'");
                }
                if (null != args.getStatus()) {
                    WHERE("status = #{status}");
                }
            }};
        }

        public String findById() {
            return new SQL() {{
                SELECT("m.account", "m.name", "m.status", "gp.permission_id AS permissionId");
                FROM("member m");
                JOIN("permission_group gp ON m.id = gp.member_id");
                WHERE("m.id = #{memberId}");
            }}.toString();
        }
    }

}
