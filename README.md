# UserCTRL Pro - Advanced Linux User Management System

## Description

**UserCTRL Pro** is a comprehensive Linux user management system that allows administrators to efficiently manage user accounts through both a command-line interface and a graphical user interface built with Tkinter. The system enables operations such as creating users, deleting users, modifying user details, locking accounts, and assigning specific roles (admin, student, guest) with appropriate permissions.

This repository contains all the shell scripts necessary for performing user management tasks, role templates for permission assignment, and a Python-based GUI for easier interaction.

Additionally, **UserCTRL Pro** includes robust system audit features for generating comprehensive audit reports, emailing those reports to administrators, and archiving them for future reference.

---

## Table of Contents

* [Project Setup](#project-setup)
* [Features](#features)
* [Scripts Overview](#scripts-overview)
* [GUI Interface](#gui-interface)
* [How to Use](#how-to-use)
* [Dependencies](#dependencies)
* [Contributors](#contributors)

---

## Project Setup

To get started with **UserCTRL Pro**, follow these steps:

1. **Clone the Repository**:
   ```
   git clone https://github.com/vanshita44/UserCTRL_Pro.git
   ```

2. **Navigate to the Project Directory**:
   ```
   cd UserCTRL_Pro
   ```

3. **Set Permissions**:
   ```
   chmod +x *.sh
   ```

4. **Install Dependencies**:
   ```
   sudo apt update
   sudo apt install mailutils python3-tk
   ```

5. **Launch the Application**:
   ```
   # For GUI interface
   python3 gui/main_gui.py
   
   # For command-line interface
   bash ./scripts/script_name.sh
   ```

---

## Features

* **User Management**:
  * Add users with role-based permissions
  * Delete users with home directory backup option
  * Lock/unlock user accounts with expiration options
  * Modify user details (username, shell, home directory, groups)
  * Bulk user creation from CSV files

* **Role-Based Access Control**:
  * Admin: Full system privileges (sudo access)
  * Student: Limited privileges (students group)
  * Guest: Minimal privileges (guests group)

* **System Auditing**:
  * Generate comprehensive system reports
  * Customizable report sections
  * User activity monitoring
  * Security checks

* **Automation**:
  * Email reports to administrators
  * Archive reports with organized date structure
  * Logging of all operations

* **Graphical User Interface**:
  * Tkinter-based GUI for easier interaction
  * Tabbed interface for different operations
  * Form validation and error handling

---

## Scripts Overview

### User Management Scripts

* **add_user.sh**: Creates users with password security and role assignment
* **delete_user.sh**: Removes users with home directory backup
* **lock_user.sh**: Locks/unlocks accounts with reason tracking
* **modify_user.sh**: Comprehensive user modification options
* **bulk_add.sh**: Processes CSV files for bulk user creation

### Audit and Reporting Scripts

* **generate_audit.sh**: Creates detailed system audit reports
* **send_report.sh**: Emails reports and archives them

### Utility Scripts

* **utils.sh**: Common functions used across scripts
* **role_templates.sh**: Defines permissions for different roles

---

## GUI Interface

The Tkinter-based GUI provides an intuitive interface for all operations:

* **User Management Tab**: Add, delete, lock/unlock, and modify users
* **Audit & Reports Tab**: Generate and send audit reports
* **Bulk Operations Tab**: Upload CSV files for bulk user creation

The GUI internally calls the bash scripts to perform the actual system operations, providing a user-friendly front-end while maintaining the robust back-end functionality.

---

## How to Use

### Command Line Interface

Run individual scripts directly:

```
# Add a user
bash scripts/add_user.sh

# Delete a user
bash scripts/delete_user.sh

# Lock a user account
bash scripts/lock_user.sh

# Modify a user
bash scripts/modify_user.sh

# Generate audit report
bash scripts/generate_audit.sh

# Send report via email
bash scripts/send_report.sh recipient@example.com report_file.txt
```

### Graphical Interface

Launch the GUI application:

```
python3 gui/main_gui.py
```

Then use the intuitive interface to perform all operations.

---

## Dependencies

* **Bash**: Core scripting language
* **Python 3**: For the GUI interface
* **Tkinter**: Python library for GUI development
* **mailutils**: For email functionality
* **System commands**: useradd, usermod, userdel, passwd, etc.

---

## Contributors

* **Armaannpreet**: GUI Integration & Final Integration
* **Vanshita Sharma**: Core Bash Logic, Role Templates, User Operations
* **Shreya**: CSV Handling & Bulk Operations
* **Arshdeep**: Audit Reports & Email Automation
```
