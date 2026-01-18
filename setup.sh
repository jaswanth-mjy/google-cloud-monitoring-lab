#!/bin/bash
# Quick Setup Script for Cloud Shell

echo "========================================="
echo "Google Cloud Monitoring Lab - Quick Setup"
echo "========================================="
echo

# Make shell.sh executable
if [ -f "shell.sh" ]; then
    chmod +x shell.sh
    echo "✓ Made shell.sh executable"
else
    echo "✗ Error: shell.sh not found in current directory"
    echo "  Please ensure shell.sh is uploaded to Cloud Shell"
    exit 1
fi

echo
echo "Setup complete! Run the lab with:"
echo
echo "  ./shell.sh"
echo
echo "----------------------------------------"
echo "Project IDs configured in the script:"
echo "  Project 1 (Monitoring): qwiklabs-gcp-01-8738a17451ea"
echo "  Project 2 (Worker 1):   qwiklabs-gcp-02-9402c6127f7c"
echo "  Project 3 (Worker 2):   qwiklabs-gcp-01-99d92e72d5c9"
echo "----------------------------------------"
echo
