package com.emfabro.test.utils;

import java.io.File;
import java.nio.file.Path;

public class Commons {
    public static Path getTestResource() {
        File currentFolder = new File(
                Commons.class.getProtectionDomain().getCodeSource().getLocation().getPath());

        return getRootPath(currentFolder.toPath()).resolve("src")
                                                  .resolve("test")
                                                  .resolve("resources");
    }

    private static Path getRootPath(Path current) {
        return !current.toString().endsWith(".jar") && !current.toString().endsWith("bin") &&
                !current.toString().endsWith("out") && !current.toString().endsWith("java") &&
                !current.toString().endsWith("lib") && !current.toString().endsWith("build") &&
                !current.toString().endsWith("classes") && !current.toString().endsWith("WEB-INF") &&
                !current.toString().endsWith("main") && !current.toString().endsWith("test") &&
                !current.toString().endsWith("production") ? current : getRootPath(current.getParent());
    }
}
