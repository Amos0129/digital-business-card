package com.emfabro.template.dao;

import com.emfabro.Starter;
import com.emfabro.template.domain.entity.Member;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class MemberDaoTest extends Starter.UnitTester {

    private Member member;

    @Autowired
    private MemberDao.Jpa repo;

    @BeforeEach
    public void setting() {
        member = Member.builder()
                .account("test_account")
                .name("test_name")
                .status((byte) 1)
                .whisper("test_whisper")
                .build();

        member.create("system");

        repo.saveAndFlush(member);
    }

    @Test
    public void findTest() {
        repo.findById(member.getId())
                .ifPresentOrElse(user -> assertEquals(user.getId(), member.getId()), Assertions::fail);
    }

    @AfterEach
    public void destroy() {
        repo.deleteById(member.getId());
    }
}
