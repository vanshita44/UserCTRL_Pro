Here’s an updated version of your **README** to reflect the changes and tasks completed:

---

# UserCTRL Pro - Project Overview

## Description

**UserCTRL Pro** is a shell script-based user management system that allows administrators to efficiently manage user accounts on a Linux system. It enables operations such as creating users, deleting users, modifying user details, locking accounts, and assigning specific roles (admin, student, guest). The system also features role-based access controls to ensure the right permissions are applied based on the user's role.

This repository contains all the shell scripts necessary for performing user management tasks, as well as role templates that allow the assignment of different privileges to each user.

Additionally, **UserCTRL Pro** includes system audit features for generating audit reports, emailing those reports, and archiving them for future reference.

---

## Table of Contents

* [Project Setup](#project-setup)
* [My Contributions](#my-contributions)
* [Scripts Overview](#scripts-overview)
* [How to Use](#how-to-use)
* [Dependencies](#dependencies)
* [Contributors](#contributors)

---

## Project Setup

To get started with **UserCTRL Pro**, follow these steps:

1. **Clone the Repository**: First, clone the repository to your local machine:

   ```bash
   git clone https://github.com/vanshita44/UserCTRL_Pro.git
   ```

2. **Navigate to the Project Directory**: Once the repository is cloned, navigate into the project folder:

   ```bash
   cd UserCTRL_Pro
   ```

3. **Set Permissions (Optional)**: If required, ensure that the scripts have execute permissions:

   ```bash
   chmod +x *.sh
   ```

4. **Install Dependencies** (for email functionality):
   If you plan to use the email automation feature, ensure you have `mailutils` (or an equivalent mail client) installed. Run:

   ```bash
   sudo apt update
   sudo apt install mailutils
   ```

---

## Contributions

As part of the **UserCTRL Pro** project, I was responsible for creating and managing the core Bash scripts that handle user operations, role-based templates, input validation, error handling, and system auditing.

Here’s an overview of the tasks I handled:

### 1. **Core Bash Logic & User Operations**

I created the main shell scripts that perform the essential user management tasks on a Linux system. These include:

#### **add\_user.sh**

* **Purpose**: Adds a new user to the system and assigns them a role (admin, student, guest).
* **Role**: The role-based access control ensures that each user has specific permissions.

  * Admins are given *sudo* access to perform administrative tasks.
  * Students are added to the *students* group.
  * Guests are added to the *guests* group.
* **Functionality**:

  * The script prompts the administrator for the *username* and *role* of the new user.
  * It checks if the username is already in use.
  * If not, the user is added using the `useradd` command.
  * Then, the script assigns the user to the appropriate group based on their role using the `usermod` command.

#### **delete\_user.sh**

* **Purpose**: Deletes an existing user from the system.
* **Functionality**:

  * The script prompts for the username to be deleted.
  * It checks if the user exists and then deletes them using the `userdel` command.

#### **lock\_user.sh**

* **Purpose**: Locks a user’s account, preventing them from logging in.
* **Functionality**:

  * The script prompts for the username to be locked.
  * It uses the `passwd -l` command to lock the account.

#### **modify\_user.sh**

* **Purpose**: Modifies a user’s details (e.g., adding/removing roles, changing groups).
* **Functionality**:

  * The script prompts for the username and the modification action (e.g., adding/removing user from groups).
  * It uses the `usermod` command to modify user settings.

---

### 2. **Bulk User Creation from CSV**

#### **bulk\_add.sh**

* **Purpose**: Handles bulk user creation from a CSV file (containing usernames and roles).
* **Functionality**:

  * The script reads the `users.csv` file, which contains user details (username, role).
  * It processes each line and adds users in bulk to the system based on the role.
  * It handles edge cases such as duplicate usernames and logs errors to `error_log.txt` for failed entries.

---

### 3. **Audit Reporting and Automation**

#### **generate\_audit.sh**

* **Purpose**: Generates a system audit report that includes key system metrics (e.g., uptime, memory usage, active processes, IP address, network connections).
* **Functionality**:

  * The script collects system data such as uptime, free memory, top processes by memory usage, IP address configuration, and network listening services.
  * The report is saved with a timestamp to a file.
  * The script calls `send_report.sh` to automatically email the report and archive it for future reference.

#### **send\_report.sh**

* **Purpose**: Sends the generated audit report via email and archives it for record-keeping.
* **Functionality**:

  * This script emails the generated audit report to the specified recipient using the system's mail utility (like `mail` or `sendmail`).
  * The report is archived in a designated folder for record-keeping.

---

### 4. **Role Templates**

I created role templates for users to define what groups they should belong to. This makes it easier to assign roles with predefined permissions:

* **Admin**: Full privileges, able to perform administrative tasks (added to the **sudo** group).
* **Student**: Limited privileges, part of the **students** group.
* **Guest**: Very limited privileges, part of the **guests** group.

---

### 5. **System Commands**

Throughout the scripts, I utilized several important Linux commands to manage users and generate audit reports:

* **useradd**: Used to create a new user.
* **usermod**: Used to modify an existing user (e.g., add the user to specific groups based on their role).
* **userdel**: Used to delete a user from the system.
* **passwd -l**: Used to lock a user account.
* **uptime, free, ps, ip, ss**: Used in the audit report to gather system statistics.

---

## Scripts Overview

### 1. **add\_user.sh**

* Adds a user and assigns a role.
* Takes *username* and *role* as input.
* Roles: *admin, student, guest*.
* Assigns the user to the appropriate Linux group based on their role.

### 2. **delete\_user.sh**

* Deletes a user from the system.
* Takes *username* as input.
* Ensures the user exists before deleting.

### 3. **lock\_user.sh**

* Locks a user account to prevent login.
* Takes *username* as input.

### 4. **modify\_user.sh**

* Modifies a user's group memberships.
* Takes *username* and *modification action* as input.
* Allows adding/removing users from groups.

### 5. **Bulk User Operations**

* **bulk\_add.sh**: Adds multiple users from a CSV file, logs errors, and handles edge cases.

### 6. **Audit Scripts**

* **generate\_audit.sh**: Generates and saves a system audit report.
* **send\_report.sh**: Sends the audit report via email and archives it.

---

## How to Use

To use the UserCTRL Pro scripts, follow the steps below:

1. **Clone the Repository**:
   Clone this repository to your local machine:

   ```bash
   git clone https://github.com/vanshita44/UserCTRL_Pro.git
   cd UserCTRL_Pro
   ```

2. **Make the Scripts Executable** (if required):

   ```bash
   chmod +x *.sh
   ```

3. **Install Dependencies** (for email functionality):
   Install **mailutils** or another mail client:

   ```bash
   sudo apt update
   sudo apt install mailutils
   ```

4. **Run the Scripts**:

   * To add a user:

     ```bash
     bash add_user.sh
     ```

   * To delete a user:

     ```bash
     bash delete_user.sh
     ```

   * To lock a user account:

     ```bash
     bash lock_user.sh
     ```

   * To modify a user:

     ```bash
     bash modify_user.sh
     ```

   * To generate and email the system audit report (automatically archived):

     ```bash
     bash generate_audit.sh
     ```

5. **Follow the Prompts**:
   Each script will prompt you to input a username and, in some cases, a role (for `add_user.sh`). Follow the prompts to execute the desired action.

---

## Dependencies

* **mailutils**: Required for sending email with audit reports.
* **ps, free, uptime, ip, ss**: Required for generating system audit reports.
* **chmod +x**: Ensure all scripts have execute permissions.

---

## Contributors

* **Armaannpreet**: GUI Integration & Final Integration (in charge of connecting the bash logic to the GUI).
* **Vanshita Sharma**: Core Bash Logic, Role Templates, User Operations (Add, Delete, Lock, Modify).
* **Shreya**: CSV Handling & Bulk Operations.
* **Arshdeep**: Audit Reports & Email Automation.

---

This version includes all of the contributions and changes, including the bulk user operations and the role templates you worked on. Let me know if you need further adjustments!
