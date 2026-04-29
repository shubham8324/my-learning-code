#!/usr/bin/env python3
"""
Remote File Manager - Master Server
Python 3.6+ compatible
Run: /home/tibusr/Python/Python-3.6.4/python download_upload.py
Access: http://10.10.10.10:20202
"""

import os
import sys
import json
import subprocess
import tempfile
import shutil
import tarfile

from flask import Flask, request, jsonify, send_file

# ── CONFIG ────────────────────────────────────────────────────────────────────
BASE_PATH    = "/your/path/download_upload" ##your path
HTML_FILE    = os.path.join(BASE_PATH, "index.html")
PROD_CONF    = os.path.join(BASE_PATH, "IP_prod.conf")
SELF_IP      = "10.10.10.10" ##your IP
PORT         = 20202 ##your port

# 5 GB limit for upload/download
MAX_FILE_SIZE = 5 * 1024 * 1024 * 1024  # 5 GB in bytes

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 5 * 1024 * 1024 * 1024  # 5 GB max upload

# ── CONF HELPERS ──────────────────────────────────────────────────────────────

def read_conf(conf_path):
    entries = []
    if not os.path.exists(conf_path):
        return entries
    with open(conf_path, "r") as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split("|")
            if len(parts) == 4:
                entries.append({
                    "env":      parts[0].strip(),
                    "ip":       parts[1].strip(),
                    "username": parts[2].strip(),
                    "path":     parts[3].strip(),
                })
    return entries


def write_conf(conf_path, entries):
    dir_name = os.path.dirname(conf_path)
    if dir_name:
        try:
            os.makedirs(dir_name)
        except OSError:
            pass
    with open(conf_path, "w") as fh:
        for e in entries:
            fh.write("{env}|{ip}|{username}|{path}\n".format(**e))


def ensure_conf_entry(env, ip, username, path, path_save_enabled=False):
    """Save env|ip|username|/home/username to conf.

    Rules:
    - Never save self / localhost entries.
    - Only save when path_save_enabled is True (path history toggle on frontend).
    - Path stored in conf is ALWAYS /home/<username>, never a sub-path.
    - One entry per (env, ip, username) — no duplicates.
    """
    # Block self-IP entries entirely
    if is_self(ip):
        return

    # Only write when the frontend has path-save enabled
    if not path_save_enabled:
        return

    conf_path = PROD_CONF
    default_path = "/home/" + username

    entries = read_conf(conf_path)
    # Deduplicate: if this (env, ip, username) already exists, leave it untouched
    for e in entries:
        if e["env"] == env and e["ip"] == ip and e["username"] == username:
            return

    entries.append({"env": env, "ip": ip, "username": username, "path": default_path})
    write_conf(conf_path, entries)


def remove_conf_entry(env, ip, username, path):
    """Remove a specific entry from the appropriate conf file."""
    if is_self(ip):
        return
    conf_path = PROD_CONF
    entries = read_conf(conf_path)
    entries = [e for e in entries if not (
        e["env"] == env and e["ip"] == ip and e["username"] == username
    )]
    write_conf(conf_path, entries)


def get_all_entries():
    return {
        "prod": read_conf(PROD_CONF),
    }

# ── SSH HELPERS ───────────────────────────────────────────────────────────────

def is_self(ip):
    return ip in ("self", "localhost", SELF_IP, "127.0.0.1")


