#!/bin/bash

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed. Please install it first."
    echo "You can install it using: sudo apt-get install pandoc"
    exit 1
fi

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <markdown_file> [output_file]"
    exit 1
fi

input_file="$1"
output_file="${2:-${input_file%.*}.html}"

# Create a temporary CSS file
cat > temp_style.css << 'EOL'
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    line-height: 1.6;
    max-width: 800px;
    margin: 0 auto;
    padding: 2em;
    color: #333;
}

h1, h2, h3, h4, h5, h6 {
    color: #2c3e50;
    margin-top: 1.5em;
    margin-bottom: 0.5em;
}

h1 { font-size: 2.5em; border-bottom: 2px solid #eee; padding-bottom: 0.3em; }
h2 { font-size: 2em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
h3 { font-size: 1.75em; }

code {
    background-color: #f6f8fa;
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;
}

pre {
    background-color: #f6f8fa;
    padding: 1em;
    border-radius: 5px;
    overflow-x: auto;
}

pre code {
    background-color: transparent;
    padding: 0;
}

blockquote {
    margin: 0;
    padding-left: 1em;
    border-left: 4px solid #ddd;
    color: #666;
}

a {
    color: #0366d6;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 1em 0;
}

th, td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
}

th {
    background-color: #f6f8fa;
}

img {
    max-width: 100%;
    height: auto;
    display: block;
    margin: 1em auto;
}
EOL

# Convert markdown to HTML with custom CSS
pandoc "$input_file" \
    --standalone \
    --css=temp_style.css \
    --from=markdown \
    --to=html5 \
    --output="$output_file"

# Clean up temporary CSS file
rm temp_style.css

echo "Conversion complete! Output saved to: $output_file" 