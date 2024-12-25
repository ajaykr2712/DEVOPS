# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_003

1. Opening Terminal & Checking Current Directory : This command shows your absolute path location in the filesystem.
```
pwd    # Print Working Directory
```
2. Listing Directory Contents with Different Flags
Flag Explanations:
-a: Shows all files, including hidden ones (starting with .)
-h: Shows file sizes in human-readable format (KB, MB, GB)
-l: Long format, showing permissions, owner, size, date
-lah: Combines all above flags for most detailed view

```
ls        # Basic list
ls -a     # Show all files (including hidden)
ls -h     # Human readable file sizes
ls -l     # Long format (detailed)
ls -la    # Long format including hidden files
ls -lah   # Combines all above flags

```

3. Checking Username and Navigating to Home

```
whoami    # Shows current username
cd ~      # Navigate to home directory
# OR
cd        # Same as cd ~
# OR
cd /home/username    # Direct path to home

```

4. Creating Practice Directory

```
mkdir practice # Creates a directory

```

5. Navigating to Practice Directory

```
cd practice

```

6. Creating Empty File

```
touch mcsdwj.txt # Creates empty file 

```

7. Adding Text to File

```
echo "This is file1" > file1.txt    # Writes text to file
# > overwrites file
# >> appends to file

```

8. Using Nano Editor

```
nano file1.txt    # Opens nano editor
# Ctrl + O to save
# Ctrl + X to exit

```

9. Viewing File Contents

```
cat file1.txt #Display contents

```

10. Copying the files

```
cp file1.txt file2.txt    # Creates copy

```

11. Renaming the files

```
cp file1.txt file2.txt # Renames contents   

```

12. Deleting Files

```
rm file1.txt

```

13. Creating multiple directories

```
mkdir dir1 dir2 # Creates two directory   

```

14. Directory Navigation

```
cd dir1           # Move into dir1
ls                # List contents
cd ..             # Move up one level
cd ../dir2        # Move to sibling directory
pwd               # Check current location

```

15. Returning to Original Directory

```
cd ~ 

```