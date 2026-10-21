
<div align="center">

# 🛡️ NullWatch

### See the signals. Catch the patterns.

A lightweight Bash-based Linux security log monitor that analyzes web server access logs, detects repeated HTTP errors, flags suspicious IP addresses, and generates security reports.

<br>

![Bash](https://img.shields.io/badge/Bash-Shell_Scripting-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-System_Administration-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Security](https://img.shields.io/badge/Security-Log_Analysis-111827?style=for-the-badge&logo=shield&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

**A small tool for understanding a big problem: suspicious activity hidden in server logs.**

[Features](#-features) · [Installation](#-installation) · [Usage](#-usage) · [How It Works](#-how-it-works) · [Roadmap](#-roadmap)

</div>

---

## 🧠 What is NullWatch?

Every web server generates logs. Those logs record requests, response codes, and other information about activity on the server.

Sometimes, repeated failed requests can indicate directory enumeration, attempts to discover hidden files, or other suspicious behavior.

**NullWatch helps make those patterns easier to spot.**

It is a beginner-friendly security monitoring project written in Bash. It reads access logs, counts selected HTTP error responses by IP address, compares the counts against a configurable threshold, and writes a report.

> NullWatch is a learning project for Linux system administration and basic security monitoring. It identifies suspicious patterns; it does not prove that an attack occurred.

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 Log Analysis | Reads web server access logs |
| 🚨 Suspicious Activity Detection | Tracks HTTP `401`, `403`, and `404` responses |
| 🌐 IP-Based Aggregation | Counts matching responses from each IP |
| ⚙️ Configurable Threshold | Defines when an IP should trigger an alert |
| 📄 Security Reports | Saves findings to a text report |
| 🧪 Mock Log Generation | Creates sample data when the input log is missing |
| 🐧 Linux Native | Uses Bash, AWK, and standard command-line utilities |

## ⚙️ How It Works

```text
        ┌──────────────────────┐
        │   Web Server Logs    │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │   Parse HTTP Status  │
        │     401 / 403 / 404  │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  Count Errors by IP  │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ Compare to Threshold │
        └──────────┬───────────┘
                   │
             ┌─────┴─────┐
             ▼           ▼
       ┌──────────┐ ┌──────────┐
       │  Alert   │ │ No Alert │
       └────┬─────┘ └────┬─────┘
            └──────┬─────┘
                   ▼
        ┌──────────────────────┐
        │  Generate Report     │
        └──────────────────────┘
```

### HTTP status codes monitored

- **401 — Unauthorized:** Authentication is required or has failed.
- **403 — Forbidden:** The server refuses the request.
- **404 — Not Found:** The requested resource could not be found.

Repeated requests for paths such as `/admin`, `/config.php`, or `/backup.sql` may warrant investigation, particularly when accompanied by other suspicious behavior.

## 🖥️ Installation

### Requirements

- Linux or Windows Subsystem for Linux (WSL)
- Bash
- AWK
- Git
- Standard utilities such as `sort` and `date`

### 1. Clone the repository

Open your Linux terminal and run:

```bash
git clone https://github.com/YOUR-USERNAME/nullwatch.git
```

Replace `YOUR-USERNAME` with your GitHub username.

**What does `git clone` do?**

It downloads a copy of the repository to your computer, including its tracked files and Git history.

### 2. Enter the project directory

```bash
cd nullwatch
```

The `cd` command changes your current working directory to the project folder.

### 3. Make the script executable

```bash
chmod +x server_health.sh
```

This adds the executable permission to the script, allowing you to run it directly.

### 4. Run NullWatch

```bash
./server_health.sh
```

If `mock_access.log` does not exist, the script creates sample log data automatically.

### 5. View the security report

```bash
cat security_report.txt
```

The report contains the generation time, input file, configured threshold, and any detected threshold breaches.

## 🚀 Usage

Run the script from the project directory:

```bash
./server_health.sh
```

Example output using the included mock data:

```text
==============================================
       LINUX SECURITY LOG MONITOR
==============================================
Analyzing HTTP error responses...

Suspicious traffic summary:
----------------------------------------------
IP: 192.168.1.50 | Suspicious responses: 6
ALERT: IP 192.168.1.50 generated 6 suspicious responses.
IP: 192.168.1.99 | Suspicious responses: 1
----------------------------------------------
Report saved to: ./security_report.txt
Analysis complete.
```

The exact ordering of IP addresses may vary.

### Generated files

| File | Purpose |
|---|---|
| `mock_access.log` | Sample access log used for testing |
| `security_report.txt` | Generated security report |

These files are generated locally and excluded from Git using `.gitignore`.

## 🔧 Configuration

Open `server_health.sh` and find the configuration section:

```bash
LOG_FILE="./mock_access.log"
REPORT_FILE="./security_report.txt"
THRESHOLD=5
```

Change these variables to customize the input file, report location, or alert threshold.

For example, setting `THRESHOLD=10` means an IP must generate at least ten matching responses to trigger an alert.

**Current detection logic:** NullWatch counts matching responses per IP across the entire log file. It does not currently evaluate activity within a rolling time window.

## 📁 Project Structure

```text
nullwatch/
├── server_health.sh       # Main monitoring script
├── README.md              # Documentation
├── .gitignore             # Excludes generated files
└── LICENSE                # MIT License
```

The mock log and generated report appear in the directory after running the script, but they are not committed to Git.

## 🧩 Skills Demonstrated

This project provides practical experience with:

- **Linux:** file permissions, filesystem navigation, and terminal commands
- **Bash:** variables, conditionals, loops, and input processing
- **AWK:** parsing structured text and aggregating records
- **Pipelines:** connecting utilities to process log data
- **Security fundamentals:** HTTP status codes and suspicious request patterns
- **Troubleshooting:** validating log formats and testing detection logic
- **Git and GitHub:** source control and project documentation

## 🛣️ Roadmap

Potential future improvements:

- [ ] Add time-window-based detection
- [ ] Validate malformed log entries
- [ ] Support Apache and Nginx log formats explicitly
- [ ] Add command-line arguments for configuration
- [ ] Add automated tests for detection logic
- [ ] Export reports to CSV or JSON
- [ ] Add optional email notifications
- [ ] Support scheduled execution using cron
- [ ] Add optional detection for repeated failed SSH logins

## ⚠️ Limitations

- This is a basic log-analysis tool, not a full intrusion detection system.
- HTTP errors can occur during normal use and are not proof of malicious activity.
- The parser expects a common access-log format in which the status code is field 8.
- Detection uses a fixed threshold across the entire log, not a time-based threshold.
- NullWatch does not block IP addresses, modify firewall rules, or prevent attacks.
- The current mock data is intended for testing, not real-world threat validation.

## 🔒 Security Disclaimer

Use NullWatch only with logs you own or are authorized to inspect.

Review alerts before taking action. Do not automatically block IP addresses based solely on HTTP error counts.

## 🤝 Contributing

Contributions, bug reports, and suggestions are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Make your changes and test them.
4. Submit a pull request describing the improvement.

## 📜 License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE) for details.

---

<div align="center">

**Built to learn Linux. Designed to watch the logs.**

`nullwatch` · Bash · Linux · Security

</div>

