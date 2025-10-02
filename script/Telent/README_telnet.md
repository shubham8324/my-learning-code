# 🌐 Telnet Connectivity Checker

> A **professional Bash script** to check multiple server/port connectivity using `telnet`.  
> Logs results in **human-readable logs** and **CSV format** for easy analysis.  

---

## 🚀 Features

- ✅ **Automatic concurrency adjustment**
  - 3 parallel connections for `<100` targets  
  - 5 parallel connections for `100–500` targets  
  - 10 parallel connections for `>500` targets  

- ✅ **Portable and fast**
  - Works on older Bash versions  
  - Runs multiple telnet connections in parallel without flooding  

- ✅ **Logging**
  - `Telnet_Connected.txt` → connected servers  
  - `Telnet_Failed.txt` → failed servers  
  - `Telnet_Results.csv` → CSV format for Excel/analysis  

- ✅ **Suppresses unnecessary output**
  - Prevents “Terminated” messages from showing up  

---

## 📋 Usage

1️⃣ **Ensure your serverlist.txt is correctly formatted**

Use spaces or tabs consistently, no extra spaces at the end:

# IP Address   Port
- 8.8.8.8       53
- 1.1.1.1       80
- 192.168.1.10  22

<img width="365" height="166" alt="image" src="https://github.com/user-attachments/assets/62d5df21-a062-4c79-9611-2f5610c4c168" />

Avoid mixing multiple spaces or tabs inconsistently.


2️⃣ **Make the script executable:**

chmod +x telnet_checker.sh

3️⃣ **Run the script:**

./telnet_checker.sh
If no file is provided, it defaults to serverlist.txt.


🗂 **Output Files**
| File                   | Description                     |
| ---------------------- | ------------------------------- |
| `Telnet_Connected.txt` | Successfully connected servers  |
| `Telnet_Failed.txt`    | Failed servers                  |
| `Telnet_Results.csv`   | CSV file for Excel / automation |



⚙️ **Notes**

- The script automatically throttles parallel jobs to avoid overwhelming the network.
- Works completely offline — no external dependencies required.
- Can be extended to include retry logic or email notifications.


✨ **Example**

./telnet_checker.sh

Output:
2025-10-02 22:15:01 - 8.8.8.8         53    ......Connected
2025-10-02 22:15:02 - 1.1.1.1         80    ......Connected
2025-10-02 22:15:03 - 192.168.1.10    22    ......Failed



👤 Author 

Shubham Patel 🖋️
