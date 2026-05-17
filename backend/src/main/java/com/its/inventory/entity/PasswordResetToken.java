package com.its.inventory.entity;

import jakarta.persistence.*;
import java.time.Instant;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "password_reset_tokens",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_password_reset_tokens_token", columnNames = "token")
    },
    indexes = {
        @Index(name = "ix_password_reset_tokens_user_id", columnList = "user_id")
    }
)
public class PasswordResetToken {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(optional = false, fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Column(nullable = false, length = 80)
  private String token;

  @Column(nullable = false)
  private Instant expiresAt;

  @Column(nullable = false)
  private boolean used;
}
