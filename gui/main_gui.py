import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import subprocess
import os
import threading
from datetime import datetime

# Define improved color scheme
COLORS = {
    "primary": "#1976D2",  # Deeper blue
    "secondary": "#263238",  # Dark slate
    "success": "#2E7D32",  # Deep green
    "warning": "#F57F17",  # Amber
    "danger": "#D32F2F",  # Red
    "light": "#ECEFF1",  # Light gray
    "dark": "#37474F",  # Dark slate gray
    "bg": "#F5F5F5",  # Light background
    "text": "#212121",  # Almost black text
    "accent": "#00BCD4"  # Cyan accent
}

class UserCTRLApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("UserCTRL Pro - Linux User Management")
        self.geometry("900x650")
        self.configure(bg=COLORS["bg"])

        # Create header with improved styling
        self.header_frame = tk.Frame(self, bg=COLORS["secondary"], height=60)
        self.header_frame.pack(fill="x")
        header_label = tk.Label(
            self.header_frame,
            text="UserCTRL Pro",
            font=("Helvetica", 18, "bold"),
            fg="white",
            bg=COLORS["secondary"],
            padx=20
        )
        header_label.pack(side="left", pady=10)

        # Create main content area
        self.content_frame = tk.Frame(self, bg=COLORS["bg"])
        self.content_frame.pack(fill="both", expand=True, padx=15, pady=15)

        # Create tabs with improved styling
        self.style = ttk.Style()
        self.style.configure("TNotebook", background=COLORS["bg"])
        self.style.configure("TNotebook.Tab", padding=[10, 5], font=("Helvetica", 10))
        self.tab_control = ttk.Notebook(self.content_frame)

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

        # Create status bar
        self.status_var = tk.StringVar()
        self.status_var.set("Ready")
        self.status_bar = tk.Label(
            self,
            textvariable=self.status_var,
            bd=1,
            relief=tk.SUNKEN,
            anchor=tk.W,
            bg=COLORS["light"],
            padx=10,
            pady=5
        )
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)

        # Create logs directory if it doesn't exist
        os.makedirs("../logs", exist_ok=True)

        # Apply custom styling
        self.apply_custom_style()

    def apply_custom_style(self):
        style = ttk.Style()
        style.configure("TButton",
                      font=("Helvetica", 10),
                      background=COLORS["primary"])
        style.configure("Success.TButton",
                      background=COLORS["success"])
        style.configure("Danger.TButton",
                      background=COLORS["danger"])
        style.configure("TEntry",
                      fieldbackground=COLORS["light"])
        style.configure("TNotebook",
                      background=COLORS["bg"])
        style.configure("TNotebook.Tab",
                      padding=[12, 6],
                      font=("Helvetica", 10))

    def setup_user_tab(self):
        # Create left panel for user list
        left_frame = ttk.Frame(self.user_tab)
        left_frame.pack(side="left", fill="y", padx=10, pady=10)

        # User list
        ttk.Label(left_frame, text="Current Users", font=("Helvetica", 12, "bold")).pack(pady=(0, 10))
        self.user_listbox = tk.Listbox(left_frame, width=25, height=20, selectmode=tk.SINGLE)
        self.user_listbox.pack(side="top", fill="both", expand=True)
        self.user_listbox.bind("<<ListboxSelect>>", self.on_user_select)

        refresh_btn = ttk.Button(left_frame, text="Refresh Users", command=self.refresh_users)
        refresh_btn.pack(pady=10, fill="x")

        # Create right panel for user actions
        right_frame = ttk.Frame(self.user_tab)
        right_frame.pack(side="right", fill="both", expand=True, padx=10, pady=10)

        # Title
        ttk.Label(right_frame, text="User Management", font=("Helvetica", 14, "bold")).pack(pady=(0, 20))

        # User actions frame
        actions_frame = ttk.LabelFrame(right_frame, text="Actions")
        actions_frame.pack(fill="x", pady=10, padx=5)

        # Create a grid of buttons
        btn_frame = ttk.Frame(actions_frame)
        btn_frame.pack(pady=15, padx=10)

        # Add User button
        add_btn = ttk.Button(btn_frame, text="Add User", command=self.open_add_user)
        add_btn.grid(row=0, column=0, padx=10, pady=10, sticky="ew")

        # Delete User button
        del_btn = ttk.Button(btn_frame, text="Delete User", command=self.open_delete_user)
        del_btn.grid(row=0, column=1, padx=10, pady=10, sticky="ew")

        # Lock User button
        lock_btn = ttk.Button(btn_frame, text="Lock User", command=self.open_lock_user)
        lock_btn.grid(row=1, column=0, padx=10, pady=10, sticky="ew")

        # Modify User button
        mod_btn = ttk.Button(btn_frame, text="Modify User", command=self.open_modify_user)
        mod_btn.grid(row=1, column=1, padx=10, pady=10, sticky="ew")

        # User details frame
        details_frame = ttk.LabelFrame(right_frame, text="User Details")
        details_frame.pack(fill="both", expand=True, pady=10, padx=5)

        self.details_text = tk.Text(details_frame, height=10, width=40)
        self.details_text.pack(fill="both", expand=True, pady=10, padx=10)
        self.details_text.config(state="disabled")

        # Load initial user list
        self.refresh_users()

    def setup_audit_tab(self):
        # Create main frame
        main_frame = ttk.Frame(self.audit_tab)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)

        # Title
        ttk.Label(main_frame, text="System Audit & Reports", font=("Helvetica", 14, "bold")).pack(pady=(0, 20))

        # Audit options frame
        options_frame = ttk.LabelFrame(main_frame, text="Audit Options")
        options_frame.pack(fill="x", pady=10)

        # Checkboxes for audit sections
        self.audit_sections = {}
        sections = ["system", "memory", "network", "users", "security"]
        section_frame = ttk.Frame(options_frame)
        section_frame.pack(pady=10, padx=10)

        for i, section in enumerate(sections):
            var = tk.BooleanVar(value=True)
            self.audit_sections[section] = var
            cb = ttk.Checkbutton(section_frame, text=section.capitalize(), variable=var)
            cb.grid(row=0, column=i, padx=10)

        # Buttons frame
        btn_frame = ttk.Frame(main_frame)
        btn_frame.pack(pady=20)

        # Generate Audit button
        audit_btn = ttk.Button(
            btn_frame,
            text="Generate Audit Report",
            command=self.generate_audit
        )
        audit_btn.grid(row=0, column=0, padx=10, pady=10)

        # Send Report button
        send_btn = ttk.Button(
            btn_frame,
            text="Send Report",
            command=self.send_report
        )
        send_btn.grid(row=0, column=1, padx=10, pady=10)

        # View Reports button
        view_btn = ttk.Button(
            btn_frame,
            text="View Reports",
            command=self.view_reports
        )
        view_btn.grid(row=0, column=2, padx=10, pady=10)

        # Report preview frame
        preview_frame = ttk.LabelFrame(main_frame, text="Report Preview")
        preview_frame.pack(fill="both", expand=True, pady=10)

        self.preview_text = tk.Text(preview_frame, wrap="word")
        self.preview_text.pack(fill="both", expand=True, pady=10, padx=10)
        self.preview_text.config(state="disabled")

    def setup_bulk_tab(self):
        # Create main frame
        main_frame = ttk.Frame(self.bulk_tab)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)

        # Title
        ttk.Label(main_frame, text="Bulk User Operations", font=("Helvetica", 14, "bold")).pack(pady=(0, 20))

        # CSV file frame
        file_frame = ttk.LabelFrame(main_frame, text="CSV File")
        file_frame.pack(fill="x", pady=10)

        file_select_frame = ttk.Frame(file_frame)
        file_select_frame.pack(fill="x", pady=10, padx=10)

        self.csv_path_var = tk.StringVar()
        path_entry = ttk.Entry(file_select_frame, textvariable=self.csv_path_var, width=50)
        path_entry.grid(row=0, column=0, padx=(0, 10))

        browse_btn = ttk.Button(file_select_frame, text="Browse", command=self.browse_csv)
        browse_btn.grid(row=0, column=1)

        # Buttons frame
        btn_frame = ttk.Frame(main_frame)
        btn_frame.pack(pady=20)

        # Bulk Add button
        bulk_btn = ttk.Button(btn_frame, text="Bulk Add Users", command=self.bulk_add)
        bulk_btn.grid(row=0, column=0, padx=10, pady=10)

        # CSV Template button
        template_btn = ttk.Button(btn_frame, text="Download CSV Template", command=self.download_template)
        template_btn.grid(row=0, column=1, padx=10, pady=10)

        # Dry Run button
        dry_run_btn = ttk.Button(btn_frame, text="Dry Run", command=self.dry_run)
        dry_run_btn.grid(row=0, column=2, padx=10, pady=10)

        # Results frame
        results_frame = ttk.LabelFrame(main_frame, text="Operation Results")
        results_frame.pack(fill="both", expand=True, pady=10)

        self.results_text = tk.Text(results_frame, wrap="word")
        self.results_text.pack(fill="both", expand=True, pady=10, padx=10)
        self.results_text.config(state="disabled")

    # User Management Functions
    def refresh_users(self):
        try:
            # Run command with binary output instead of text
            result = subprocess.run(["getent", "passwd"], capture_output=True, text=False)
            
            if result.returncode == 0:
                self.user_listbox.delete(0, tk.END)
                users = []
                
                # Decode with error handling
                output = result.stdout.decode('utf-8', errors='replace')
                
                for line in output.splitlines():
                    username = line.split(":")[0]
                    # Filter out system users (UID < 1000 typically)
                    try:
                        user_info = subprocess.run(["id", "-u", username], capture_output=True, text=True)
                        uid = int(user_info.stdout.strip())
                        if uid >= 1000 and not username.startswith("_"):
                            users.append(username)
                    except:
                        pass
                        
                for user in sorted(users):
                    self.user_listbox.insert(tk.END, user)
                    
                self.status_var.set(f"Found {len(users)} users")
            else:
                messagebox.showerror("Error", "Failed to retrieve user list")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to refresh users: {str(e)}")

    def on_user_select(self, event):
        if not self.user_listbox.curselection():
            return

        username = self.user_listbox.get(self.user_listbox.curselection())
        try:
            # Get user details
            id_result = subprocess.run(["id", username], capture_output=True, text=True)
            finger_result = subprocess.run(["finger", username], capture_output=True, text=True)

            self.details_text.config(state="normal")
            self.details_text.delete(1.0, tk.END)
            self.details_text.insert(tk.END, f"Username: {username}\n\n")

            if id_result.returncode == 0:
                self.details_text.insert(tk.END, "ID Information:\n")
                self.details_text.insert(tk.END, id_result.stdout)
                self.details_text.insert(tk.END, "\n\n")

            if finger_result.returncode == 0:
                self.details_text.insert(tk.END, "User Information:\n")
                self.details_text.insert(tk.END, finger_result.stdout)

            self.details_text.config(state="disabled")
        except Exception as e:
            self.details_text.config(state="normal")
            self.details_text.delete(1.0, tk.END)
            self.details_text.insert(tk.END, f"Error retrieving user details: {str(e)}")
            self.details_text.config(state="disabled")

    def open_add_user(self):
        self.open_dialog("add_user")

    def open_delete_user(self):
        if not self.user_listbox.curselection():
            messagebox.showinfo("Select User", "Please select a user from the list first")
            return
        username = self.user_listbox.get(self.user_listbox.curselection())
        self.open_dialog("delete_user", username)

    def open_lock_user(self):
        if not self.user_listbox.curselection():
            messagebox.showinfo("Select User", "Please select a user from the list first")
            return
        username = self.user_listbox.get(self.user_listbox.curselection())
        self.open_dialog("lock_user", username)

    def open_modify_user(self):
        if not self.user_listbox.curselection():
            messagebox.showinfo("Select User", "Please select a user from the list first")
            return
        username = self.user_listbox.get(self.user_listbox.curselection())
        self.open_dialog("modify_user", username)

    # Audit Functions
    def generate_audit(self):
        # Get selected sections
        sections = []
        for section, var in self.audit_sections.items():
            if var.get():
                sections.append(section)

        if not sections:
            messagebox.showinfo("No Sections", "Please select at least one audit section")
            return

        self.status_var.set("Generating audit report...")

        # Run in a separate thread to avoid freezing the UI
        def run_audit():
            try:
                cmd = ["bash", "./scripts/generate_audit.sh"]
                # Add include sections parameter
                if len(sections) < 5:  # Not all sections selected
                    cmd.extend(["-i", ",".join(sections)])

                result = subprocess.run(cmd, capture_output=True, text=True)

                if result.returncode == 0:
                    # Find the generated report file
                    report_files = [f for f in os.listdir("./") if f.startswith("audit_report_")]
                    if report_files:
                        latest_report = max(report_files)
                        # Show preview
                        with open(latest_report, "r") as f:
                            report_content = f.read()

                        self.preview_text.config(state="normal")
                        self.preview_text.delete(1.0, tk.END)
                        self.preview_text.insert(tk.END, report_content)
                        self.preview_text.config(state="disabled")

                        self.status_var.set(f"Audit report generated: {latest_report}")
                    else:
                        messagebox.showerror("Error", "Report file not found after generation")
                else:
                    messagebox.showerror("Error", f"Failed to generate audit report:\n{result.stderr}")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to generate audit: {str(e)}")

            self.status_var.set("Ready")

        threading.Thread(target=run_audit).start()

    def send_report(self):
        # Find the latest audit report
        report_files = [f for f in os.listdir("./") if f.startswith("audit_report_")]
        if not report_files:
            messagebox.showinfo("No Reports", "No audit reports found. Generate a report first.")
            return

        latest_report = max(report_files)

        # Create dialog to get email
        email_dialog = tk.Toplevel(self)
        email_dialog.title("Send Report")
        email_dialog.geometry("400x200")
        email_dialog.configure(bg=COLORS["bg"])

        # Make dialog modal
        email_dialog.transient(self)
        email_dialog.grab_set()

        ttk.Label(email_dialog, text="Send Audit Report", font=("Helvetica", 12, "bold")).pack(pady=10)
        ttk.Label(email_dialog, text=f"Report: {latest_report}").pack(pady=5)

        email_frame = ttk.Frame(email_dialog)
        email_frame.pack(pady=10)

        ttk.Label(email_frame, text="Recipient Email:").grid(row=0, column=0, padx=5, pady=5, sticky="e")
        email_entry = ttk.Entry(email_frame, width=30)
        email_entry.grid(row=0, column=1, padx=5, pady=5)

        ttk.Label(email_frame, text="Subject:").grid(row=1, column=0, padx=5, pady=5, sticky="e")
        subject_entry = ttk.Entry(email_frame, width=30)
        subject_entry.grid(row=1, column=1, padx=5, pady=5)
        subject_entry.insert(0, f"System Audit Report - {datetime.now().strftime('%Y-%m-%d')}")

        def send():
            email = email_entry.get()
            subject = subject_entry.get()

            if not email:
                messagebox.showerror("Error", "Email is required")
                return

            if not subject:
                subject = "System Audit Report"

            try:
                self.status_var.set(f"Sending report to {email}...")
                cmd = ["bash", "./scripts/send_report.sh"]
                if subject != "System Audit Report":
                    cmd.extend(["-s", subject])
                cmd.extend([email, latest_report])

                result = subprocess.run(cmd, capture_output=True, text=True)

                if "SUCCESS" in result.stdout:
                    messagebox.showinfo("Success", f"Report sent to {email}")
                    email_dialog.destroy()
                    self.status_var.set(f"Report sent to {email}")
                else:
                    messagebox.showerror("Error", f"Failed to send report:\n{result.stderr}")
                    self.status_var.set("Ready")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to send report: {str(e)}")
                self.status_var.set("Ready")

        btn_frame = ttk.Frame(email_dialog)
        btn_frame.pack(pady=10)

        ttk.Button(btn_frame, text="Send", command=send).grid(row=0, column=0, padx=10)
        ttk.Button(btn_frame, text="Cancel", command=email_dialog.destroy).grid(row=0, column=1, padx=10)

    def view_reports(self):
        # Check if archive directory exists
        archive_dir = "./archive/reports"
        if not os.path.exists(archive_dir):
            messagebox.showinfo("No Archives", "No archived reports found.")
            return

        # Create dialog to browse reports
        reports_dialog = tk.Toplevel(self)
        reports_dialog.title("Archived Reports")
        reports_dialog.geometry("600x400")
        reports_dialog.configure(bg=COLORS["bg"])

        ttk.Label(reports_dialog, text="Archived Reports", font=("Helvetica", 12, "bold")).pack(pady=10)

        # Create a frame for the treeview
        tree_frame = ttk.Frame(reports_dialog)
        tree_frame.pack(fill="both", expand=True, padx=10, pady=10)

        # Create treeview with scrollbar
        columns = ("date", "time", "size")
        tree = ttk.Treeview(tree_frame, columns=columns, show="headings")
        tree.heading("date", text="Date")
        tree.heading("time", text="Time")
        tree.heading("size", text="Size")
        tree.column("date", width=150)
        tree.column("time", width=100)
        tree.column("size", width=100)

        scrollbar = ttk.Scrollbar(tree_frame, orient="vertical", command=tree.yview)
        tree.configure(yscrollcommand=scrollbar.set)
        tree.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Populate treeview with reports
        reports = []
        for root, dirs, files in os.walk(archive_dir):
            for file in files:
                if file.endswith(".txt"):
                    file_path = os.path.join(root, file)
                    file_stat = os.stat(file_path)
                    file_time = datetime.fromtimestamp(file_stat.st_mtime)
                    reports.append({
                        "path": file_path,
                        "date": file_time.strftime("%Y-%m-%d"),
                        "time": file_time.strftime("%H:%M:%S"),
                        "size": f"{file_stat.st_size / 1024:.1f} KB"
                    })

        # Sort reports by date and time (newest first)
        reports.sort(key=lambda x: x["path"], reverse=True)

        for report in reports:
            tree.insert("", "end", values=(report["date"], report["time"], report["size"]), tags=(report["path"],))

        # Function to view selected report
        def view_report():
            selection = tree.selection()
            if not selection:
                messagebox.showinfo("Select Report", "Please select a report to view")
                return

            item = tree.item(selection[0])
            file_path = tree.item(selection[0], "tags")[0]

            try:
                with open(file_path, "r") as f:
                    report_content = f.read()

                # Create a new window to display the report
                view_window = tk.Toplevel(reports_dialog)
                view_window.title(f"Report: {os.path.basename(file_path)}")
                view_window.geometry("700x500")

                text_widget = tk.Text(view_window, wrap="word")
                text_widget.pack(fill="both", expand=True, padx=10, pady=10)
                text_widget.insert(tk.END, report_content)
                text_widget.config(state="disabled")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to open report: {str(e)}")

        btn_frame = ttk.Frame(reports_dialog)
        btn_frame.pack(pady=10)

        ttk.Button(btn_frame, text="View Report", command=view_report).grid(row=0, column=0, padx=10)
        ttk.Button(btn_frame, text="Close", command=reports_dialog.destroy).grid(row=0, column=1, padx=10)

    # Bulk Operations Functions
    def browse_csv(self):
        file_path = filedialog.askopenfilename(
            title="Select CSV File",
            filetypes=[("CSV Files", "*.csv"), ("All Files", "*.*")]
        )
        if file_path:
            self.csv_path_var.set(file_path)

    def bulk_add(self):
        csv_path = self.csv_path_var.get()
        if not csv_path:
            messagebox.showinfo("No File", "Please select a CSV file first")
            return

        if not os.path.exists(csv_path):
            messagebox.showerror("Error", "Selected file does not exist")
            return

        self.status_var.set("Adding users from CSV...")

        # Run in a separate thread to avoid freezing the UI
        def run_bulk_add():
            try:
                cmd = ["bash", "./scripts/bulk_add.sh", "-f", csv_path]
                result = subprocess.run(cmd, capture_output=True, text=True)

                self.results_text.config(state="normal")
                self.results_text.delete(1.0, tk.END)
                self.results_text.insert(tk.END, result.stdout)
                if result.stderr:
                    self.results_text.insert(tk.END, "\nErrors:\n" + result.stderr)
                self.results_text.config(state="disabled")

                if result.returncode == 0:
                    self.status_var.set("Users added successfully from CSV")
                else:
                    self.status_var.set("Failed to add users from CSV")

                # Refresh user list
                self.refresh_users()
            except Exception as e:
                messagebox.showerror("Error", f"Failed to add users: {str(e)}")
                self.status_var.set("Ready")

        threading.Thread(target=run_bulk_add).start()

    def download_template(self):
        save_path = filedialog.asksaveasfilename(
            title="Save CSV Template",
            defaultextension=".csv",
            filetypes=[("CSV Files", "*.csv")]
        )
        if save_path:
            try:
                with open(save_path, "w") as f:
                    f.write("username,fullname,password,shell,role\n")
                    f.write("jdoe,John Doe,Password123,/bin/bash,admin\n")
                    f.write("asmith,Alice Smith,SecurePass456,/bin/bash,student\n")
                    f.write("bwilson,Bob Wilson,GuestPass789,/bin/bash,guest\n")
                messagebox.showinfo("Template Saved", f"CSV template saved to {save_path}")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to save template: {str(e)}")

    def dry_run(self):
        csv_path = self.csv_path_var.get()
        if not csv_path:
            messagebox.showinfo("No File", "Please select a CSV file first")
            return

        if not os.path.exists(csv_path):
            messagebox.showerror("Error", "Selected file does not exist")
            return

        self.status_var.set("Performing dry run...")

        # Run in a separate thread to avoid freezing the UI
        def run_dry_run():
            try:
                cmd = ["bash", "./scripts/bulk_add.sh", "-f", csv_path, "-d"]
                result = subprocess.run(cmd, capture_output=True, text=True)

                self.results_text.config(state="normal")
                self.results_text.delete(1.0, tk.END)
                self.results_text.insert(tk.END, "DRY RUN RESULTS:\n\n")
                self.results_text.insert(tk.END, result.stdout)
                if result.stderr:
                    self.results_text.insert(tk.END, "\nErrors:\n" + result.stderr)
                self.results_text.config(state="disabled")

                self.status_var.set("Dry run completed")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to perform dry run: {str(e)}")
                self.status_var.set("Ready")

        threading.Thread(target=run_dry_run).start()

    # Helper Functions
    def open_dialog(self, script_name, preselected_username=None):
        dialog = UserDialog(self, script_name, preselected_username)
        self.wait_window(dialog)
        # Refresh user list after dialog closes
        self.refresh_users()

