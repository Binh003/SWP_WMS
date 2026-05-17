package com.its.inventory.repository;

import com.its.inventory.entity.Role;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface RoleRepository extends JpaRepository<Role, Long> {
  @EntityGraph(attributePaths = {"permissions"})
  Optional<Role> findById(Long id);

  @Query("select r from Role r left join fetch r.permissions where r.id = :id")
  Optional<Role> findByIdWithPermissions(Long id);

  Optional<Role> findByCode(String code);

  boolean existsByCode(String code);
}
