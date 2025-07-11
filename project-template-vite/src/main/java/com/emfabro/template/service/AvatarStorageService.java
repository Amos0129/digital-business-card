package com.emfabro.template.service;

import com.emfabro.global.exception.BadRequestException;
import com.emfabro.global.exception.ExpectationFailedException;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.FilenameUtils;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Slf4j
@Service
public class AvatarStorageService {

    private static final String RELATIVE_PATH = "/uploads/avatars";
    private static final String STATIC_PREFIX = "/static/avatars/";

    public String save(Integer cardId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("檔案為空，請重新選擇頭像");
        }

        try {
            String extension = FilenameUtils.getExtension(file.getOriginalFilename());
            String fileName = "card_" + cardId + "." + extension;

            // 構建資料夾路徑
            String rootPath = System.getProperty("user.dir");
            Path uploadPath = Paths.get(rootPath + RELATIVE_PATH);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // 儲存檔案
            Path filePath = uploadPath.resolve(fileName);
            file.transferTo(filePath.toFile());

            return STATIC_PREFIX + fileName;
        } catch (IOException e) {
            log.error("頭像儲存失敗", e);
            throw new ExpectationFailedException("頭像儲存失敗：" + e.getMessage());
        }
    }
}
