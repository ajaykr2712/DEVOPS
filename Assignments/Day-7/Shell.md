# A step-by-step guide on how to run these Bash scripts. Here's a general process that applies to all the scripts we've created:

1. Open a terminal window on your computer.

2. Navigate to the directory where you've saved the scripts. For example:
   ```bash
   cd /Users/aponduga/Desktop/Personal/Devops/Assignments/Day-7
   ```

3. Ensure the script has executable permissions. If it doesn't, you can add them using the chmod command:
   ```bash
   chmod +x search_replace.sh
   ```

4. Run the script by prefixing it with ./
   For the search_replace.sh script, you would run:
   ```bash
   ./search_replace.sh <filename> <search_word> <replace_word>
   ```
   Replace <filename>, <search_word>, and <replace_word> with actual values.

   For example:
   ```bash
   ./search_replace.sh myfile.txt old new
   ```

5. The script will execute and provide output based on its functionality.

For the specific search_replace.sh script:

1. Create a test file to work with:
   ```bash
   echo "This is a test file with some words to replace." > testfile.txt
   ```

2. Run the script:
   ```bash
   ./search_replace.sh testfile.txt words phrases
   ```

3. Check the output. It should tell you how many replacements were made.

4. Verify the changes in the file:
   ```bash
   cat testfile.txt
   ```

Remember, for scripts that require user input (like greet_user.sh or add_numbers.sh), you'll be prompted to enter information after running the script.

For scripts with menus (like menu_operations.sh), you'll interact with the script by entering numbers corresponding to menu options.

Always make sure you're in the correct directory when running the scripts, and that you provide the correct number and type of arguments for scripts that expect them.