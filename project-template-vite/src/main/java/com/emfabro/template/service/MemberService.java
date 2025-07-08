package com.emfabro.template.service;

import java.util.List;
import java.util.Optional;

import com.emfabro.template.dao.MemberDao;
import com.emfabro.template.domain.Page;
import com.emfabro.template.domain.entity.Member;
import com.emfabro.template.domain.vo.MemberVo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MemberService {

    @Autowired
    private MemberDao.Jpa repo;

    @Autowired
    private MemberDao.Mybatis mapper;

    public Boolean exist(String account) {
        return repo.existsByAccount(account);
    }

    public Optional<Member> get(Long memberId) {
        return repo.findById(memberId);
    }

    public Optional<Member> get(String account, String sigWhisper) {
        return repo.findByAccountAndWhisper(account, sigWhisper);
    }

    public MemberVo.Profile getProfile(Long memberId) {
        return mapper.findById(memberId);
    }

    public Page.Result<List<MemberVo.Query>> getList(MemberVo.Args query) {
        return Page.Result.create(query, mapper::count, mapper::find);
    }

    public Member create(MemberVo.Save save, String whisper, String account) {
        Member saveEntity = Member.builder()
                                  .account(save.getAccount())
                                  .name(save.getName())
                                  .whisper(whisper)
                                  .status(Member.Status.ENABLED)
                                  .build();

        saveEntity.create(account);

        return repo.saveAndFlush(saveEntity);
    }

    public void update(Long memberId, MemberVo.Update update, String account) {
        Member entity = repo.findById(memberId).orElseThrow(() -> new NullPointerException("帳號不存在"));

        entity.setAccount(update.getAccount());
        entity.setName(update.getName());
        entity.setStatus(update.getStatus());
        entity.update(account);

        repo.saveAndFlush(entity);
    }

    public void updateWhisper(Member member, String whisper, String account) {
        member.setWhisper(whisper);
        member.update(account);

        repo.saveAndFlush(member);
    }

    public Long countMember() {
        return repo.count();
    }
}

