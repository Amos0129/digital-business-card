package com.emfabro;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.Security;
import java.util.Random;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static com.emfabro.system.constant.SystemValues.PROFILE_DEV;
import static com.emfabro.system.constant.SystemValues.PROFILE_LOCAL;

public class Starter {
    public static void main(String[] args) {
        SpringApplication.run(Starter.class);
    }

    public static Path getTestFileRoot() throws IOException {
        Path fileRoot = Paths.get("file-lab");

        Files.exists(fileRoot);

        Files.createDirectories(fileRoot);

        return fileRoot;
    }

    public static Path getTestFileRoot(String... pathOrFileName) throws IOException {
        Path fileRoot = getTestFileRoot();

        for (String path : pathOrFileName) {
            fileRoot = fileRoot.resolve(path);
        }

        return fileRoot;
    }

    @SpringBootTest
    @ActiveProfiles(PROFILE_DEV)
    public static abstract class UnitTester {
        public UnitTester() {
            Security.addProvider(new BouncyCastleProvider());
        }

        public long randomLong() {
            return new Random().nextLong();
        }
    }

}
