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
    name = "roles",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_roles_code", columnNames = "code")
    }
)
public class Role {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, length = 50)
  private String code;

  @Column(nullable = false, length = 200)
  private String name;

  @Column(length = 500)
  private String description;

  @Column(nullable = false)
  private boolean enabled = true;

  @Builder.Default
  @ManyToMany(fetch = FetchType.LAZY)
  @JoinTable(
      name = "role_permissions",
      joinColumns = @JoinColumn(name = "role_id"),
      inverseJoinColumns = @JoinColumn(name = "permission_id"),
      uniqueConstraints = {
          @UniqueConstraint(
              name = "uk_role_permissions_role_permission",
              columnNames = {"role_id", "permission_id"}
          )
      }
  )
  private Set<Permission> permissions = new HashSet<>();
}
