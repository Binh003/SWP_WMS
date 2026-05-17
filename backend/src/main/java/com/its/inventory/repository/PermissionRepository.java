package com.its.inventory.repository;

import com.its.inventory.entity.Permission;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PermissionRepository extends JpaRepository<Permission, Long> {
  Optional<Permission> findByCode(String code);

  boolean existsByCode(String code);
}
