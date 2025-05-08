import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import os

class UserCTRLApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("UserCTRL Pro")
        self.geometry("800x600")
        
        # Create tabs
        self.tab_control = ttk.Notebook(self)
        
        # User Management Tab
        self.user_tab = ttk.Frame(self.tab_control)
        self.tab_control.add(self.user_tab, text="User Management")
        self.setup_user_tab()
        
        # Audit Tab
        self.audit_tab = ttk.Frame(self.tab_control)
        self.tab_control.add(self.audit_tab, text="Audit & Reports")
        self.setup_audit_tab()
        
        # Bulk Operations Tab
        self.bulk_tab = ttk.Frame(self.tab_control)
        self.tab_control.add(self.bulk_tab, text="Bulk Operations")
        self.setup_bulk_tab()
        
        self.tab_control.pack(expand=1, fill="both")
    
    def setup_user_tab(self):
        # Create frame for buttons
        btn_frame = ttk.Frame(self.user_tab)
        btn_frame.pack(pady=20)
        
        # Add User button
        add_btn = ttk.Button(btn_frame, text="Add User", command=self.open_add_user)
        add_btn.grid(row=0, column=0, padx=10, pady=10)
        
        # Delete User button
        del_btn = ttk.Button(btn_frame, text="Delete User", command=self.open_delete_user)
        del_btn.grid(row=0, column=1, padx=10, pady=10)
        
        # Lock User button
        lock_btn = ttk.Button(btn_frame, text="Lock User", command=self.open_lock_user)
        lock_btn.grid(row=0, column=2, padx=10, pady=10)
        
        # Modify User button
        mod_btn = ttk.Button(btn_frame, text="Modify User", command=self.open_modify_user)
        mod_btn.grid(row=0, column=3, padx=10, pady=10)
    
    def setup_audit_tab(self):
        # Create frame for buttons
        btn_frame = ttk.Frame(self.audit_tab)
        btn_frame.pack(pady=20)
        
        # Generate Audit button
        audit_btn = ttk.Button(btn_frame, text="Generate Audit Report", command=self.generate_audit)
        audit_btn.grid(row=0, column=0, padx=10, pady=10)
        
        # Send Report button
        send_btn = ttk.Button(btn_frame, text="Send Report", command=self.send_report)
        send_btn.grid(row=0, column=1, padx=10, pady=10)
    
    def setup_bulk_tab(self):
        # Create frame for buttons
        btn_frame = ttk.Frame(self.bulk_tab)
        btn_frame.pack(pady=20)
        
        # Bulk Add button
        bulk_btn = ttk.Button(btn_frame, text="Bulk Add Users", command=self.bulk_add)
        bulk_btn.grid(row=0, column=0, padx=10, pady=10)
        
        # CSV Template button
        template_btn = ttk.Button(btn_frame, text="Download CSV Template", command=self.download_template)
        template_btn.grid(row=0, column=1, padx=10, pady=10)
    
    # User Management Functions
    def open_add_user(self):
        self.open_dialog("add_user")
    
    def open_delete_user(self):
        self.open_dialog("delete_user")
    
    def open_lock_user(self):
        self.open_dialog("lock_user")
    
    def open_modify_user(self):
        self.open_dialog("modify_user")
    
    # Audit Functions
    def generate_audit(self):
        try:
            result = subprocess.run(["bash", "./scripts/generate_audit.sh"], 
                                  capture_output=True, text=True)
            messagebox.showinfo("Audit Report", f"Report generated successfully.\n{result.stdout}")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to generate audit: {str(e)}")
    
    def send_report(self):
        # Create dialog to get email
        email_dialog = tk.Toplevel(self)
        email_dialog.title("Send Report")
        email_dialog.geometry("400x200")
        
        ttk.Label(email_dialog, text="Recipient Email:").pack(pady=10)
        email_entry = ttk.Entry(email_dialog, width=40)
        email_entry.pack(pady=10)
        
        def send():
            email = email_entry.get()
            if not email:
                messagebox.showerror("Error", "Email is required")
                return
            
            try:
                # Find the latest audit report
                reports = [f for f in os.listdir("./") if f.startswith("audit_report_")]
                if not reports:
                    messagebox.showerror("Error", "No audit reports found")
                    return
                
                latest_report = max(reports)
                result = subprocess.run(["bash", "./scripts/send_report.sh", email, latest_report], 
                                      capture_output=True, text=True)
                messagebox.showinfo("Success", f"Report sent to {email}")
                email_dialog.destroy()
            except Exception as e:
                messagebox.showerror("Error", f"Failed to send report: {str(e)}")
        
        ttk.Button(email_dialog, text="Send", command=send).pack(pady=20)
    
    # Bulk Operations Functions
    def bulk_add(self):
        try:
            result = subprocess.run(["bash", "./scripts/bulk_add.sh"], 
                                  capture_output=True, text=True)
            messagebox.showinfo("Bulk Add", "Users added from CSV file.\nCheck logs for details.")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to add users: {str(e)}")
    
    def download_template(self):
        # Create a sample CSV template
        with open("template.csv", "w") as f:
            f.write("username,fullname,password,shell\n")
            f.write("jdoe,John Doe,Pass@123,/bin/bash\n")
            f.write("asmith,Alice Smith,Secret456,/bin/zsh\n")
        
        messagebox.showinfo("Template", "CSV template saved as template.csv")
    
    # Helper Functions
    def open_dialog(self, script_name):
        dialog = UserDialog(self, script_name)
        self.wait_window(dialog)

