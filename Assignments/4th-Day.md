# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_004


### The goal of this assignment is to get familiar with the Linux terminal by manipulating files using some common commands.


ALL these operations are implemented parallely in the the Terminal and being contemplated here

1. cd ..
 cd .. /home
2.  touch file.txt
3. nano file.txt (eidts)
4. To save and edit nano commands you need to follow the instructions
   To Save:
        Ctrl + O (letter O) - Write Out/Save
        Press Enter to confirm the filename
   To Edit:
        Just type to insert/edit textUse arrow keys to navigate
        Ctrl + K - Cut line
        Ctrl + U - Paste line
        Ctrl + W - Search text
        Backspace/Delete - Delete charactersTo Exit:
6. echo file.txt
7.  echo "My name is Echo" >> file.txt
8. sed -i 's/practice/manipulation/g' file.txt
9. cp command to copy  and create a backup file text:  cp example.txt example_backup.txt
10.   Remove second line from backup:  sed -i '2d' example_backup.txt
11. Count words in original file: wc -w file.txt, for the backup file use the same and add the path wc -w file_backup.txt
12. exit the terminal : exit


# Happy Learning


