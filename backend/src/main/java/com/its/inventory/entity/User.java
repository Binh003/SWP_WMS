package com.its.inventory.entity;

import jakarta.persistence.*;
import java.util.HashSet;
import java.util.Set;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "users",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_users_username", columnNames = "username")
    }
)
public class User {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, length = 100)
  private String username;

  @Column(nullable = false, length = 200)
  private String fullName;

  @Column(nullable = false, length = 200)
  private String email;

  @Column(nullable = false)
  private String passwordHash;

  @Builder.Default
  @ManyToMany(fetch = FetchType.LAZY)
  @JoinTable(
      name = "user_roles",
      joinColumns = @JoinColumn(name = "user_id"),
      inverseJoinColumns = @JoinColumn(name = "role_id"),
      uniqueConstraints = {
          @UniqueConstraint(name = "uk_user_roles_user_role", columnNames = {"user_id", "role_id"})
      }
  )
  private Set<Role> roles = new HashSet<>();

  @Column(nullable = false)
  private boolean enabled = true;
}
