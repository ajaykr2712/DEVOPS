# Linux Accounts, Groups, Users, and Permissions Cheat Sheet

| **Command**                    | **Description**                                                                                  |
|---------------------------------|--------------------------------------------------------------------------------------------------|
| `whoami`                       | Displays the current logged-in user.                                                            |
| `id`                           | Displays the user ID (UID) and group ID (GID) of the current or specified user.                 |
| `groups`                       | Lists the groups a user belongs to.                                                             |
| `adduser username`             | Adds a new user with the specified `username`.                                                  |
| `useradd username`             | Adds a new user (requires manual configuration of home directory, password, etc.).              |
| `passwd username`              | Changes the password for the specified user.                                                    |
| `usermod -aG groupname username` | Adds a user to a specified group (`-a` for append, `-G` for group).                            |
| `deluser username`             | Deletes the specified user.                                                                     |
| `userdel username`             | Deletes the specified user (similar to `deluser`).                                              |
| `groupadd groupname`           | Creates a new group.                                                                            |
| `groupdel groupname`           | Deletes a group.                                                                                |
| `chown owner:group filename`   | Changes the ownership of a file to the specified `owner` and `group`.                           |
| `chmod permissions filename`   | Changes the file permissions (e.g., `chmod 755 filename`).                                      |
| `ls -l`                        | Lists files with their permissions, ownership, and other details.                               |
| `getfacl filename`             | Displays the access control list (ACL) for a file or directory.                                 |
| `setfacl -m u:username:rw filename` | Modifies the ACL to grant read and write permissions to a specific user.                   |
| `chmod u+r filename`           | Adds read permission for the user to the specified file.                                        |
| `chmod g-w filename`           | Removes write permission for the group from the specified file.                                 |
| `chmod o+x filename`           | Adds execute permission for others to the specified file.                                       |
| `chmod 777 filename`           | Grants read, write, and execute permissions to everyone.                                        |
| `chmod 000 filename`           | Removes all permissions from everyone.                                                         |
| `umask`                        | Displays or sets the default permissions for new files and directories.                        |
| `su - username`                | Switches to another user account with their environment.                                        |
| `sudo command`                 | Executes a command with superuser privileges.                                                  |
| `visudo`                       | Edits the sudoers file securely.                                                               |
| `find / -user username`        | Finds all files owned by the specified user.                                                   |
| `find / -group groupname`      | Finds all files belonging to the specified group.                                              |
| `touch filename`               | Creates a new empty file.                                                                      |
| `mkdir dirname`                | Creates a new directory.                                                                       |
| `rm -rf dirname`               | Deletes a directory and its contents recursively.                                              |
| `lsattr filename`              | Lists the attributes of a file (e.g., immutable files).                                        |
| `chattr +i filename`           | Makes a file immutable (cannot be modified, deleted, or renamed).                              |
| `chattr -i filename`           | Removes the immutable attribute from a file.                                                  |
| `who`                          | Displays all users currently logged into the system.                                           |
| `w`                            | Shows who is logged in and what they are doing.                                                |
| `last`                         | Displays the login history of users.                                                           |
| `finger username`              | Shows detailed information about a user, including home directory, shell, and more.            |
| `ssh username@hostname`        | Connects to a remote machine using SSH with the specified username.                            |
| `scp file username@hostname:/path` | Copies a file to a remote machine using SSH.                                               |
| `rsync -av source destination` | Synchronizes files between source and destination.                                             |

Feel free to copy and use this in your Markdown file!
