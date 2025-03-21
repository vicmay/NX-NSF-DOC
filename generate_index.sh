#!/bin/bash

# Create the header of the index.html file
cat > index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Directory Index</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
            background-color: #f5f5f5;
        }
        h1 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 0.5rem;
        }
        .file-list {
            list-style: none;
            padding: 0;
        }
        .file-item {
            background: white;
            margin: 0.5rem 0;
            padding: 0.8rem 1rem;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.2s ease;
        }
        .file-item:hover {
            transform: translateX(5px);
        }
        a {
            color: #2980b9;
            text-decoration: none;
            display: block;
        }
        a:hover {
            color: #3498db;
        }
        .timestamp {
            color: #7f8c8d;
            font-size: 0.9em;
            float: right;
        }
    </style>
</head>
<body>
    <h1>Directory Index</h1>
    <ul class="file-list">
EOL

# Find all .html files except index.html and sort them
for file in $(find . -maxdepth 1 -type f -name "*.html" ! -name "index.html" | sort); do
    filename=$(basename "$file")
    # Strip .html extension for display
    display_name=${filename%.html}
    # Get the last modified time in a readable format
    modified_time=$(date -r "$file" "+%Y-%m-%d %H:%M")
    echo "        <li class=\"file-item\"><a href=\"$filename\">$display_name <span class=\"timestamp\">$modified_time</span></a></li>" >> index.html
done

# Close the HTML file
cat >> index.html << 'EOL'
    </ul>
</body>
</html>
EOL

# Make the script executable
chmod +x "$0" 