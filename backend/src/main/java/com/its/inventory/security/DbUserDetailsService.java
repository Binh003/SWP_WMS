package com.its.inventory.security;

import com.its.inventory.repository.UserRepository;
import java.util.List;
import java.util.stream.Stream;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DbUserDetailsService implements UserDetailsService {

  private final UserRepository userRepository;

  @Override
  public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
    var u = userRepository.findByUsername(username)
        .orElseThrow(() -> new UsernameNotFoundException("User not found"));

    // Authorities are derived dynamically from DB:
    // - roles => ROLE_<code>
    // - permissions => <code>
    var authorities = u.getRoles().stream()
        .flatMap(r -> Stream.concat(
            Stream.of(new SimpleGrantedAuthority("ROLE_" + r.getCode())),
            r.getPermissions().stream().map(p -> new SimpleGrantedAuthority(p.getCode()))
        ))
        .distinct()
        .toList();

    return org.springframework.security.core.userdetails.User.builder()
        .username(u.getUsername())
        .password(u.getPasswordHash())
        .disabled(!u.isEnabled())
        .authorities(authorities.isEmpty() ? List.of() : authorities)
        .build();
  }
}
