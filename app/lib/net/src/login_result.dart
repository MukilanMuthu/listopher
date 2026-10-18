/// why a login failed.
enum LoginFailure { wrongCredentials, locked, unreachable }

/// outcome of login: LoginOk or LoginFailed.
sealed class LoginResult {
  const LoginResult();
}

/// server said yes: my account on that server.
class LoginOk extends LoginResult {
  final String accountId;
  final String displayName;
  final String token;
  const LoginOk({required this.accountId, required this.displayName, required this.token});
}

/// server said no, or was not there.
class LoginFailed extends LoginResult {
  final LoginFailure reason;
  const LoginFailed(this.reason);
}
