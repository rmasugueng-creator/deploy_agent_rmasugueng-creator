# Project: Automated Project Bootstrapping & Process Management

## Overview
This repository contains an Infrastructure as Code (IaC) deployment agent (`setup_project.sh`) designed to automatically bootstrap a student attendance tracker environment, configure its internal metrics dynamically, and handle manual cancellations gracefully.

## Setup Instructions
1. Clone this repository to your local Linux machine.
2. Elevate script file execution permissions:
   ```bash
   chmod +x setup_project.sh
   ```
3. Run the automated bootstrapping utility:
   ```bash
   ./setup_project.sh
   ```

## How to Test the Process Trap (Emergency Archive Feature)
1. Run the script utility: `./setup_project.sh`
2. Enter any name when prompted to create the directory structure.
3. When the script asks you if you want to update thresholds, break the execution by pressing **`Ctrl + C`** on your keyboard.
4. The signal trap will immediately capture the interrupt, package your workspace into a `.tar.gz` archive file, and completely delete the incomplete template directory to maintain clean system storage.
