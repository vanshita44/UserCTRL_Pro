# 🛡️ UserCTRL Pro - Advanced Linux User Management System

**UserCTRL Pro** is a comprehensive Linux-based user management system that empowers system administrators with both a graphical and command-line interface to manage user accounts effectively. With intuitive operations such as creating, modifying, deleting, and locking accounts, this tool also incorporates role-based access control and audit reporting features to ensure secure and efficient system administration.

---

## 📁 Table of Contents

- [🚀 Features](#-features)
- [⚙️ Project Setup](#️-project-setup)
- [🧩 Scripts Overview](#-scripts-overview)
- [🖥️ GUI Interface](#️-gui-interface)
- [📌 How to Use](#-how-to-use)
- [📦 Dependencies](#-dependencies)
- [🔧 Troubleshooting](#-troubleshooting)
- [👨‍💻 Contributors](#-contributors)

---

## 🚀 Features

### 🔐 User Management
- Add users with role-based access control (admin, student, guest)
- Delete users with optional home directory backup
- Lock/unlock accounts with reason tracking
- Modify user attributes (username, shell, home directory, groups, role)
- Bulk user creation using CSV files

### 🧑‍💼 Role-Based Access Control
- **Admin**: Full system privileges including sudo access
- **Student**: Limited privileges within the `students` group
- **Guest**: Minimal access via the `guests` group

### 📋 System Auditing
- Generate detailed system audit reports
- Track user activity and system changes
- Include customizable sections in the reports
- Check for security anomalies

### ⚙️ Automation
- Automatically send audit reports via email
- Archive reports with date-based structure
- Log every operation with timestamps

### 🖥️ GUI (Graphical User Interface)
- Built using **Tkinter**
- Tabbed layout for easy navigation
- Input validation and user-friendly forms
- Backend powered by robust shell scripts

---

## ⚙️ Project Setup

Follow these steps to get started with UserCTRL Pro:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/vanshita44/UserCTRL_Pro.git
   ```

2. **Navigate to the Project Directory**:
   ```bash
   cd UserCTRL_Pro
   ```

3. **Set Executable Permissions for Scripts**:
   ```bash
   chmod +x scripts/*.sh
   ```

4. **Install Required Packages**:
   ```bash
   sudo apt update
   sudo apt install mailutils python3-tk finger
   ```

5. **Configure Email Functionality** (Optional):
   ```bash
   # Install mutt for better email handling
   sudo apt install mutt
   
   # Create mutt configuration file
   nano ~/.muttrc
   ```
   
   Add the following to your `.muttrc` file:
   ```
   set smtp_url="smtps://your_email@gmail.com@smtp.gmail.com:465/"
   set smtp_pass="your_app_password"
   set from="your_email@gmail.com"
   set realname="Your Name"
   set ssl_starttls=yes
   set ssl_force_tls=yes
   ```

6. **Launch the Application**:
   - **For GUI**:
     ```bash
     sudo python3 gui/main_gui.py
     ```
   - **For CLI**:
     ```bash
     bash scripts/script_name.sh
     ```

---

## 🧩 Scripts Overview

### 🔧 User Management
- `add_user.sh` – Add a user with password and role setup
- `delete_user.sh` – Delete a user and optionally back up their home directory
- `modify_user.sh` – Modify user attributes including role
- `lock_user.sh` – Lock or unlock user accounts
- `bulk_add.sh` – Bulk user creation from a CSV file

### 📝 Auditing & Reporting
- `generate_audit.sh` – Generate system audit logs
- `send_report.sh` – Email and archive audit reports

---

## 🖥️ GUI Interface

The GUI provides an intuitive interface, featuring:

- **User Management Tab**: Add, delete, lock/unlock, and modify users
- **Audit & Reports Tab**: Generate and email reports
- **Bulk Operations Tab**: Upload CSV files for mass user creation

Each GUI operation internally executes its respective shell script.

### Key GUI Improvements
- Default role selection is now "admin" when adding new users
- Added role modification in the Modify User dialog
- Improved error handling for UTF-8 encoding issues
- Enhanced user details display

---

## 📌 How to Use

### 🖥️ Command-Line Interface

Execute scripts directly:

```bash
bash scripts/add_user.sh
bash scripts/delete_user.sh
bash scripts/lock_user.sh
bash scripts/modify_user.sh -u username -r admin  # Change user role
bash scripts/generate_audit.sh
bash scripts/send_report.sh recipient@example.com report.txt
```

### 🖱️ Graphical Interface

Launch the GUI:

```bash
sudo python3 gui/main_gui.py
```

Navigate through tabs to manage users or generate reports.

---

## 📦 Dependencies

- **Bash** – For scripting core logic
- **Python 3** – GUI backend
- **Tkinter** – Python library for GUI
- **finger** – For displaying user information
- **mailutils/mutt** – For sending email reports
- **System tools** – `useradd`, `usermod`, `userdel`, `passwd`, etc.

---

## 🔧 Troubleshooting

### Common Issues and Solutions

1. **UTF-8 Decoding Error**
   - **Issue**: `'utf-8' codec can't decode byte 0xed in position 1689: invalid continuation byte`
   - **Solution**: The application now handles non-UTF-8 characters in user data

2. **Email Sending Failures**
   - **Issue**: Reports not being sent via email
   - **Solution**: 
     - Install and configure mutt: `sudo apt install mutt`
     - Set up proper SMTP configuration in `~/.muttrc`
     - For Gmail, generate an App Password if using 2FA

3. **Missing User Information**
   - **Issue**: Error retrieving user details when clicking on a user
   - **Solution**: Install the finger package: `sudo apt install finger`

4. **Permission Issues**
   - **Issue**: Scripts failing due to permission errors
   - **Solution**: Run the GUI with sudo: `sudo python3 gui/main_gui.py`

---

## 👨‍💻 Contributors

| Name               | Role                                      |
|--------------------|-------------------------------------------|
| **Armaanpreet**    | GUI Development & Final Integration       |
| **Vanshita Sharma**| Core Shell Scripts & Role Architecture    |
| **Shreya**         | Bulk CSV User Handling                    |
| **Arshdeep**       | Audit Logging & Email Automation          |

---

> 🚀 *UserCTRL Pro – Streamlining Linux user management like a pro!*
