
from flask import Flask, request, jsonify, send_from_directory, make_response
import csv, os, io, sys, subprocess, socket, shutil, secrets
from datetime import date, datetime, timedelta

# ─────────────────────────────────────────────────────────────
#  CONFIG
# ─────────────────────────────────────────────────────────────
HOST        = '0.0.0.0'
PORT        = 30303
CSV_FILE    = 'CLE_EXCEPTIONCODE_DETAILS.csv'
BACKUP_DIR  = '/tmp/CLE_EXCEPTIONCODE_DETAILS_BACKUP'
BACKUP_DAYS = 7
FIELDNAMES  = ['ERROR_CODE', 'COMPONENT', 'DESCRIPTION', 'END_SYSTEM', 'ACTION_REQUIRED', 'COMMENTS']

# ─────────────────────────────────────────────────────────────
#  STARTUP HELPERS
# ─────────────────────────────────────────────────────────────
def check_dependencies():
    try:
        import flask
    except ImportError:
        print("[INFO] Flask not found. Installing...")
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'flask', '--quiet'])
        print("[OK]  Flask installed.")

def kill_port(port):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            if s.connect_ex(('127.0.0.1', port)) == 0:
                print(f"[INFO] Port {port} in use. Attempting to free it...")
                os.system(f"fuser -k {port}/tcp 2>/dev/null || lsof -ti:{port} | xargs kill -9 2>/dev/null || true")
                import time; time.sleep(1)
    except Exception:
        pass

def print_banner():
    print("")
    print("╔══════════════════════════════════════════════════════╗")
    print("║        CLE EXCEPTIONCODE DETAILS DASHBOARD           ║")
    print("╚══════════════════════════════════════════════════════╝")
    print(f"  Dashboard URL : http://10.137.137.137:{PORT}")
    print(f"  CSV File      : {os.path.abspath(CSV_FILE)}")
    print(f"  Backup Folder : {BACKUP_DIR}")
    print(f"  Backup Retain : {BACKUP_DAYS} days")
    print( "  Uniqueness    : ERROR_CODE + COMPONENT")
    print( "  Press Ctrl+C  to stop")
    print("─────────────────────────────────────────────────────────")
    print("")

# ─────────────────────────────────────────────────────────────
#  BACKUP
# ─────────────────────────────────────────────────────────────
_last_backup_date = None

def take_daily_backup():
    global _last_backup_date
    today = date.today()
    if _last_backup_date == today:
        return
    if not os.path.exists(CSV_FILE):
        return
    os.makedirs(BACKUP_DIR, exist_ok=True)
    backup_name = f"CLE_EXCEPTIONCODE_DETAILS_{today.strftime('%Y%m%d')}.csv"
    backup_path = os.path.join(BACKUP_DIR, backup_name)
    try:
        shutil.copy2(CSV_FILE, backup_path)
        _last_backup_date = today
        print(f"[BACKUP] Saved → {backup_path}")
    except Exception as e:
        print(f"[BACKUP] Save failed: {e}"); return
    cutoff = datetime.now() - timedelta(days=BACKUP_DAYS)
    deleted = 0
    for fname in os.listdir(BACKUP_DIR):
        fpath = os.path.join(BACKUP_DIR, fname)
        if not os.path.isfile(fpath): continue
        if datetime.fromtimestamp(os.path.getmtime(fpath)) < cutoff:
            try:
                os.remove(fpath); deleted += 1
                print(f"[BACKUP] Deleted old backup → {fname}")
            except Exception as e:
                print(f"[BACKUP] Could not delete {fname}: {e}")
    if deleted:
        print(f"[BACKUP] Cleaned up {deleted} file(s) older than {BACKUP_DAYS} days")

# ─────────────────────────────────────────────────────────────
#  CSV HELPERS
# ─────────────────────────────────────────────────────────────
def safe_row(row):
    """Ensure all FIELDNAMES exist with string defaults (backward-compat with old CSVs)."""
    return {f: (row.get(f) or '').strip() for f in FIELDNAMES}

def row_key(r):
    """Composite uniqueness key."""
    return (r['ERROR_CODE'], r['COMPONENT'])