class UserDialog(tk.Toplevel):
    def __init__(self, parent, script_type, preselected_username=None):
        super().__init__(parent)
        self.script_type = script_type
        self.parent = parent

        # Configure dialog
        self.configure(bg=COLORS["bg"])
        self.resizable(False, False)

        # Make dialog modal
        self.transient(parent)
        self.grab_set()

        # Set up the appropriate form based on script type
        if script_type == "add_user":
            self.title("Add User")
            self.setup_add_user()
        elif script_type == "delete_user":
            self.title("Delete User")
            self.setup_delete_user(preselected_username)
        elif script_type == "lock_user":
            self.title("Lock/Unlock User")
            self.setup_lock_user(preselected_username)
        elif script_type == "modify_user":
            self.title("Modify User")
            self.setup_modify_user(preselected_username)

    def setup_add_user(self):
        self.geometry("400x350")
        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)

        ttk.Label(main_frame, text="Add New User", font=("Helvetica", 12, "bold")).pack(pady=(0, 20))

        # Create form
        form_frame = ttk.Frame(main_frame)
        form_frame.pack(fill="x")

        # Username
        ttk.Label(form_frame, text="Username:").grid(row=0, column=0, padx=5, pady=5, sticky="e")
        self.username = ttk.Entry(form_frame, width=30)
        self.username.grid(row=0, column=1, padx=5, pady=5)

        # Full Name
        ttk.Label(form_frame, text="Full Name:").grid(row=1, column=0, padx=5, pady=5, sticky="e")
        self.fullname = ttk.Entry(form_frame, width=30)
        self.fullname.grid(row=1, column=1, padx=5, pady=5)

        # Password
        ttk.Label(form_frame, text="Password:").grid(row=2, column=0, padx=5, pady=5, sticky="e")
        self.password = ttk.Entry(form_frame, width=30, show="*")
        self.password.grid(row=2, column=1, padx=5, pady=5)

        # Confirm Password
        ttk.Label(form_frame, text="Confirm Password:").grid(row=3, column=0, padx=5, pady=5, sticky="e")
        self.confirm_password = ttk.Entry(form_frame, width=30, show="*")
        self.confirm_password.grid(row=3, column=1, padx=5, pady=5)

        # Role - Make admin the default selection
        ttk.Label(form_frame, text="Role:").grid(row=4, column=0, padx=5, pady=5, sticky="e")
        self.role = ttk.Combobox(form_frame, values=["admin", "student", "guest"], width=28)
        self.role.grid(row=4, column=1, padx=5, pady=5)
        self.role.current(0)  # Default to admin

        # Shell
        ttk.Label(form_frame, text="Shell:").grid(row=5, column=0, padx=5, pady=5, sticky="e")
        self.shell = ttk.Combobox(form_frame, values=["/bin/bash", "/bin/sh", "/bin/zsh"], width=28)
        self.shell.grid(row=5, column=1, padx=5, pady=5)
        self.shell.current(0)  # Default to bash

        # Buttons
        btn_frame = ttk.Frame(main_frame)
        btn_frame.pack(pady=20)

        ttk.Button(btn_frame, text="Add User", command=self.execute_add_user).grid(row=0, column=0, padx=10)
        ttk.Button(btn_frame, text="Cancel", command=self.destroy).grid(row=0, column=1, padx=10)

    def setup_delete_user(self, preselected_username):
        self.geometry("400x250")
        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)

        ttk.Label(main_frame, text="Delete User", font=("Helvetica", 12, "bold")).pack(pady=(0, 20))

        # Create form
        form_frame = ttk.Frame(main_frame)
        form_frame.pack(fill="x")

        # Username
        ttk.Label(form_frame, text="Username:").grid(row=0, column=0, padx=5, pady=5, sticky="e")
        self.username = ttk.Entry(form_frame, width=30)
        self.username.grid(row=0, column=1, padx=5, pady=5)
        if preselected_username:
            self.username.insert(0, preselected_username)
            self.username.config(state="readonly")

        # Keep home directory option
        self.keep_home = tk.BooleanVar(value=False)
        ttk.Checkbutton(form_frame, text="Keep home directory", variable=self.keep_home).grid(row=1, column=1, padx=5, pady=5, sticky="w")

        # Warning label
        warning_label = ttk.Label(
            main_frame,
            text="Warning: This action cannot be undone!",
            foreground=COLORS["danger"],
            font=("Helvetica", 10, "bold")
        )
        warning_label.pack(pady=10)

        # Buttons
        btn_frame = ttk.Frame(main_frame)
        btn_frame.pack(pady=10)

        ttk.Button(btn_frame, text="Delete User", command=self.execute_delete_user).grid(row=0, column=0, padx=10)
        ttk.Button(btn_frame, text="Cancel", command=self.destroy).grid(row=0, column=1, padx=10)

    def setup_lock_user(self, preselected_username):
        self.geometry("400x300")
        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)

        ttk.Label(main_frame, text="Lock/Unlock User", font=("Helvetica", 12, "bold")).pack(pady=(0, 20))

        # Create form
        form_frame = ttk.Frame(main_frame)
        form_frame.pack(fill="x")

        # Username
        ttk.Label(form_frame, text="Username:").grid(row=0, column=0, padx=5, pady=5, sticky="e")
        self.username = ttk.Entry(form_frame, width=30)
        self.username.grid(row=0, column=1, padx=5, pady=5)
        if preselected_username:
            self.username.insert(0, preselected_username)
            self.username.config(state="readonly")

        # Action (lock or unlock)
        ttk.Label(form_frame, text="Action:").grid(row=1, column=0, padx=5, pady=5, sticky="e")
        self.action = ttk.Combobox(form_frame, values=["Lock", "Unlock"], width=28)
        self.action.grid(row=1, column=1, padx=5, pady=5)
        self.action.current(0)  # Default to lock

        # Reason
        ttk.Label(form_frame, text="Reason:").grid(row=2, column=0, padx=5, pady=5, sticky="e")
        self.reason = ttk.Entry(form_frame, width=30)
        self.reason.grid(row=2, column=1, padx=5, pady=5)

        # Expiration (days)
        ttk.Label(form_frame, text="Expire After (days):").grid(row=3, column=0, padx=5, pady=5, sticky="e")
        self.expire_days = ttk.Spinbox(form_frame, from_=0, to=365, width=5)
        self.expire_days.grid(row=3, column=1, padx=5, pady=5, sticky="w")
        ttk.Label(form_frame, text="(0 = no expiration)").grid(row=3, column=1, padx=(50, 5), pady=5, sticky="w")

        # Buttons
        btn_frame = ttk.Frame(main_frame)
        btn_frame.pack(pady=20)

        ttk.Button(btn_frame, text="Apply", command=self.execute_lock_user).grid(row=0, column=0, padx=10)
        ttk.Button(btn_frame, text="Cancel", command=self.destroy).grid(row=0, column=1, padx=10)

    def setup_modify_user(self, preselected_username):
        self.geometry("450x400")  # Increased height to accommodate the new field
        main_frame = ttk.Frame(self)
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)

        ttk.Label(main_frame, text="Modify User", font=("Helvetica", 12, "bold")).pack(pady=(0, 20))

        # Create form
        form_frame = ttk.Frame(main_frame)
        form_frame.pack(fill="x")

        # Current Username
        ttk.Label(form_frame, text="Current Username:").grid(row=0, column=0, padx=5, pady=5, sticky="e")
        self.username = ttk.Entry(form_frame, width=30)
        self.username.grid(row=0, column=1, padx=5, pady=5)
        if preselected_username:
            self.username.insert(0, preselected_username)
            self.username.config(state="readonly")

        # New Username
        ttk.Label(form_frame, text="New Username:").grid(row=1, column=0, padx=5, pady=5, sticky="e")
        self.new_username = ttk.Entry(form_frame, width=30)
        self.new_username.grid(row=1, column=1, padx=5, pady=5)

        # New Role - Added this section
        ttk.Label(form_frame, text="New Role:").grid(row=2, column=0, padx=5, pady=5, sticky="e")
        self.role = ttk.Combobox(form_frame, values=["admin", "student", "guest"], width=28)
        self.role.grid(row=2, column=1, padx=5, pady=5)

        # New Shell
        ttk.Label(form_frame, text="New Shell:").grid(row=3, column=0, padx=5, pady=5, sticky="e")
        self.shell = ttk.Combobox(form_frame, values=["/bin/bash", "/bin/sh", "/bin/zsh"], width=28)
        self.shell.grid(row=3, column=1, padx=5, pady=5)

        # New Home Directory
        ttk.Label(form_frame, text="New Home Directory:").grid(row=4, column=0, padx=5, pady=5, sticky="e")
        self.home_dir = ttk.Entry(form_frame, width=30)
        self.home_dir.grid(row=4, column=1, padx=5, pady=5)

        # Move Home Contents
        self.move_home = tk.BooleanVar(value=True)
        ttk.Checkbutton(form_frame, text="Move home directory contents", variable=self.move_home).grid(row=5, column=1, padx=5, pady=5, sticky="w")

        # Groups to Add
        ttk.Label(form_frame, text="Add to Groups:").grid(row=6, column=0, padx=5, pady=5, sticky="e")
        self.groups = ttk.Entry(form_frame, width=30)
        self.groups.grid(row=6, column=1, padx=5, pady=5)
        ttk.Label(form_frame, text="(comma-separated)").grid(row=6, column=1, padx=(250, 5), pady=5, sticky="w")

        # Buttons
        btn_frame = ttk.Frame(main_frame)
        btn_frame.pack(pady=20)

        ttk.Button(btn_frame, text="Modify User", command=self.execute_modify_user).grid(row=0, column=0, padx=10)
        ttk.Button(btn_frame, text="Cancel", command=self.destroy).grid(row=0, column=1, padx=10)

    def execute_add_user(self):
        username = self.username.get()
        fullname = self.fullname.get()
        password = self.password.get()
        confirm_password = self.confirm_password.get()
        role = self.role.get()
        shell = self.shell.get()

        # Validate inputs
        if not username:
            messagebox.showerror("Error", "Username is required")
            return
        if not password:
            messagebox.showerror("Error", "Password is required")
            return
        if password != confirm_password:
            messagebox.showerror("Error", "Passwords do not match")
            return
        if not role:
            messagebox.showerror("Error", "Role is required")
            return

        # Create a temporary file with inputs
        with open("temp_input.txt", "w") as f:
            f.write(f"{username}\n{role}\n{password}\n{password}\n")

        try:
            # Run the bash script directly (assuming proper permissions)
            cmd = ["bash", "./scripts/add_user.sh"]
            process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            # Send the input file content
            with open("temp_input.txt", "r") as f:
                input_content = f.read()
            stdout, stderr = process.communicate(input=input_content)

            if "successfully" in stdout:
                messagebox.showinfo("Success", f"User {username} added successfully with role {role}")
                self.parent.status_var.set(f"User {username} added successfully")
                self.destroy()
            else:
                error_msg = stderr if stderr else stdout
                messagebox.showerror("Error", f"Failed to add user:\n{error_msg}")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to add user: {str(e)}")
        finally:
            # Clean up
            if os.path.exists("temp_input.txt"):
                os.remove("temp_input.txt")

    def execute_delete_user(self):
        username = self.username.get()
        keep_home = "y" if self.keep_home.get() else "n"

        if not username:
            messagebox.showerror("Error", "Username is required")
            return

        # Confirm deletion
        confirm = messagebox.askyesno(
            "Confirm Deletion",
            f"Are you sure you want to delete user '{username}'?\nThis action cannot be undone!"
        )
        if not confirm:
            return

        # Create a temporary file with inputs
        with open("temp_input.txt", "w") as f:
            f.write(f"{username}\ny\n{keep_home}\n")

        try:
            # Run the bash script directly
            cmd = ["bash", "./scripts/delete_user.sh"]
            process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            # Send the input file content
            with open("temp_input.txt", "r") as f:
                input_content = f.read()
            stdout, stderr = process.communicate(input=input_content)

            if "successfully" in stdout:
                messagebox.showinfo("Success", f"User {username} deleted successfully")
                self.parent.status_var.set(f"User {username} deleted successfully")
                self.destroy()
            else:
                error_msg = stderr if stderr else stdout
                messagebox.showerror("Error", f"Failed to delete user:\n{error_msg}")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to delete user: {str(e)}")
        finally:
            # Clean up
            if os.path.exists("temp_input.txt"):
                os.remove("temp_input.txt")

    def execute_lock_user(self):
        username = self.username.get()
        action = self.action.get().lower()
        reason = self.reason.get()
        expire_days = self.expire_days.get()

        if not username:
            messagebox.showerror("Error", "Username is required")
            return

        # Build command
        cmd = ["bash", "./scripts/lock_user.sh"]
        if action == "unlock":
            cmd.extend(["-u"])
        if reason:
            cmd.extend(["-r", reason])
        if expire_days and expire_days != "0":
            cmd.extend(["-e", expire_days])

        # Create a temporary file with inputs
        with open("temp_input.txt", "w") as f:
            f.write(f"{username}\n{reason}\n")

        try:
            process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            # Send the input file content
            with open("temp_input.txt", "r") as f:
                input_content = f.read()
            stdout, stderr = process.communicate(input=input_content)

            if "successfully" in stdout:
                action_text = "unlocked" if action == "unlock" else "locked"
                messagebox.showinfo("Success", f"User {username} {action_text} successfully")
                self.parent.status_var.set(f"User {username} {action_text} successfully")
                self.destroy()
            else:
                error_msg = stderr if stderr else stdout
                messagebox.showerror("Error", f"Failed to {action} user:\n{error_msg}")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to {action} user: {str(e)}")
        finally:
            # Clean up
            if os.path.exists("temp_input.txt"):
                os.remove("temp_input.txt")

    def execute_modify_user(self):
        username = self.username.get()
        new_username = self.new_username.get()
        new_role = self.role.get()
        shell = self.shell.get()
        home_dir = self.home_dir.get()
        move_home = self.move_home.get()
        groups = self.groups.get()

        if not username:
            messagebox.showerror("Error", "Current username is required")
            return

        # Check if any modifications are specified
        if not any([new_username, new_role, shell, home_dir, groups]):
            messagebox.showinfo("No Changes", "No modifications specified")
            return

        # Build command
        cmd = ["bash", "./scripts/modify_user.sh", "-u", username]
        if new_username:
            cmd.extend(["-n", new_username])
        if shell:
            cmd.extend(["-s", shell])
        if home_dir:
            cmd.extend(["-d", home_dir])
        if move_home:
            cmd.extend(["-m"])
        if groups:
            cmd.extend(["-a", "-G", groups])
        
        # Add role parameter if specified
        if new_role:
            cmd.extend(["-r", new_role])

        try:
            process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            stdout, stderr = process.communicate()

            if "successfully" in stdout:
                messagebox.showinfo("Success", f"User {username} modified successfully")
                self.parent.status_var.set(f"User {username} modified successfully")
                self.destroy()
            else:
                error_msg = stderr if stderr else stdout
                messagebox.showerror("Error", f"Failed to modify user:\n{error_msg}")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to modify user: {str(e)}")

if __name__ == "__main__":
    app = UserCTRLApp()
    app.mainloop()
