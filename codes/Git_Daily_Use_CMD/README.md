# Git — Practical Notes for Daily Use 

This README is written **as a Git user**, not as a tutorial output.  
Use it as a **mental model + command reference**.

---

## 1. Git Basics (Mental Model)

Git is a **distributed version control system**.
Every developer has:
- Full project source
- Full commit history
- Ability to work **offline**

Repository types:
- **Local repository** → on your machine
- **Remote repository** → GitHub / GitLab (central reference)

---

## 2. Git’s 3 Logical States
1. Working Directory
~ Where you edit files

2. Staging Area (Index)
~ Prepared snapshot

3. Local Repository
~ Permanent history (commits)

Movement:
```bash
Working → Staging → Repository
 edit       git add      git commit
```

## 3. Commit (Snapshot, Not Full Copy)

- Commit = snapshot of changes only
- Uses SHA-1 (40 hex characters)
- Immutable reference:
```bash
git commit -m "meaningful message"
```

Key facts:
- Every commit has a unique ID
- Commits form a directed history
- Tags point to commits


## 4. Repository Lifecycle

### Install & Verify
```bash
sudo apt install git -y
which git
git --version
```

## 5. Identity (Mandatory)
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --list
```
>  Name & email become permanent metadata in commit history.

## 6. Repository Initialization
```bash
mkdir project
cd project
git init
```

Creates:
>  .git/ (hidden) → entire Git brain



## 7. Remote Repository (GitHub)
Add Remote
```bash
git remote add origin <repo-url>
git remote -v
```

Push / Pull
```bash
git push origin master
git pull origin master
```

> push = local → remote
> pull = remote → local (fetch + merge)


## 8. Authentication (GitHub Token)

Path:
- GitHub → Settings → Developer Settings
- → Personal Access Tokens (Classic)
- → Generate → Copy immediately

> Use token instead of password.

## 9. Status & Inspection
```bash
git status
git log
git log --oneline
git log -n 5
git log --grep "keyword"
git show <commit-id>
```

## 10. .gitignore (Critical)

Create:
```bash
vi .gitignore
```

Examples:
```bash
*.log
*.class
.env
```

Add & commit:
```bash
git add .gitignore
git commit -m "add gitignore"
```

## 11. Git Ignore Cache Fix
If want don't want to ignore *.class then 
- edit .gitignore:
```bash
vi .gitignore
```

Examples:
```bash
*.log
.env
```

clear index still tracked:
```bash
git rm -r --cached .
git add .
git commit -m "fix gitignore tracking"
```
> This is the only correct flow when changing what is ignored.

If You want to stop ignoring ONE file but keep others ignored

- edit .gitignore:
```bash
vi .gitignore
```

Examples:
```bash
*.log
!app.log
.env
```

```bash
git add app.log
git commit -m "track app.log while ignoring others"
```
> All .log ignored but app.log tracked



- Completely remove .gitignore Completely
```bash
rm .gitignore
git rm .gitignore
git commit -m "remove gitignore"
```
>⚠️ Ignored files will not automatically come back unless you add them manually.


## Golden Rules (Remember This)
- .gitignore does not affect already tracked files
- Changing ignore rules → clear cache once
- Use !filename to re-include a file
- Never commit secrets (.env, keys)
