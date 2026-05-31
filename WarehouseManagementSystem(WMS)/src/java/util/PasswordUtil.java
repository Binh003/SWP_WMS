package util;

import org.mindrot.jbcrypt.BCrypt;

public final class PasswordUtil {

    private PasswordUtil() {}

    public static String hash(String rawPassword) {
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt(10));
    }

    public static boolean matches(String rawPassword, String hashed) {
        if (rawPassword == null || hashed == null || hashed.isBlank()) {
            return false;
        }
        return BCrypt.checkpw(rawPassword, hashed);
    }
}
