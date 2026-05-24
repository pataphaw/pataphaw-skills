---
name: coding-agent-digest
description: Collect, filter, and write a concise Chinese daily digest for coding agent news. Use when the user asks for yesterday/today/daily coding agent资讯, Codex/Claude Code/Cursor/Gemini/Antigravity updates, agentic coding news, or a <=10 item digest from official docs, changelogs, releases, core people, starred blogs, Medium, or high-quality communities.
---

# Coding Agent 日报

## 核心原则

生成 coding agent 资讯日报时，优先让用户快速判断“今天有什么值得看”。不要硬凑数量；没有高质量内容时，少发是正确结果。

默认输出中文，保留英文标题、产品名和原文链接。每条摘要约 100 字，说明发生了什么、涉及哪些能力变化、为什么和 coding agent 相关。

## 时间窗口

- 默认收集用户所在地时区的“昨天”。若没有额外说明，使用 `Asia/Shanghai`。
- 按本地日期判断，同时兼容 UTC 发布时间跨日：北京时间昨天 00:00-23:59 内发生或发布的内容都可纳入。
- 不主动回溯更早日期。只有用户明确要求“补充最近几天”“本周”“没有内容也找一些”时才扩大窗口。
- 不为凑满 10 条扩大时间范围。

## 来源优先级

优先一手和高信噪比来源：

1. 官方文档、changelog、release notes、GitHub releases。
2. 官方博客、工程博客、开发者博客。
3. 已确认核心人员的博客、GitHub、X/Twitter、Threads；社交源必须能公开抓取或被可靠索引验证。
4. 明星博客和高质量 newsletters，例如 Simon Willison、Latent Space。
5. Medium 和开放社区只作低权重发现源；仅当标题/摘要强相关且信息密度足够时保留。

常用来源池包括但不限于：

- OpenAI Codex: `https://developers.openai.com/codex/`, Codex changelog RSS, `openai/codex` GitHub releases, OpenAI News。
- Claude Code: `https://code.claude.com/docs/en/overview`, Claude Code changelog, Anthropic Engineering, Anthropic News。
- Cursor: Cursor changelog RSS, Cursor blog product/research, Cursor docs sitemap。
- Gemini / Antigravity / Code Assist: Gemini CLI releases/changelog, Antigravity CLI repo/docs, Gemini Code Assist release notes, Google Developers Blog。
- Blogs: Simon Willison coding-agent tags, Latent Space feed, selected Medium coding-agent tags。

## 快速筛选规则

保留内容需要同时满足：

- 来源可靠或来自高质量社区。
- 标题、摘要或正文明确关联 coding agent / agentic coding / developer agents。
- 对重度用户、产品设计、使用实践、能力变化、生态趋势、权限/安全/成本/工作流至少有一项价值。

直接丢弃：

- 纯 internal infrastructure、无用户可见变化的小版本。
- 依赖升级、CI、文档错字、纯 UI polish。
- 泛模型发布、融资、公关、招聘、活动宣传，除非明确影响 coding agent 工作流。
- Medium SEO 榜单、泛泛工具推荐、无一手信息的竞品对比。
- GitHub commits/issues 的日常噪声，除非涉及 release、security、breaking、auth、sandbox、MCP、agent runtime、IDE/CLI 集成。

不要强制按 Codex / Claude Code / Cursor / Gemini 每类覆盖。用户关注的是 coding agent 方向，而不是分类完整性。

## 推荐工作流

1. 明确日期窗口：默认昨天，输出中写清楚日期。
2. 快速抓取官方和高质量来源的当天条目。
3. 粗筛标题/摘要；只对候选条目做必要正文确认。
4. 去重：同一事件多源报道时优先官方源；博客解读只在有额外观点时保留。
5. 产出最多 10 条，通常 2-6 条即可。
6. 若当天没有足够内容，说明“今天高质量候选较少”，不要回溯硬凑。

当需要评估具体来源、批量抓取多个来源、或用户担心上下文过大时，使用 subagents 分别抓取候选；主线程只做汇总、去重和最终裁剪。

## 输出格式

使用以下结构：

```text
YYYY-MM-DD Coding Agent 日报

必看

1. 标题
来源：...
时间：...
链接：...

摘要：
约 100 字，说明发生了什么、涉及哪些能力或变化、为什么和 coding agent 相关。

价值：
一句话说明对重度用户或 qoder 产品设计的启发。

可选
...

不保留
- 可简短列出被排除的重要候选及原因；不要列太多。
```

如果候选少于 3 条，仍按真实数量输出。不要为了形式制造“可选”区。

## 摘要风格

- 摘要要比一句话更完整，目标约 80-120 个中文字。
- 价值句要具体，避免空话，例如“qoder 可关注成本归因、权限边界、session 恢复”优于“值得学习”。
- 对官方 release，突出用户可感知变化。
- 对趋势文章，突出它解释了什么行业变化。
- 对 Medium/社区文章，标注来源权重较低，只在产品观察价值明确时推荐。
