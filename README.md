# UserCTRL Pro - Project Overview

## Description

**UserCTRL Pro** is a shell script-based user management system that allows administrators to efficiently manage user accounts on a Linux system. It enables operations such as creating users, deleting users, modifying user details, locking accounts, and assigning specific roles (admin, student, guest). The system also features role-based access controls to make sure the right permissions are applied based on the user's role.

This repository contains all the shell scripts necessary for performing user management tasks, as well as role templates that allow the assignment of different privileges to each user.

## Table of Contents

- [Project Setup](#project-setup)
- [My Contributions](#my-contributions)
- [Scripts Overview](#scripts-overview)
- [How to Use](#how-to-use)
- [Contributors](#contributors)

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

## My Contributions

As part of the **UserCTRL Pro** project, I was responsible for creating and managing the core Bash scripts that handle user operations, role-based templates, input validation, and error handling.

Here’s an overview of the tasks I handled:

### 1. **Core Bash Logic & User Operations**

I created the main shell scripts that perform the essential user management tasks on a Linux system. These include:

#### `add_user.sh`
- **Purpose**: Adds a new user to the system and assigns them a role (admin, student, guest).
- **Role**: The role-based access control ensures that each user has specific permissions.
  - Admins are given **sudo** access to perform administrative tasks.
  - Students are added to the **students** group.
  - Guests are added to the **guests** group.

- **Functionality**:
   - The script first prompts the administrator for the **username** and **role** of the new user.
   - It checks if the username is already in use.
   - If not, the user is added using the `useradd` command.
   - Then, the script assigns the user to the appropriate group based on their role using the `usermod` command.

#### `delete_user.sh`
- **Purpose**: Deletes an existing user from the system.
- **Functionality**:
   - The script prompts for the username to be deleted.
   - It checks if the user exists and then deletes them using the `userdel` command.

#### `lock_user.sh`
- **Purpose**: Locks a user’s account, preventing them from logging in.
- **Functionality**:
   - The script prompts for the username to be locked.
   - It uses the `passwd -l` command to lock the account.

#### `modify_user.sh`
- **Purpose**: Modifies a user’s details (e.g., adding/removing roles, changing groups).
- **Functionality**:
   - The script prompts for the username and the modification action (e.g., adding/removing user from groups).
   - It uses the `usermod` command to modify user settings.

### 2. **Role Templates**
I created role templates for users to define what groups they should belong to. This makes it easier to assign roles with predefined permissions:
- **Admin**: Full privileges, able to perform administrative tasks (added to the **sudo** group).
- **Student**: Limited privileges, part of the **students** group.
- **Guest**: Very limited privileges, part of the **guests** group.

### 3. **Input Validation**
I ensured that user inputs (like usernames and roles) were validated before performing any operations. This ensures that the system operates smoothly and that no invalid data is entered.

- **Input checks**: 
   - Ensure that a username and role are provided when adding or modifying users.
   - Check if the username already exists before adding a new user.
   - Provide meaningful error messages when an operation cannot be performed.

### 4. **System Commands**
Throughout the scripts, I utilized several important Linux commands to manage users:

- **`useradd`**: Used to create a new user.
- **`usermod`**: Used to modify an existing user (e.g., add the user to specific groups based on their role).
- **`userdel`**: Used to delete a user from the system.
- **`passwd -l`**: Used to lock a user account.

### 5. **Testing and Debugging**
Once the scripts were completed, I tested each one thoroughly to ensure they functioned correctly:
- Ensured the user creation process worked for each role.
- Verified that the delete and modify operations were functional.
- Checked that invalid inputs were handled correctly with proper error messages.

---

## Scripts Overview

### 1. `add_user.sh`
- Adds a user and assigns a role.
- Takes **username** and **role** as input.
- Roles: **admin**, **student**, **guest**.
- Assigns the user to the appropriate Linux group based on their role.

### 2. `delete_user.sh`
- Deletes a user from the system.
- Takes **username** as input.
- Ensures the user exists before deleting.

### 3. `lock_user.sh`
- Locks a user account to prevent login.
- Takes **username** as input.

### 4. `modify_user.sh`
- Modifies a user's group memberships.
- Takes **username** and **modification action** as input.
- Allows adding/removing users from groups.

### 5. Role Templates
- Templates for **admin**, **student**, and **guest** roles.
- Predefined groups to streamline user role assignment.

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

3. **Run the Scripts**:

   - To add a user:
     ```bash
     bash add_user.sh
     ```
   - To delete a user:
     ```bash
     bash delete_user.sh
     ```
   - To lock a user account:
     ```bash
     bash lock_user.sh
     ```
   - To modify a user:
     ```bash
     bash modify_user.sh
     ```

4. **Follow the Prompts**:
   Each script will prompt you to input a username and, in some cases, a role (for `add_user.sh`). Follow the prompts to execute the desired action.

---

## Contributors

- **Armaannpreet**: GUI Integration & Final Integration (in charge of connecting the bash logic to the GUI).
- **Vanshita Sharma**: Core Bash Logic, Role Templates, User Operations (Add, Delete, Lock, Modify).
- **Shreya**: CSV Handling & Bulk Operations.
- **Arshdeep**: Audit Reports & Email Automation.


---


