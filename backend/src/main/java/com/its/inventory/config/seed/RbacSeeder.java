package com.its.inventory.config.seed;

import com.its.inventory.entity.Permission;
import com.its.inventory.entity.Role;
import com.its.inventory.entity.User;
import com.its.inventory.repository.PermissionRepository;
import com.its.inventory.repository.RoleRepository;
import com.its.inventory.repository.UserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class RbacSeeder implements CommandLineRunner {

  private final PermissionRepository permissionRepository;
  private final RoleRepository roleRepository;
  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;

  @Value("${app.seed.admin.username}")
  private String adminUsername;

  @Value("${app.seed.admin.password}")
  private String adminPassword;

  @Override
  @Transactional
  public void run(String... args) {
    seedPermissions();
    seedRoles();
    seedAdminUser();
  }

  private void seedPermissions() {
    // Keep permission catalog server-controlled (seeded). UI can assign perms to roles dynamically.
    ensurePermission("USER_READ", "Xem người dùng");
    ensurePermission("USER_WRITE", "Quản lý người dùng");
    ensurePermission("ROLE_READ", "Xem vai trò");
    ensurePermission("ROLE_WRITE", "Quản lý vai trò");
    ensurePermission("PERMISSION_READ", "Xem quyền");
  }

  private void seedRoles() {
    var userRead = permissionRepository.findByCode("USER_READ").orElseThrow();
    var userWrite = permissionRepository.findByCode("USER_WRITE").orElseThrow();
    var roleRead = permissionRepository.findByCode("ROLE_READ").orElseThrow();
    var roleWrite = permissionRepository.findByCode("ROLE_WRITE").orElseThrow();
    var permRead = permissionRepository.findByCode("PERMISSION_READ").orElseThrow();

    ensureRole(
        "ADMIN",
        "Administrator",
        List.of(userRead, userWrite, roleRead, roleWrite, permRead)
    );

    ensureRole(
        "WAREHOUSE",
        "Warehouse",
        List.of()
    );

    ensureRole(
        "VIEWER",
        "Viewer",
        List.of()
    );
  }

  private void seedAdminUser() {
    var adminRole = roleRepository.findByCode("ADMIN").orElseThrow();

    var u = userRepository.findByUsername(adminUsername).orElse(null);
    if (u == null) {
      u = User.builder()
          .username(adminUsername)
          .fullName("Administrator")
          .email("admin@inventory.local")
          .passwordHash(passwordEncoder.encode(adminPassword))
          .enabled(true)
          .build();
    }

    u.setEnabled(true);
    u.getRoles().add(adminRole);
    userRepository.save(u);
  }

  private void ensurePermission(String code, String name) {
    if (permissionRepository.existsByCode(code)) return;
    permissionRepository.save(Permission.builder().code(code).name(name).build());
  }

  private void ensureRole(String code, String name, List<Permission> permissions) {
    var role = roleRepository.findByCode(code).orElse(null);
    if (role == null) {
      role = Role.builder().code(code).name(name).build();
      role.getPermissions().addAll(permissions);
      roleRepository.save(role);
      return;
    }

    // Don't overwrite permission assignments on existing roles.
    // Roles are configurable dynamically via UI.
    role.setName(name);
    roleRepository.save(role);
  }
}
