# Removing Image Source Calls from a Markdown File

This guide explains how to remove image source calls (e.g., `![](image.jpg)`) from a Markdown file, specifically targeting the provided example of removing:

```html
<p align="center">
  <img src="https://github.com/Avik-Jain/100-Days-Of-ML-Code/blob/master/Info-graphs/Day%204.jpg">
</p> 
```
Tools and Techniques
    You can achieve this using various text editors or command-line tools. Here are a couple of approaches:

1. Manual Deletion using a Text Editor
    Open the 100days.md file: Use any text editor (VS Code, Atom, Sublime Text, Notepad++, etc.).

    Find the Image Calls: Locate the lines containing <img src= tags.
    
    Delete: Select and delete the entire block of HTML code associated with the image, including the <p> tags for alignment.

    Save: Save the 100days.md file.2. 
2. Automated Removal using sed (Command Line)
    Caution: This method is powerful but requires caution as it directly modifies the original file. Always back up your file before running such commands.
    
    1. Open your terminal/command prompt.
    2. Navigate to the directory containing the 100days.md file using the cd command.
    3. Run the following sed command:
    ```
    sed -i '' '/<p align="center">/,/<\/p>/d' 100days.md 

    ```

    