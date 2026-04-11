---
name: git-publish
description: 将当前 git 工作区的改动整理为一组干净、可审阅的提交，必要时切换到合适分支，默认推送到 origin，并默认向 `main` 创建 PR。Use when the user asks to analyze current changes, split commits, write commit messages, push a branch, or publish local work as a GitHub pull request.
---

# Git Publish

## 概览
把当前工作区里的改动，整理成一条清晰、克制、适合 review 的发布路径。

这个 skill 关注的不是“赶紧 push 上去”，而是先判断范围，再拆分提交、整理历史、推送远端，最后开出一个能被顺畅阅读的 PR。

## 工作流
### 1. 先看清当前改动
- 先运行 `git status -sb`，确认当前分支、已修改文件、未跟踪文件。
- 结合 `git diff`、`git diff --cached` 判断这批改动是否属于同一个意图。
- 如果工作区里混有无关改动，而且用户没有明确范围，先停下来确认哪些文件属于这次发布。

### 2. 判断要不要切分支
- 如果当前在 `main`、`master` 或其他默认分支上，先切到一个独立工作分支再提交。
- 分支名要简短、能表达主题。
- 优先使用带层级的名字，例如 `codex/<topic>`；如果仓库环境对 slash-style branch name 不稳定，就退回平面名字，例如 `<topic>`。
- 如果用户已经在一个合适的特性分支上，通常继续在当前分支完成即可。

### 3. 按意图拆分提交
- 一次提交只表达一个清晰意图，不按“改了几个文件”来分，而按“做成了什么事”来分。
- 显式使用 `git add <paths>` 暂存每一组改动，不要默认 `git add -A`。
- 每次提交前都检查 `git diff --cached --stat` 或 `git diff --cached`，确认暂存区内容和这笔提交的意图一致。
- 如果同时存在 rename / move 和实质性内容修改，优先分开提交，让历史更易读。

### 4. 写精心的 commit message
- commit message 保持简洁，但要有判断力。
- 优先用祈使语气，直接描述这笔提交做了什么。
- 避免把多个主题揉进同一条 commit message。
- 不要改写或 amend 用户已有提交，除非用户明确要求。

### 5. 做轻量但有价值的验证
- 优先跑和这批改动最相关、成本最低的检查。
- 如果是文档或元数据改动，至少在最后一笔提交前运行 `git diff --cached --check`。
- 如果仓库里存在显而易见、成本可接受的测试，也应在 push 前跑掉并记录结果。

### 6. 默认推送远端
- 只要用户没有明确说“不推送”，默认在提交整理完成后推送到 `origin`。
- 优先使用 `git push -u origin $(git branch --show-current)` 建立跟踪关系。
- 如果 push 因为权限、网络或沙箱限制失败，明确报告阻塞点，并在需要时请求授权。

### 7. 默认创建 PR
- 只要用户没有明确说“不建 PR”，默认在推送成功后创建 PR。
- 如果用户没有指定目标分支，默认把 PR 指向 `main`。
- 默认创建普通 PR，不默认用 draft；只有用户明确表达 WIP / draft 意图，或改动明显还没准备好 review 时，才使用 draft。
- 优先使用 GitHub app 创建 PR；必要时再退回 `gh pr create`。
- PR 标题要概括整组变更；PR body 至少说明改了什么、为什么改、影响范围、以及做了哪些验证。

## 安全边界
- 不要静默地把无关改动一起 stage。
- 不要在范围不清晰时直接 `git add -A`。
- 如果用户明确说不要 push，就停在本地提交阶段。
- 如果用户没有要求，不要替用户合并 PR。
- 如果遇到脏工作区、冲突中的 rebase、异常 detached HEAD 等状态，先解释当前局面，再决定是否继续。

## 输出要求
完成后明确汇报这些信息：
- 最终使用的分支名。
- 每一笔新提交的 SHA 和 commit message。
- 是否已经推送远端。
- PR 链接、编号和目标分支。
- 跑了哪些验证，哪些没有跑，以及原因。