def init_csv():
    if not os.path.exists(CSV_FILE):
        with open(CSV_FILE, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
            writer.writeheader()
            sample = [
                {'ERROR_CODE':'CLE-001','COMPONENT':'GATEWAY',  'DESCRIPTION':'Connection timeout to downstream service','END_SYSTEM':'PAYMENT_GW','ACTION_REQUIRED':'Retry with exponential backoff','COMMENTS':''},
                {'ERROR_CODE':'CLE-001','COMPONENT':'CORE',     'DESCRIPTION':'Connection timeout — core layer variant', 'END_SYSTEM':'PAYMENT_GW','ACTION_REQUIRED':'Check core service health',    'COMMENTS':''},
                {'ERROR_CODE':'CLE-002','COMPONENT':'ROUTER',   'DESCRIPTION':'Invalid message format received',         'END_SYSTEM':'ORDER_SVC', 'ACTION_REQUIRED':'Validate payload schema',    'COMMENTS':''},
                {'ERROR_CODE':'CLE-003','COMPONENT':'AUTH',     'DESCRIPTION':'Authentication token expired',            'END_SYSTEM':'AUTH_SVC',  'ACTION_REQUIRED':'Refresh OAuth token',         'COMMENTS':''},
                {'ERROR_CODE':'CLE-004','COMPONENT':'DB',       'DESCRIPTION':'Database write conflict detected',        'END_SYSTEM':'DB_CLUSTER','ACTION_REQUIRED':'',                           'COMMENTS':''},
                {'ERROR_CODE':'CLE-005','COMPONENT':'MESSAGING','DESCRIPTION':'Queue consumer lag exceeded threshold',   'END_SYSTEM':'KAFKA_BUS', 'ACTION_REQUIRED':'Scale consumer group',       'COMMENTS':''},
            ]
            writer.writerows(sample)

def read_csv():
    rows = []
    if os.path.exists(CSV_FILE):
        with open(CSV_FILE, 'r', newline='') as f:
            reader = csv.DictReader(f)
            for row in reader:
                rows.append(safe_row(row))
    return rows

def write_csv(rows):
    with open(CSV_FILE, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(rows)

# ─────────────────────────────────────────────────────────────
#  FLASK APP
# ─────────────────────────────────────────────────────────────
app = Flask(__name__, static_folder='.')
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0

@app.after_request
def add_no_cache_headers(response):
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    response.headers['Pragma']        = 'no-cache'
    response.headers['Expires']       = '0'
    return response

@app.route('/')
def index():
    take_daily_backup()
    response = make_response(send_from_directory('.', 'index.html'))
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    response.headers['Pragma']        = 'no-cache'
    response.headers['Expires']       = '0'
    return response

@app.route('/api/data', methods=['GET'])
def get_data():
    return jsonify(read_csv())

# ── Normal user: edit ACTION_REQUIRED ────────────────────────
@app.route('/api/update', methods=['POST'])
def update_row():
    body       = request.json or {}
    error_code = body.get('ERROR_CODE',      '').strip()
    component  = body.get('COMPONENT',       '').strip()
    action     = body.get('ACTION_REQUIRED', '')
    rows = read_csv()
    for row in rows:
        if row['ERROR_CODE'] == error_code and row['COMPONENT'] == component:
            row['ACTION_REQUIRED'] = action
            write_csv(rows)
            return jsonify({'status': 'ok'})
    return jsonify({'status': 'error', 'message': 'Record not found'}), 404

# ── All users (edit-mode gated in frontend): update COMMENTS ─
@app.route('/api/update-comment', methods=['POST'])
def update_comment():
    body       = request.json or {}
    error_code = body.get('ERROR_CODE', '').strip()
    component  = body.get('COMPONENT',  '').strip()
    comment    = body.get('COMMENTS',   '')
    rows = read_csv()
    for row in rows:
        if row['ERROR_CODE'] == error_code and row['COMPONENT'] == component:
            row['COMMENTS'] = comment
            write_csv(rows)
            return jsonify({'status': 'ok'})
    return jsonify({'status': 'error', 'message': 'Record not found'}), 404

# ── Add single row ────────────────────────────────────────────
@app.route('/api/add', methods=['POST'])
def add_row():
    body = request.json or {}
    new_row = {f: body.get(f, '').strip() for f in FIELDNAMES}
    if not new_row['ERROR_CODE']:
        return jsonify({'status': 'error', 'message': 'ERROR_CODE is required'}), 400
    rows = read_csv()
    if any(row_key(r) == row_key(new_row) for r in rows):
        return jsonify({'status': 'error', 'message': 'ERROR_CODE + COMPONENT combination already exists'}), 409
    rows.append(new_row)
    write_csv(rows)
    return jsonify({'status': 'ok'})

# ─────────────────────────────────────────────────────────────
#  BULK IMPORT
# ─────────────────────────────────────────────────────────────
@app.route('/api/bulk-add', methods=['POST'])
def bulk_add():
    body     = request.json or {}
    incoming = body.get('rows', [])
    if not incoming:
        return jsonify({'status': 'error', 'message': 'No rows provided'}), 400
    rows          = read_csv()
    existing_keys = {row_key(r) for r in rows}
    added_count = 0
    skipped     = []
    invalid     = 0
    for item in incoming:
        code      = (item.get('ERROR_CODE')  or '').strip()
        component = (item.get('COMPONENT')   or '').strip()
        if not code:
            invalid += 1; continue
        key = (code, component)
        if key in existing_keys:
            skipped.append({'code': code, 'component': component})
        else:
            new_row = {
                'ERROR_CODE':      code,
                'COMPONENT':       component,
                'DESCRIPTION':     (item.get('DESCRIPTION')     or '').strip(),
                'END_SYSTEM':      (item.get('END_SYSTEM')      or '').strip(),
                'ACTION_REQUIRED': (item.get('ACTION_REQUIRED') or '').strip(),
                'COMMENTS':        (item.get('COMMENTS')        or '').strip(),
            }
            rows.append(new_row)
            existing_keys.add(key)
            added_count += 1
    if added_count:
        write_csv(rows)
    return jsonify({'status': 'ok', 'added': added_count, 'skipped': skipped, 'invalid': invalid})

@app.route('/api/sample-csv', methods=['GET'])
def sample_csv():
    sample_rows = [
        {'ERROR_CODE':'CLE-010','COMPONENT':'GATEWAY',  'DESCRIPTION':'Sample description — gateway layer', 'END_SYSTEM':'SAMPLE_SYS','ACTION_REQUIRED':'Sample action to resolve','COMMENTS':''},
        {'ERROR_CODE':'CLE-010','COMPONENT':'CORE',     'DESCRIPTION':'Same code, different component',     'END_SYSTEM':'CORE_SVC',  'ACTION_REQUIRED':'Check core layer',         'COMMENTS':''},
        {'ERROR_CODE':'CLE-011','COMPONENT':'MESSAGING','DESCRIPTION':'Another sample exception',           'END_SYSTEM':'ORDER_SVC', 'ACTION_REQUIRED':'',                         'COMMENTS':''},
    ]
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=FIELDNAMES)
    writer.writeheader()
    writer.writerows(sample_rows)
    response = make_response(output.getvalue())
    response.headers['Content-Type']        = 'text/csv; charset=utf-8'
    response.headers['Content-Disposition'] = 'attachment; filename=CLE_IMPORT_SAMPLE.csv'
    response.headers['Cache-Control']       = 'no-cache'
    return response

@app.route('/api/export', methods=['GET'])
def export_csv():
    rows = read_csv()
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=FIELDNAMES)
    writer.writeheader()
    writer.writerows(rows)
    response = make_response(output.getvalue())
    response.headers['Content-Type']        = 'text/csv; charset=utf-8'
    response.headers['Content-Disposition'] = 'attachment; filename=CLE_EXCEPTIONCODE_DETAILS.csv'
    response.headers['Cache-Control']       = 'no-cache'
    return response

