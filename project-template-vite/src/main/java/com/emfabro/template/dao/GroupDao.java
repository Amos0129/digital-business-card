package com.emfabro.template.dao;

import java.util.List;
import java.util.Optional;

import com.emfabro.template.domain.entity.Group;
import com.emfabro.template.domain.entity.User;
import org.apache.xmlbeans.impl.xb.xsdschema.Public;
import org.springframework.data.jpa.repository.JpaRepository;

public class GroupDao {

    public interface Jpa extends JpaRepository<Group, Integer> {

        List<Group> findByUser(User user);
        Optional<Group> findByUserAndName(User user, String name);
    }
}