class UserDialog(tk.Toplevel):
    def __init__(self, parent, script_type):
        super().__init__(parent)
        self.script_type = script_type
        
        if script_type == "add_user":
            self.title("Add User")
            self.setup_add_user()
        elif script_type == "delete_user":
            self.title("Delete User")
            self.setup_delete_user()
        elif script_type == "lock_user":
            self.title("Lock User")
            self.setup_lock_user()
        elif script_type == "modify_user":
            self.title("Modify User")
            self.setup_modify_user()
    
    def setup_add_user(self):
        self.geometry("400x300")
        
        ttk.Label(self, text="Username:").pack(pady=5)
        self.username = ttk.Entry(self, width=30)
        self.username.pack(pady=5)
        
        ttk.Label(self, text="Role:").pack(pady=5)
        self.role = ttk.Combobox(self, values=["admin", "student", "guest"])
        self.role.pack(pady=5)
        
        ttk.Button(self, text="Add User", command=self.execute_add_user).pack(pady=20)
    
    def setup_delete_user(self):
        self.geometry("400x200")
        
        ttk.Label(self, text="Username:").pack(pady=10)
        self.username = ttk.Entry(self, width=30)
        self.username.pack(pady=10)
        
        ttk.Button(self, text="Delete User", command=self.execute_delete_user).pack(pady=20)
    
    def setup_lock_user(self):
        self.geometry("400x200")
        
        ttk.Label(self, text="Username:").pack(pady=10)
        self.username = ttk.Entry(self, width=30)
        self.username.pack(pady=10)
        
        ttk.Button(self, text="Lock User", command=self.execute_lock_user).pack(pady=20)
    
    def setup_modify_user(self):
        self.geometry("400x250")
        
        ttk.Label(self, text="Username:").pack(pady=5)
        self.username = ttk.Entry(self, width=30)
        self.username.pack(pady=5)
        
        ttk.Label(self, text="New Username:").pack(pady=5)
        self.new_username = ttk.Entry(self, width=30)
        self.new_username.pack(pady=5)
        
        ttk.Button(self, text="Modify User", command=self.execute_modify_user).pack(pady=20)
    
    def execute_add_user(self):
        username = self.username.get()
        role = self.role.get()
        
        if not username or not role:
            messagebox.showerror("Error", "Username and role are required")
            return
        
        # Create a temporary file with inputs
        with open("temp_input.txt", "w") as f:
            f.write(f"{username}\n{role}\n")
        
        try:
            # Run the bash script with input from the file
            result = subprocess.run(["bash", "./scripts/add_user.sh"], 
                                  stdin=open("temp_input.txt"), 
                                  capture_output=True, text=True)
            
            if "successfully" in result.stdout:
                messagebox.showinfo("Success", f"User {username} added successfully with role {role}")
                self.destroy()
            else:
                messagebox.showerror("Error", result.stdout)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to add user: {str(e)}")
        finally:
            # Clean up
            if os.path.exists("temp_input.txt"):
                os.remove("temp_input.txt")
    
    def execute_delete_user(self):
        username = self.username.get()
        
        if not username:
            messagebox.showerror("Error", "Username is required")
            return
        
        # Create a temporary file with inputs
        with open("temp_input.txt", "w") as f:
            f.write(f"{username}\n")
        
        try:
            result = subprocess.run(["bash", "./scripts/delete_user.sh"], 
                                  stdin=open("temp_input.txt"), 
                                  capture_output=True, text=True)
            
            if "successfully" in result.stdout:
                messagebox.showinfo("Success", f"User {username} deleted successfully")
                self.destroy()
            else:
                messagebox.showerror("Error", result.stdout)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to delete user: {str(e)}")
        finally:
            if os.path.exists("temp_input.txt"):
                os.remove("temp_input.txt")
    
    def execute_lock_user(self):
        username = self.username.get()
        
        if not username:
            messagebox.showerror("Error", "Username is required")
            return
        
        with open("temp_input.txt", "w") as f:
            f.write(f"{username}\n")
        
        try:
            result = subprocess.run(["bash", "./scripts/lock_user.sh"], 
                                  stdin=open("temp_input.txt"), 
                                  capture_output=True, text=True)
            
            if "successfully" in result.stdout:
                messagebox.showinfo("Success", f"User {username} locked successfully")
                self.destroy()
            else:
                messagebox.showerror("Error", result.stdout)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to lock user: {str(e)}")
        finally:
            if os.path.exists("temp_input.txt"):
                os.remove("temp_input.txt")
    
    def execute_modify_user(self):
        username = self.username.get()
        new_username = self.new_username.get()
        
        if not username or not new_username:
            messagebox.showerror("Error", "Both usernames are required")
            return
        
        with open("temp_input.txt", "w") as f:
            f.write(f"{username}\n{new_username}\n")
        
        try:
            result = subprocess.run(["bash", "./scripts/modify_user.sh"], 
                                  stdin=open("temp_input.txt"), 
                                  capture_output=True, text=True)
            
            if "changed" in result.stdout:
                messagebox.showinfo("Success", f"Username changed to {new_username}")
                self.destroy()
            else:
                messagebox.showerror("Error", result.stdout)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to modify user: {str(e)}")
        finally:
            if os.path.exists("temp_input.txt"):
                os.remove("temp_input.txt")

if __name__ == "__main__":
    app = UserCTRLApp()
    app.mainloop()
