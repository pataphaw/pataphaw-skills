---
name: refresh
description: 刷新当前工作区对应的 git 仓库。Use when the user asks to refresh, sync, update, or pull the current workspace, or wants to switch back to `main` / `master` before syncing. First inspect whether the repo has uncommitted changes, untracked files, unfinished git operations, missing upstream, or unpushed commits; if any of these exist, stop and ask the user how to proceed. Only when the repo is clean, switch to `main` or `master` and pull the latest code from remote.
---

# Refresh

按“先检查，再同步”的顺序执行。不要跳过检查。

## 工作流

### 1. 先检查当前仓库
- 先运行 `git status -sb`。
- 必要时补充运行：
  - `git rev-parse --abbrev-ref HEAD`
  - `git rev-parse --abbrev-ref --symbolic-full-name @{u}`（允许失败）
- 把下面情况都视为“先停下来问用户”：
  - 有已修改、已暂存、未跟踪文件。
  - 有 merge、rebase、cherry-pick 等未完成状态。
  - 当前分支领先 upstream，存在未推送提交。
  - 当前分支没有 upstream，无法确认是否已全部推送。

### 2. 有本地风险时先询问
- 不要自动 `stash`、`commit`、`push`、`reset`、`checkout -f`。
- 简洁展示现状，并直接问用户想怎么处理。
- 在用户明确前，不进入切分支和拉取步骤。

### 3. 仓库干净时切默认分支
- 优先使用 `main`；本地没有 `main` 时退回 `master`。
- 如果本地分支不存在，但 `origin/main` 或 `origin/master` 存在，创建跟踪分支再切换。
- 两者都不存在时，明确报告缺少默认分支并停止。
- 优先使用 `git switch`，避免旧式 `checkout`。

### 4. 拉取最新代码
- 切到目标分支后，运行 `git pull --ff-only`。
- 如果拉取失败，直接报告阻塞原因，不要自动做 rebase、merge 或强制覆盖。

## 输出
- 如果中途停止：说明停在哪一步、发现了什么、正在等用户决定什么。
- 如果刷新成功：说明最终分支，以及是否已成功拉取最新代码。