def run_local(cmd, timeout=30):
    proc = subprocess.Popen(
        cmd, shell=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    try:
        out, err = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        proc.kill()
        out, err = proc.communicate()
    return out.decode("utf-8", errors="replace"), \
           err.decode("utf-8", errors="replace"), \
           proc.returncode


def ssh_run(ip, username, cmd, timeout=30):
    if is_self(ip):
        return run_local(cmd, timeout)
    ssh_prefix = (
        "ssh -o StrictHostKeyChecking=no "
        "-o ConnectTimeout=10 "
        "-o BatchMode=yes "
        "{user}@{ip}".format(user=username, ip=ip)
    )
    full = "{prefix} '{cmd}'".format(prefix=ssh_prefix, cmd=cmd.replace("'", "'\\''"))
    return run_local(full, timeout)


def list_path(ip, username, path):
    """Return JSON-able dict describing directory contents with mtime and size."""
    py_snippet = (
        "import os,json,stat,pwd;"
        "p='{p}';"
        "exists=os.path.exists(p);"
        "is_dir=os.path.isdir(p);"
        "items=[];"
        "["
        "items.append({{"
        "'name':e,"
        "'path':os.path.join(p,e),"
        "'is_dir':os.path.isdir(os.path.join(p,e)),"
        "'size':os.path.getsize(os.path.join(p,e)) if os.path.isfile(os.path.join(p,e)) else 0,"
        "'mtime':int(os.path.getmtime(os.path.join(p,e))),"
        "'owner':(lambda s:(pwd.getpwuid(s.st_uid).pw_name if hasattr(pwd,'getpwuid') else str(s.st_uid)))(os.stat(os.path.join(p,e)))"
        "}}) for e in sorted(os.listdir(p))"
        "] if is_dir else None;"
        "print(json.dumps({{'items':items,'cwd':p,'exists':exists,'is_dir':is_dir}}))"
    ).format(p=path.replace("'", "\\'"))

    cmd = "python3 -c \"{snip}\"".format(snip=py_snippet)
    stdout, stderr, rc = ssh_run(ip, username, cmd, timeout=20)
    try:
        data = json.loads(stdout.strip())
        if data.get("items") is None:
            data["items"] = []
        return data
    except Exception:
        # fallback to raw ls output
        out2, _, _ = ssh_run(ip, username, "ls -la {p} 2>&1".format(p=path))
        return {
            "items":   [],
            "raw":     out2,
            "error":   stderr.strip(),
            "cwd":     path,
            "exists":  (rc == 0),
            "is_dir":  True,
        }


def get_remote_size(ip, username, path):
    """Get size of a remote path in bytes using du."""
    cmd = "du -sb {p} 2>/dev/null | cut -f1".format(p=path)
    out, _, rc = ssh_run(ip, username, cmd, timeout=60)
    try:
        return int(out.strip())
    except (ValueError, TypeError):
        return 0


def get_home_dir(ip, username):
    if is_self(ip):
        if username and username != "self":
            expanded = os.path.expanduser("~" + username)
            return expanded if expanded != ("~" + username) else "/home/" + username
        return os.path.expanduser("~")
    out, _, _ = ssh_run(ip, username, "echo $HOME")
    return out.strip() or "/home/" + username


def make_targz(source_path, output_path, arcname=None):
    """Create a tar.gz archive from source_path."""
    with tarfile.open(output_path, "w:gz") as tar:
        tar.add(source_path, arcname=arcname or os.path.basename(source_path))

# ── ROUTES ────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    with open(HTML_FILE, "r") as fh:
        return fh.read()


@app.route("/api/config", methods=["GET"])
def api_config():
    self_user = os.environ.get("USER", os.environ.get("LOGNAME", "user"))
    return jsonify({"entries": get_all_entries(), "self_ip": SELF_IP, "self_user": self_user})


@app.route("/api/browse", methods=["POST"])
def api_browse():
    data              = request.json or {}
    env               = data.get("env", "prod")
    ip                = data.get("ip", SELF_IP)
    username          = data.get("username", "") or ""
    path              = data.get("path", "") or ""
    path_save_enabled = bool(data.get("path_save_enabled", False))

    if is_self(ip):
        ip = SELF_IP
    if not username or username == "self":
        username = os.environ.get("USER", "root")
    if not path:
        path = get_home_dir(ip, username)

    result = list_path(ip, username, path)
    result["ip"]       = ip
    result["username"] = username
    result["env"]      = env

    # Save env|ip|username|/home/username to conf only when path_save_enabled
    try:
        ensure_conf_entry(env, ip, username, path, path_save_enabled)
    except Exception:
        pass

    return jsonify(result)


@app.route("/api/search", methods=["POST"])
def api_search():
    """Recursive find from a base path matching a filename pattern.
    Uses 'find -ls' so no python3 needed on the remote/self machine.
    find -ls columns: inode blocks perms links owner group size month day time path...
    """
    data     = request.json or {}
    ip       = data.get("ip", SELF_IP)
    username = data.get("username", "") or ""
    path     = data.get("path", "/") or "/"
    query    = data.get("query", "").strip()

    if is_self(ip):
        ip = SELF_IP
    if not username or username == "self":
        username = os.environ.get("USER", "root")
    if not query:
        return jsonify({"error": "No search query", "items": []}), 400

    # Sanitise — strip shell-dangerous chars
    safe_q = query.replace("'", "").replace('"', "").replace(";", "") \
                  .replace("&", "").replace("|", "").replace("\\", "")
    safe_p = path.rstrip("/") or "/"
    safe_p_sh = safe_p.replace("'", "\\'")

    # find -ls gives full detail in one shot — no python3 needed on remote
    cmd = (
        "find '{p}' -name '*{q}*' -not -path '*/.git/*' -ls 2>/dev/null | head -500"
    ).format(p=safe_p_sh, q=safe_q)

    stdout, stderr, rc = ssh_run(ip, username, cmd, timeout=65)

    items = []
    for line in stdout.strip().split("\n"):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        # find -ls: inode(0) blocks(1) perms(2) links(3) owner(4) group(5) size(6)
        #           month(7) day(8) time_or_year(9) path(10+)
        if len(parts) < 11:
            continue
        try:
            perms    = parts[2]
            owner    = parts[4]
            size     = int(parts[6])
            fp       = " ".join(parts[10:])   # handles spaces in filenames
            if not fp or fp == safe_p:
                continue
            name     = os.path.basename(fp)
            parent   = os.path.dirname(fp)
            is_dir   = perms.startswith("d")
            mtime    = _parse_find_ls_mtime(parts[7], parts[8], parts[9])
            items.append({
                "name":   name,
                "path":   fp,
                "parent": parent,
                "is_dir": is_dir,
                "size":   0 if is_dir else size,
                "mtime":  mtime,
                "owner":  owner,
            })
        except (IndexError, ValueError):
            continue

    return jsonify({"items": items, "base": safe_p, "query": query})


def _parse_find_ls_mtime(month_s, day_s, time_or_year_s):
    """Parse the 3-field date from find -ls output into a Unix timestamp."""
    MONTHS = {"Jan":1,"Feb":2,"Mar":3,"Apr":4,"May":5,"Jun":6,
              "Jul":7,"Aug":8,"Sep":9,"Oct":10,"Nov":11,"Dec":12}
    import time as _time
    try:
        mon = MONTHS.get(month_s, 0)
        day = int(day_s)
        now = _time.localtime()
        if ":" in time_or_year_s:          # recent — HH:MM, year = current
            hh, mm = time_or_year_s.split(":")
            year = now.tm_year
            t = _time.mktime((year, mon, day, int(hh), int(mm), 0, 0, 0, -1))
            if t > _time.time():           # future → last year
                t = _time.mktime((year - 1, mon, day, int(hh), int(mm), 0, 0, 0, -1))
        else:                              # older — year given, time = 00:00
            year = int(time_or_year_s)
            t = _time.mktime((year, mon, day, 0, 0, 0, 0, 0, -1))
        return int(t)
    except Exception:
        return 0


@app.route("/api/download", methods=["POST"])
def api_download():
    data     = request.json or {}
    env      = data.get("env", "prod")
    ip       = data.get("ip", SELF_IP)
    username = data.get("username", "") or ""
    path     = data.get("path", "") or ""
    is_dir   = data.get("is_dir", False)

    if is_self(ip):
        ip = SELF_IP
    if not username or username == "self":
        username = os.environ.get("USER", "root")

    filename = os.path.basename(path.rstrip("/")) or "download"
    tmp_dir  = tempfile.mkdtemp()

    try:
        if is_self(ip):
            local_path = path

            # Check size limit
            if os.path.isfile(local_path):
                fsize = os.path.getsize(local_path)
                if fsize > MAX_FILE_SIZE:
                    shutil.rmtree(tmp_dir, ignore_errors=True)
                    return jsonify({"error": "File size ({}) exceeds 5 GB limit".format(
                        _fmt_size(fsize))}), 413

                return send_file(
                    local_path,
                    as_attachment=True,
                    attachment_filename=filename,
                )

            elif os.path.isdir(local_path):
                # Compress as tar.gz
                tgz_name = filename + ".tar.gz"
                tgz_path = os.path.join(tmp_dir, tgz_name)
                make_targz(local_path, tgz_path, arcname=filename)

                # Check compressed size
                tgz_size = os.path.getsize(tgz_path)
                if tgz_size > MAX_FILE_SIZE:
                    shutil.rmtree(tmp_dir, ignore_errors=True)
                    return jsonify({"error": "Compressed archive ({}) exceeds 5 GB limit".format(
                        _fmt_size(tgz_size))}), 413

                return send_file(
                    tgz_path,
                    as_attachment=True,
                    attachment_filename=tgz_name,
                    mimetype="application/gzip",
                )
            else:
                shutil.rmtree(tmp_dir, ignore_errors=True)
                return jsonify({"error": "Path does not exist"}), 404

        else:
            # Remote: check size first
            remote_size = get_remote_size(ip, username, path)
            if remote_size > MAX_FILE_SIZE:
                shutil.rmtree(tmp_dir, ignore_errors=True)
                return jsonify({"error": "Remote path size ({}) exceeds 5 GB limit. Compress to tar.gz first to reduce size.".format(
                    _fmt_size(remote_size))}), 413

            tmp_local = os.path.join(tmp_dir, filename)
            scp_cmd = (
                "scp -o StrictHostKeyChecking=no -o ConnectTimeout=15 "
                "-r {user}@{ip}:{path} {dest}"
            ).format(user=username, ip=ip, path=path, dest=tmp_local)
            out, err, rc = run_local(scp_cmd, timeout=300)
            if rc != 0:
                shutil.rmtree(tmp_dir, ignore_errors=True)
                return jsonify({"error": err or "SCP failed"}), 500

            if os.path.isdir(tmp_local):
                # Compress as tar.gz
                tgz_name = filename + ".tar.gz"
                tgz_path = os.path.join(tmp_dir, tgz_name)
                make_targz(tmp_local, tgz_path, arcname=filename)

                # Check compressed size
                tgz_size = os.path.getsize(tgz_path)
                if tgz_size > MAX_FILE_SIZE:
                    shutil.rmtree(tmp_dir, ignore_errors=True)
                    return jsonify({"error": "Compressed archive ({}) exceeds 5 GB limit".format(
                        _fmt_size(tgz_size))}), 413

                return send_file(
                    tgz_path,
                    as_attachment=True,
                    attachment_filename=tgz_name,
                    mimetype="application/gzip",
                )
            else:
                # Single file – check size after download
                fsize = os.path.getsize(tmp_local)
                if fsize > MAX_FILE_SIZE:
                    shutil.rmtree(tmp_dir, ignore_errors=True)
                    return jsonify({"error": "File size ({}) exceeds 5 GB limit".format(
                        _fmt_size(fsize))}), 413

                return send_file(
                    tmp_local,
                    as_attachment=True,
                    attachment_filename=filename,
                )

    except Exception as exc:
        shutil.rmtree(tmp_dir, ignore_errors=True)
        return jsonify({"error": str(exc)}), 500


@app.route("/api/upload", methods=["POST"])
def api_upload():
    env               = request.form.get("env", "prod")
    ip                = request.form.get("ip", SELF_IP)
    username          = request.form.get("username", "") or ""
    path              = request.form.get("path", "") or ""
    path_save_enabled = request.form.get("path_save_enabled", "false").lower() == "true"

    if is_self(ip):
        ip = SELF_IP
    if not username or username == "self":
        username = os.environ.get("USER", "root")
    if not path:
        return jsonify({"error": "Destination path is required"}), 400

    files = request.files.getlist("files")
    if not files:
        return jsonify({"error": "No files provided"}), 400

    # Save env|ip|username|/home/username to conf only when path_save_enabled
    try:
        ensure_conf_entry(env, ip, username, path, path_save_enabled)
    except Exception:
        pass

    results  = []
    tmp_dir  = tempfile.mkdtemp()
    try:
        for f in files:
            fname    = os.path.basename(f.filename or "upload")
            tmp_path = os.path.join(tmp_dir, fname)
            f.save(tmp_path)

            # Check file size
            fsize = os.path.getsize(tmp_path)
            if fsize > MAX_FILE_SIZE:
                os.remove(tmp_path)
                results.append({
                    "file": fname,
                    "status": "error",
                    "error": "File size ({}) exceeds 5 GB limit".format(_fmt_size(fsize))
                })
                continue

            if is_self(ip):
                try:
                    os.makedirs(path)
                except OSError:
                    pass
                dest = os.path.join(path, fname)
                shutil.copy2(tmp_path, dest)
                results.append({"file": fname, "status": "ok"})
            else:
                # ensure remote dir exists
                ssh_run(ip, username, "mkdir -p {p}".format(p=path))
                scp = (
                    "scp -o StrictHostKeyChecking=no -o ConnectTimeout=15 "
                    "{src} {user}@{ip}:{dst}/"
                ).format(src=tmp_path, user=username, ip=ip, dst=path)
                _, err, rc = run_local(scp, timeout=300)
                if rc == 0:
                    results.append({"file": fname, "status": "ok"})
                else:
                    results.append({"file": fname, "status": "error", "error": err.strip()})

    except Exception as exc:
        return jsonify({"error": str(exc), "results": results}), 500
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    return jsonify({"results": results, "path": path, "ip": ip})


@app.route("/api/ips/<env>", methods=["GET"])
def api_ips(env):
    entries = read_conf(PROD_CONF)
    seen, ips = set(), []
    for e in entries:
        if e["ip"] not in seen:
            seen.add(e["ip"])
            ips.append(e["ip"])
    return jsonify({"ips": ips})


@app.route("/api/users", methods=["POST"])
def api_users():
    data    = request.json or {}
    ip      = data.get("ip", SELF_IP)
    entries = read_conf(PROD_CONF)
    users   = list({e["username"] for e in entries if e["ip"] == ip})
    return jsonify({"users": users})


@app.route("/api/paths", methods=["POST"])
def api_paths():
    """Return the single default path (/home/username) for a given ip+username in conf."""
    data     = request.json or {}
    ip       = data.get("ip", SELF_IP)
    username = data.get("username", "")
    entries  = read_conf(PROD_CONF)
    paths = list({e["path"] for e in entries
                  if e["ip"] == ip and e["username"] == username})
    return jsonify({"paths": paths})


@app.route("/api/history/delete", methods=["POST"])
def api_history_delete():
    """Delete specific entries from backend conf files (called when user clears history items)."""
    data  = request.json or {}
    items = data.get("items", [])
    deleted = 0
    for item in items:
        env      = item.get("env", "")
        ip       = item.get("ip", "")
        username = item.get("username", "")
        path     = item.get("path", "")
        if env == "prod" and ip and username and not is_self(ip):
            try:
                remove_conf_entry(env, ip, username, path)
                deleted += 1
            except Exception:
                pass
    return jsonify({"deleted": deleted})


@app.route("/api/homedir", methods=["POST"])
def api_homedir():
    data     = request.json or {}
    ip       = data.get("ip", SELF_IP)
    username = data.get("username", "") or ""
    if is_self(ip):
        ip = SELF_IP
    return jsonify({"home": get_home_dir(ip, username)})


# ── HELPERS ───────────────────────────────────────────────────────────────────

def _fmt_size(b):
    """Format bytes to human-readable string."""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if b < 1024:
            return "{:.1f} {}".format(b, unit)
        b /= 1024.0
    return "{:.1f} TB".format(b)


# ── MAIN ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Ensure base dir exists
    try:
        os.makedirs(BASE_PATH)
    except OSError:
        pass

    for conf_path, header in [(PROD_CONF, "# prod|IP|username|path")]:
        if not os.path.exists(conf_path):
            with open(conf_path, "w") as fh:
                fh.write(header + "\n")

    if not os.path.exists(HTML_FILE):
        print("ERROR: index.html not found at", HTML_FILE)
        sys.exit(1)

    print("=" * 55)
    print("  Remote File Console on http://{ip}:{port}".format(ip=SELF_IP, port=PORT))
    print("  Base path : " + BASE_PATH)
    print("  Prod conf : " + PROD_CONF)
    print("  Max size  : 5 GB per file/folder (compressed)")
    print("=" * 55)

    app.run(host="0.0.0.0", port=PORT, debug=False, threaded=True)
