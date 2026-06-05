#!/bin/bash

# 1. Process Management & Signal Trap (SIGINT / Ctrl+C)
cleanup_on_interrupt() {
    echo -e "\n\n[INTERRUPT] Setup canceled by user! Cleaning up workspace..."
    if [ -d "$PROJECT_DIR" ]; then
        echo "Bundling emergency backup archive..."
        tar -czf "${PROJECT_DIR}_archive.tar.gz" "$PROJECT_DIR" 2>/dev/null
        echo "Deleting the incomplete project directory..."
        rm -rf "$PROJECT_DIR"
    fi
    exit 1
}
# Attach the trap function to the SIGINT signal
trap cleanup_on_interrupt SIGINT

# 2. Capture Project Name Input
echo "========================================="
echo "  AUTOMATED PROJECT BOOTSTRAPPING AGENT  "
echo "========================================="
echo "Enter a unique name suffix for your project directory:"
read -r USER_INPUT

# Basic check to make sure input is not blank
if [ -z "$USER_INPUT" ]; then
    echo "Error: Directory name suffix cannot be blank."
    exit 1
fi

PROJECT_DIR="attendance_tracker_${USER_INPUT}"

# Robust error handling: Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Directory '$PROJECT_DIR' already exists. Aborting to prevent overwrite."
    exit 1
fi

# 3. Build Directory Architecture
echo "Generating workspace directories for $PROJECT_DIR..."
mkdir -p "$PROJECT_DIR/Helpers" "$PROJECT_DIR/reports"

# Generate code, assets, and diagnostic log templates
touch "$PROJECT_DIR/attendance_checker.py"
touch "$PROJECT_DIR/Helpers/assets.csv"
touch "$PROJECT_DIR/reports/reports.log"

# Create a clean, baseline config.json file
cat << 'EOF' > "$PROJECT_DIR/Helpers/config.json"
{
    "warning_threshold": 75,
    "failure_threshold": 50
}
EOF

# 4. Dynamic Stream Editing (sed) with Numeric Input Validation
echo "Do you want to manually update the attendance thresholds? (y/n)"
read -r UPDATE_CHOICE

if [[ "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
    echo "Enter custom Warning threshold integer (default 75):"
    read -r WARNING_VAL
    echo "Enter custom Failure threshold integer (default 50):"
    read -r FAILURE_VAL

    # Validation check: Ensure inputs are non-empty data types and strictly numeric integers
    if [[ "$WARNING_VAL" =~ ^[0-9]+$ ]] && [[ "$FAILURE_VAL" =~ ^[0-9]+$ ]]; then
        sed -i "s/\"warning_threshold\": 75/\"warning_threshold\": $WARNING_VAL/" "$PROJECT_DIR/Helpers/config.json"
        sed -i "s/\"failure_threshold\": 50/\"failure_threshold\": $FAILURE_VAL/" "$PROJECT_DIR/Helpers/config.json"
        echo "Dynamic modifications written to config.json successfully."
    else
        echo "Error: Non-numeric values detected. Rejecting edit. Falling back to defaults."
    fi
fi

# 5. Environment Validation (Health Check)
echo "-----------------------------------------"
echo "Running system environment validation..."
if command -v python3 &>/dev/null; then
    echo "Success: python3 is installed on this local machine."
    python3 --version
else
    echo "Warning: python3 engine is missing from the local system."
fi

echo "========================================="
echo "Project factory setup successfully completed."
echo "========================================="
