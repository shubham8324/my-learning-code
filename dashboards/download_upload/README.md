# FileOps Console

A lightweight **remote file manager** built with **Flask + SSH + SCP** for browsing, searching, uploading, and downloading files from a local or remote Linux host through a single web UI.

## What it does

FileOps Console lets you:

- browse directories on the local machine or a remote server
- search files recursively by name
- download individual files or whole folders
- upload one or more files to a target path
- keep a simple history of remote IPs, users, and default paths
- switch between **Self** and **Prod** environments from the UI

It is designed for fast operational file handling where you need a browser-based interface instead of logging in and using SSH manually.

## Tech stack

- **Backend:** Python 3.6+, Flask
- **Remote access:** SSH and SCP
- **UI:** HTML, CSS, and vanilla JavaScript
- **Storage:** flat config file (`IP_prod.conf`) for host history

## Project structure

```text
.
├── download_upload.py   # Flask backend and API routes
├── index.html           # UI for browsing, upload, search, and history
└── IP_prod.conf         # Saved prod entries: env|ip|username|path
```

## Key features

### 1) Remote browsing
Browse a directory tree and view:

- name
- size
- modified time
- owner
- file/folder type

### 2) Recursive search
Search filenames recursively from a base path using the `/api/search` endpoint.

### 3) Upload support
Upload one or more files to a selected destination path.

### 4) Download support
Download:

- a single file directly
- a directory as a `.tar.gz` archive

### 5) Saved history
The app stores remote access history in `IP_prod.conf` so frequently used hosts and users are easier to reuse.

### 6) Self vs remote mode
The app can operate on:

- the local machine (`Self`)
- a remote server (`Prod`)

## How it works

The backend uses SSH to execute commands on the remote host and SCP to transfer files. For local operations, it uses Python and the local filesystem directly.

## Requirements

- Python 3.6 or newer
- Flask
- SSH access to remote hosts
- SCP available on the machine running the app
- passwordless SSH keys recommended for smooth usage

Install Flask:

```bash
pip install flask
```

## Configuration

The backend uses these important variables in `download_upload.py`:

- `BASE_PATH`: directory where `index.html` and `IP_prod.conf` are stored
- `SELF_IP`: IP address used for the local host in the UI
- `PORT`: web server port
- `MAX_FILE_SIZE`: upload/download limit, set to **5 GB** per file or folder archive

Before running, update `BASE_PATH` to match the location of your repo/files.

## `IP_prod.conf` format

Each line follows this pattern:

```text
prod|10.143.67.29|sik8susr|/home/sik8susr
```

Format:

```text
env|ip|username|path
```

## Run locally

```bash
python3 download_upload.py
```

Then open:

```text
http://10.10.10.10:20202
```

> Note: the host and port come from the hardcoded values in the script. Adjust them if needed for your environment.

## API endpoints

### `GET /api/config`
Returns the saved config, self IP, and current local username.

### `POST /api/browse`
Lists the contents of a directory.

Example payload:

```json
{
  "env": "prod",
  "ip": "10.20.20.20",
  "username": "username",
  "path": "/home/username",
  "path_save_enabled": true
}
```

### `POST /api/search`
Searches recursively for filenames matching a query.

### `POST /api/download`
Downloads a file or directory.

### `POST /api/upload`
Uploads files to a target path.

### `GET /api/ips/<env>`
Returns unique IPs from the saved config.

### `POST /api/users`
Returns usernames for a given IP.

### `POST /api/paths`
Returns saved paths for a given IP and username.

### `POST /api/history/delete`
Deletes selected saved history entries.

### `POST /api/homedir`
Returns the home directory for a given IP and username.

## Operational notes

- Remote operations rely on SSH/SCP access.
- `StrictHostKeyChecking=no` is used in the code for convenience.
- The backend limits file/folder transfers to **5 GB**.
- Directory downloads are compressed into `.tar.gz` before download.
- The app currently persists history only for the `prod` config file.

## Security note

This tool is built for internal operational use. If you plan to expose it beyond a trusted network, add authentication, authorization, input hardening, and secrets management before production use.

## Suggested improvements

- add login/authentication
- store config in a database instead of a flat file
- support multiple environments in separate config files
- add progress bars for upload/download
- add audit logging
- add role-based access control

## Why this project is useful

This is a practical internal utility for teams that frequently manage files across multiple Linux hosts and want a single browser-based interface for:

- quick file access
- file transfers
- remote host navigation
- operational workflows during debugging or maintenance

## Author

Developed by **Shubham Patel**
