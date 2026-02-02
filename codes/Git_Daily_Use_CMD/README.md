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


## Branch Upstream Setup (One-Time, Then Daily Benefit)
```bash
git push -u origin main
```

After that:
```bash
git push
git pull
```

> Why:Removes noise from daily commands.

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

## Git Ignore Cache Fix
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


## 11. Branching (Core Power of Git)
- Branch = pointer to a commit
- Default branch: master or main
- Branch creation copies current state
```bash
git branch              # list
git branch feature1     # create
git checkout feature1   # switch
```

Delete:
```bash
git branch -d feature1
git branch -D feature1  # force
```

Rename:
```bash
git branch -m main
git branch -M main      # force rename
```

## Remote Branch Cleanup
```bash
git branch -r
git push origin --delete feature1
```

> Why:Housekeeping after PR merge.

## 12. Merge Strategy
```bash
git checkout master
git merge feature1
```

Rules:
- Same file, different lines → auto-merge
- Same file, same lines → conflict


## Merge Conflict Resolution
When conflict occurs:
```bash
CONFLICT (content): Merge conflict in file
```

Steps:
1. Open conflicted file
2. Resolve manually
3. Remove conflict markers
4. Add & commit
```bash
git add .
git commit -m "resolve merge conflict"
```

## 13. Stash (Temporary Parking)

Use when:
- Work is incomplete
- You must switch context urgently
```bash
git stash
git stash list
git stash apply stash@{0}
git stash clear
```

Notes:
- Only uncommitted changes
- Multiple stashes supported

## 14. Reset vs Revert (Never Confuse)
Reset (Local, Private)
```bash
git reset <file>
git reset .
git reset --hard
```

- Rewrites history
- Dangerous after push

Revert (Public, Safe)
```bash
git revert <commit-id>
```
- Creates a new commit
- History moves forward
- State moves backward

## 15. Clean (Untracked Files)
```bash
git clean -n   # dry run
git clean -f   # force delete
```

> Only removes untracked files.

## 16. Fix Last Commit
```bash
vi file
git add .
git commit --amend
```
> Why:Used when you want to modify the most recent commit before pushing.
> --amend replaces the last commit.

## 17. Tags (Release Markers)
```bash
git tag
git tag -a v1.0 -m "first release" <commit-id>
git show v1.0
git tag -d v1.0
```

Use tags for:
- Releases
- Stable milestones
- Rollback references

## 18. git diff (Before You Commit)
You inspect history, but not changes before committing.
```bash
Missing:
git diff              # working vs staging
git diff --staged     # staging vs last commit
git diff HEAD~1 HEAD
```

Why it matters:
>This is the last line of defense before bad commits.

## 19. Clone (New Machine / New User)
```bash
git clone <repo-url>
```

Creates:
- Directory
- .git
- Full history
- Remote already configured

## 20. Strategic Notes (Important)
- Commit small, commit often
- Write commit messages like change-logs
- Never reset after push
- Revert is audit-safe
- Branch early, merge often
- .gitignore must be decided early
- Tags = trust points
- Git history is documentation

## One-Line Philosophy

> Git is not a backup tool.
> Git is decision tracking over time.
