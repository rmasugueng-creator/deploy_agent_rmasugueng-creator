#!/bin/bash

# 1. PROCESS MANAGEMENT (SIGNAL TRAP)

cleanup_on_interrupt() {
    echo -e "\n\n[INTERRUPT] Setup canceled by user! Cleaning up workspace..."
    
    # Check if the incomplete directory exists before bundling
    if [ -d "$PROJECT_DIR" ]; then
        # Named exactly as requested: attendance_tracker_{input}_archive
        # We append .tar.gz so it is a valid compressed archive file
        ARCHIVE_NAME="attendance_tracker_${USER_INPUT}_archive.tar.gz"
        
        echo "[-] Bundling current state into archive: $ARCHIVE_NAME"
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR" 2>/dev/null
        
        echo "[-] Deleting the incomplete project directory to prevent clutter..."
        rm -rf "$PROJECT_DIR"
    fi
    echo "[+] Workspace is clean. Exiting now."
    exit 1
}

# Attach the trap function to catch user interrupt (Ctrl+C)
trap cleanup_on_interrupt SIGINT




# 2. CAPTURE PROJECT SUFFIX INPUT

echo "========================================="
echo "  AUTOMATED PROJECT BOOTSTRAPPING AGENT  "
echo "========================================="
echo -n "Enter a unique name suffix for your project directory: "
read -r USER_INPUT

# Environment Validation Edge Case: Ensure the user input is not blank
if [ -z "$USER_INPUT" ]; then
    echo "[ERROR] Directory name suffix cannot be blank. Setup aborted."
    exit 1
fi

# Set up the parent directory name exactly as required
PROJECT_DIR="attendance_tracker_${USER_INPUT}"

# Robust error handling: Check if directory already exists to prevent overwrite
if [ -d "$PROJECT_DIR" ]; then
    echo "[ERROR] Directory '$PROJECT_DIR' already exists. Setup aborted."
    exit 1
fi




# 3. BUILD DIRECTORY ARCHITECTURE

echo "[+] Generating workspace directories for $PROJECT_DIR..."
# Creates parent directory and sub-directories safely
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

echo "[+] Moving your downloaded source files into place..."
# This moves the files you downloaded from the assignment into the new project structure
# If you run this script, make sure these 4 files are in the same folder as this script!
mv attendance_checker.py "$PROJECT_DIR/" 2>/dev/null
mv assets.csv "$PROJECT_DIR/Helpers/" 2>/dev/null
mv config.json "$PROJECT_DIR/Helpers/" 2>/dev/null
mv reports.log "$PROJECT_DIR/reports/" 2>/dev/null




# 4. DYNAMIC CONFIGURATION (STREAM EDITING)

echo "-----------------------------------------"
echo "Do you want to update the attendance thresholds? (y/n)"
read -r UPDATE_CHOICE

if [[ "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
    echo -n "Enter custom Warning threshold integer (default 75): "
    read -r WARNING_VAL
    echo -n "Enter custom Failure threshold integer (default 50): "
    read -r FAILURE_VAL

    # High-grade validation check: Ensure values are strictly numeric digits and not empty
    if [[ "$WARNING_VAL" =~ ^[0-9]+$ ]] && [[ "$FAILURE_VAL" =~ ^[0-9]+$ ]]; then
        echo "[+] Updating thresholds dynamically inside config.json..."
        # In-place stream editing using sed
        sed -i "s/75/$WARNING_VAL/g" "$PROJECT_DIR/Helpers/config.json" 2>/dev/null
        sed -i "s/50/$FAILURE_VAL/g" "$PROJECT_DIR/Helpers/config.json" 2>/dev/null
        echo "[SUCCESS] Dynamic modifications written successfully."
    else
        echo "[WARNING] Non-numeric or blank input detected. Falling back to defaults."
    fi
else
    echo "[-] Keeping default thresholds (75% Warning / 50% Failure)."
fi




# 5. ENVIRONMENT VALIDATION (HEALTH CHECK)

echo "-----------------------------------------"
echo "Running system environment validation..."

# Mandatory Check: Verifying python3 installation using 'python3 --version'
if python3 --version &>/dev/null; then
    echo "[SUCCESS] python3 is installed on this local machine."
    echo "System Version: $(python3 --version)"
else
    echo "[WARNING] python3 engine is missing from the local system."
fi

# Final sanity check: Verify the application directory structure is followed perfectly
if [ -f "$PROJECT_DIR/attendance_checker.py" ] && [ -d "$PROJECT_DIR/Helpers" ] && [ -d "$PROJECT_DIR/reports" ]; then
    echo "========================================="
    echo "[SUCCESS] Project factory setup successfully completed!"
    echo "========================================="
else
    echo "========================================="
    echo "[WARNING] Setup completed, but some source files were missing from the starting folder."
    echo "Please ensure you downloaded and placed all files next to this script."
    echo "========================================="
fi
