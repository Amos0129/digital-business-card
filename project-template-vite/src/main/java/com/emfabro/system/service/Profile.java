package com.emfabro.system.service;

import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;

@Service
public class Profile {

    @Autowired
    private Environment env;

    public boolean hasProfile(String str) {
        return Arrays.stream(env.getActiveProfiles())
                     .anyMatch(profile -> profile.equalsIgnoreCase(str));
    }

    public boolean hasntProfile(String str) {
        return !hasProfile(str);
    }

    public boolean hasProfiles(String... strs) {
        return Arrays.stream(strs).anyMatch(this::hasProfile);
    }
}
