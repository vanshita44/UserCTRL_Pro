
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
- [👨‍💻 Contributors](#-contributors)

---

## 🚀 Features

### 🔐 User Management
- Add users with role-based access control
- Delete users with optional home directory backup
- Lock/unlock accounts with reason tracking
- Modify user attributes (username, shell, home directory, groups)
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
   sudo apt install mailutils python3-tk
   ```

5. **Launch the Application**:
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
- `modify_user.sh` – Modify user attributes
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

---

## 📌 How to Use

### 🖥️ Command-Line Interface

Execute scripts directly:

```bash
bash scripts/add_user.sh
bash scripts/delete_user.sh
bash scripts/lock_user.sh
bash scripts/modify_user.sh
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
- **mailutils** – For sending email reports
- **System tools** – `useradd`, `usermod`, `userdel`, `passwd`, etc.

---

## 👨‍💻 Contributors

| Name            | Role                                      |
|-----------------|-------------------------------------------|
| **Armaanpreet** | GUI Development & Final Integration       |
| **Vanshita Sharma** | Core Shell Scripts & Role Architecture   |
| **Shreya**      | Bulk CSV User Handling                    |
| **Arshdeep**    | Audit Logging & Email Automation          |

---

> 🚀 *UserCTRL Pro – Streamlining Linux user management like a pro!*
