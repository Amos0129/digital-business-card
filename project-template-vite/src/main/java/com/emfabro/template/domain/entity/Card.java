package com.emfabro.template.domain.entity;


import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "cards")
@Data
public class Card {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String name;

    private String phone;

    private String email;

    private String company;

    @Column(name = "position")
    private String position;

    private String address;

    @Column(name = "style")
    private String style;

    @Column(name = "facebook")
    private Boolean facebook;

    @Column(name = "instagram")
    private Boolean instagram;

    @Column(name = "line")
    private Boolean line;

    @Column(name = "threads")
    private Boolean threads;

    @Column(name = "is_public")
    private Boolean isPublic;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
