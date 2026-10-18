# 10: Logout and delete account

**What to build:** The user can log out of a server, and can delete their account on a server. Before deleting, the app shows which owned spaces will be handed to another member and which will be deleted, then cleans up the phone after the server confirms.

**Blocked by:** 09 (Delete space)

**Status:** ready-for-agent

- [ ] Logout ends the session on the server and removes the server account from the phone; that server's spaces are removed locally
- [ ] Delete account shows the delete preview (transfer vs delete) as a warning
- [ ] After confirming, the account is deleted and local cleanup matches the logout case
- [ ] Tested against the in-process server
