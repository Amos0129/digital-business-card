package com.emfabro.template.service;

import java.util.List;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import com.emfabro.template.dao.PermissionDao;
import com.emfabro.template.dao.PermissionGroupDao;
import com.emfabro.template.dao.PermissionItemDao;
import com.emfabro.template.domain.entity.Permission;
import com.emfabro.template.domain.entity.PermissionGroup;
import com.emfabro.template.domain.entity.PermissionItem;
import com.emfabro.template.domain.vo.Option;
import com.emfabro.template.domain.vo.PermissionVo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PermissionService {

    private final static String DEFAULT_PERMISSION = "預設權限";
    private final static String DEFAULT_PERMISSION_MEMBER = "帳號管理::/members";
    private final static String DEFAULT_PERMISSION_MEMBER_ADD = "建立帳號::/member";
    private final static String DEFAULT_PERMISSION_MEMBER_EDIT = "修改帳號::/member/:memberId";
    private final static String DEFAULT_PERMISSION_PERMISSION = "權限管理::/permissions";


    @Autowired
    private PermissionDao.Jpa permissionRepo;

    @Autowired
    private PermissionDao.Mybatis permissionMapper;

    @Autowired
    private PermissionGroupDao.Jpa groupRepo;

    @Autowired
    private PermissionItemDao.Jpa itemRepo;


    public List<Option> getOptions(Long ignoreId) {
        return permissionMapper.findPermission(ignoreId);
    }

    public boolean isNameExist(String name, Long ignoreId) {
        return permissionMapper.exist(name, ignoreId) > 0;
    }

    public PermissionVo get(Long permissionId) {
        return permissionRepo.findById(permissionId)
                             .map(permission -> {
                                 List<PermissionVo.Item> pages = permissionMapper.findItem(permissionId,
                                                                                           PermissionItem.ItemType.PAGE);

                                 List<PermissionVo.Item> features = permissionMapper.findItem(permissionId,
                                                                                              PermissionItem.ItemType.FEATURE);

                                 return new PermissionVo(pages, features);
                             })
                             .orElseThrow(() -> new NullPointerException("權限不存在"));
    }

    @Transactional
    public void create(PermissionVo.Save saveEntity, String accountName) {
        Permission permission = createPermission(saveEntity.getName(), accountName);

        saveEntity.getPage()
                  .forEach(page -> createPermissionItem(permission.getId(), page.getName(),
                                                        PermissionItem.ItemType.PAGE, accountName));

        saveEntity.getFeature()
                  .forEach(page -> createPermissionItem(permission.getId(), page.getName(),
                                                        PermissionItem.ItemType.FEATURE, accountName));
    }

    private Permission createPermission(String permissionName, String account) {
        Permission permission = new Permission(permissionName);

        permission.create(account);

        return permissionRepo.saveAndFlush(permission);
    }

    private void createPermissionItem(Long permissionId, String name, Byte type, String account) {
        PermissionItem item = new PermissionItem(permissionId, name, type);

        item.create(account);

        itemRepo.save(item);
    }

    @Transactional
    public void update(Long permissionId, PermissionVo.Save saveEntity, String account) {
        updatePermission(permissionId, saveEntity.getName(), account);

        reInsertFeatures(permissionId, saveEntity.getPage(), saveEntity.getFeature(), account);
    }

    private void updatePermission(Long permissionId, String permissionName, String accountName) {
        Permission permission = permissionRepo.findById(permissionId)
                                              .orElseThrow(() -> new NullPointerException("該權限已不存在"));

        permission.setName(permissionName);

        permission.update(accountName);

        permissionRepo.save(permission);
    }

    @Transactional
    public void reInsertFeatures(Long permissionId, List<PermissionVo.Item> pages,
            List<PermissionVo.Item> features, String account) {
        itemRepo.deleteByPermissionId(permissionId);

        pages.forEach(page -> createPermissionItem(permissionId, page.getName(), PermissionItem.ItemType.PAGE,
                                                   account));

        features.forEach(feature -> createPermissionItem(permissionId, feature.getName(),
                                                         PermissionItem.ItemType.FEATURE, account));
    }

    @Transactional
    public void concat(Long srcId, Long destId, String account) {
        PermissionVo srcPermission = get(srcId);
        PermissionVo destPermission = get(destId);

        List<PermissionVo.Item> pages = getUnique(srcPermission.getPage(), destPermission.getPage());
        List<PermissionVo.Item> features = getUnique(srcPermission.getFeature(), destPermission.getFeature());

        reInsertFeatures(destId, pages, features, account);

        deletePermission(srcId);

        for (PermissionGroup permissionGroup : groupRepo.findByPermissionId(srcId)) {
            permissionGroup.setPermissionId(destId);

            groupRepo.save(permissionGroup);
        }
    }

    private List<PermissionVo.Item> getUnique(List<PermissionVo.Item> resource,
            List<PermissionVo.Item> destination) {
        Predicate<PermissionVo.Item> srcPredicate = srcFeature ->
                destination.stream()
                           .noneMatch(destFeature -> srcFeature.getName()
                                                               .equals(destFeature.getName()));

        List<PermissionVo.Item> unique = resource.stream()
                                                 .filter(srcPredicate)
                                                 .collect(Collectors.toList());

        return Stream.concat(unique.stream(), destination.stream()).collect(Collectors.toList());
    }

    @Transactional
    public void reInsertGroup(Long memberId, Long permissionId, String account) {
        groupRepo.deleteByMemberId(memberId);

        PermissionGroup newEntity = new PermissionGroup(memberId, permissionId);

        newEntity.create(account);

        groupRepo.save(newEntity);
    }

    @Transactional
    public void deletePermission(Long permissionId) {
        permissionRepo.deleteById(permissionId);

        itemRepo.deleteByPermissionId(permissionId);
    }

    @Transactional
    public Permission createDefaultPermission() {
        Permission permission =
                permissionRepo.findByName(DEFAULT_PERMISSION).orElse(createPermission(DEFAULT_PERMISSION, "system"));
        createPermissionItem(permission.getId(), DEFAULT_PERMISSION_MEMBER, PermissionItem.ItemType.PAGE,
                "system");
        createPermissionItem(permission.getId(), DEFAULT_PERMISSION_MEMBER_ADD, PermissionItem.ItemType.PAGE,
                "system");
        createPermissionItem(permission.getId(), DEFAULT_PERMISSION_MEMBER_EDIT, PermissionItem.ItemType.PAGE,
                "system");
        createPermissionItem(permission.getId(), DEFAULT_PERMISSION_PERMISSION, PermissionItem.ItemType.PAGE,
                "system");
        return permission;
    }

    @Transactional
    public void combinePermissionAndAccount(String userName, Long permissionId, Long memberId) {
        PermissionGroup permissionGroup =
                PermissionGroup.builder().memberId(memberId).permissionId(permissionId).build();
        permissionGroup.create(userName);
        groupRepo.saveAndFlush(permissionGroup);
    }

}