# ─────────────────────────────────────────────────────────────
#  ADMIN AUTH
# ─────────────────────────────────────────────────────────────
ADMIN_USER     = 'topsdap'
ADMIN_PASSWORD = 'topsdap'
_admin_tokens  = set()

def is_admin():
    return request.cookies.get('admin_token', '') in _admin_tokens

@app.route('/api/admin/status', methods=['GET'])
def admin_status():
    return jsonify({'admin': is_admin()})

@app.route('/api/admin/login', methods=['POST'])
def admin_login():
    body = request.json or {}
    if body.get('username') == ADMIN_USER and body.get('password') == ADMIN_PASSWORD:
        token = secrets.token_hex(32)
        _admin_tokens.add(token)
        resp = make_response(jsonify({'status': 'ok'}))
        resp.set_cookie('admin_token', token, httponly=True, samesite='Strict')
        return resp
    return jsonify({'status': 'error', 'message': 'Invalid credentials'}), 401

@app.route('/api/admin/logout', methods=['POST'])
def admin_logout():
    token = request.cookies.get('admin_token', '')
    _admin_tokens.discard(token)
    resp = make_response(jsonify({'status': 'ok'}))
    resp.delete_cookie('admin_token')
    return resp

@app.route('/api/admin/update', methods=['POST'])
def admin_update_row():
    """
    Admin-only: update any field(s).
    Identify row by ERROR_CODE + COMPONENT.
    Use NEW_ERROR_CODE / NEW_COMPONENT to rename.
    """
    if not is_admin():
        return jsonify({'status': 'error', 'message': 'Unauthorized'}), 403
    body       = request.json or {}
    error_code = body.get('ERROR_CODE', '').strip()
    component  = body.get('COMPONENT',  '').strip()
    if not error_code:
        return jsonify({'status': 'error', 'message': 'ERROR_CODE is required'}), 400
    rows = read_csv()
    for row in rows:
        if row['ERROR_CODE'] == error_code and row['COMPONENT'] == component:
            new_code = body.get('NEW_ERROR_CODE', '').strip()
            new_comp = body.get('NEW_COMPONENT',  '').strip()
            # Handle rename
            if new_code and new_code != error_code:
                target = (new_code, new_comp if new_comp else component)
                if any(row_key(r) == target for r in rows if not (r['ERROR_CODE']==error_code and r['COMPONENT']==component)):
                    return jsonify({'status': 'error', 'message': 'ERROR_CODE + COMPONENT already exists'}), 409
                row['ERROR_CODE'] = new_code
            if new_comp and new_comp != component:
                target = (row['ERROR_CODE'], new_comp)
                if any(row_key(r) == target for r in rows if not (r['ERROR_CODE']==error_code and r['COMPONENT']==component)):
                    return jsonify({'status': 'error', 'message': 'ERROR_CODE + COMPONENT already exists'}), 409
                row['COMPONENT'] = new_comp
            for field in ['DESCRIPTION', 'END_SYSTEM', 'ACTION_REQUIRED', 'COMMENTS']:
                if field in body:
                    row[field] = body[field]
            write_csv(rows)
            return jsonify({'status': 'ok'})
    return jsonify({'status': 'error', 'message': 'Record not found'}), 404

@app.route('/api/admin/delete', methods=['POST'])
def delete_rows():
    """Body: { pairs: [{error_code, component}, ...] }"""
    if not is_admin():
        return jsonify({'status': 'error', 'message': 'Unauthorized'}), 403
    body  = request.json or {}
    pairs = body.get('pairs', [])
    if not pairs:
        return jsonify({'status': 'error', 'message': 'No pairs provided'}), 400
    del_keys = {(p.get('error_code',''), p.get('component','')) for p in pairs}
    rows     = read_csv()
    updated  = [r for r in rows if row_key(r) not in del_keys]
    write_csv(updated)
    return jsonify({'status': 'ok', 'deleted': len(rows) - len(updated)})

# ─────────────────────────────────────────────────────────────
#  ENTRY POINT
# ─────────────────────────────────────────────────────────────
if __name__ == '__main__':
    check_dependencies()
    kill_port(PORT)
    init_csv()
    print_banner()
    app.run(host=HOST, port=PORT, debug=False)
