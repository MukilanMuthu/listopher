// thrown by login when account is locked after too many bad passwords.
class LoginLocked implements Exception {
  const LoginLocked();
}
