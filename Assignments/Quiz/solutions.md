 # Solutions  1- Make another commit. Now you should have two commits in your repo.
git add .
git commit -m “Update file1”
2- Show the changes in the last 2 commits.
git log --patch -2
3- Show all commits made by yourself. Use the one-liner option.
git log --author=“Your name” --oneline
4- Show all commits with GUI in their message.
git log --grep=“GUI”
5- Show all commits with changes to file1.txt. Include the number of lines added/
removed.
git log --stat file1.txt
6- Compare the last two commits.
git diff HEAD~1 HEAD
7- Check out the commit before the last commit. Note the detached HEAD in the
terminal. Check out the master branch.
git checkout HEAD~1
git checkout master
8- Show the author of every line in file1.txt.
git blame file1.txt
9- Create a tag (v1.0) for the last commit. Show the history using the one-liner
option and note the tag you just created.
git tag v1.0
git log --oneline
10- Delete the tag.
git tag -d v1.0
