# workhours-claude

> 一行命令，把本周 Git 提交记录导出为工时 Markdown 文件。

在 Claude Code 中输入 `/workhours 本周`，即可自动生成：

```markdown
## 2026-03-17 周一
### 上午
| 时间  | 项目     | 工作描述                     |
|-------|----------|------------------------------|
| 10:27 | geo_tool | feat: 调整适应症相关逻辑     |
| 11:15 | wpt      | fix: 修复编辑器 UI 问题      |
### 下午
| 时间  | 项目   | 工作描述                     |
|-------|--------|------------------------------|
| 14:23 | cmc-ai | feat: 调整图表默认展示数据   |
```

## 工作原理

安装后，每次 `git commit` 会自动触发全局 post-commit 钩子，将提交信息写入 `~/.workhours/git-commit-log.txt`。

`/workhours` 命令读取该日志文件，按日期和时间段整理后输出 Markdown。

## 安装

**前置要求：** [Claude Code](https://claude.ai/claude-code)、Git

```bash
curl -fsSL https://raw.githubusercontent.com/kingcwt/workhours-claude/main/install.sh | sh
```

安装脚本会自动完成：
1. 检测是否已有全局 git hooks 路径（`git config --global core.hooksPath`）
2. 没有则创建 `~/.workhours/hooks/` 并设置为全局 hooks 目录
3. 有则在现有目录中追加 post-commit 钩子（不覆盖已有内容）
4. 将 `workhours.md` 复制到 `~/.claude/commands/`

## 使用

```
/workhours                               # 导出本周工时（默认）
/workhours --time 今天                   # 导出今天
/workhours --time 上周                   # 导出上周
/workhours --time 2026-03-20             # 导出指定日期
/workhours --time 2026-03-18~2026-03-20  # 导出日期范围
/workhours --time 本月 --filter geo_tool  # 本月工时，排除某个项目
/workhours --filter wpt,cmc-ai           # 排除多个项目
/workhours --c                           # 纯文本模式，方便粘贴复制
/workhours --time 今天 --c               # 今天 + 纯文本模式
/workhours --help                        # 查看帮助
```

导出文件保存到 `~/Desktop/工时记录_<时间范围>.md`。

### 两种输出模式

**默认（表格模式）**
```markdown
### 上午
| 时间  | 项目     | 工作描述                 |
|-------|----------|--------------------------|
| 10:27 | geo_tool | feat: 调整适应症相关逻辑 |
```

**`--c` 纯文本模式**（粘贴到钉钉、飞书、微信等不乱格式）
```markdown
### 上午
`10:27` `geo_tool / main` feat: 调整适应症相关逻辑
`11:15` `wpt / main` fix: 修复编辑器 UI 问题
```

## 注意事项

- 安装后的首次提交才开始记录，历史提交不会被补录
- 自动过滤 `checkpoint-` 和 `[agent]` 开头的自动化提交

## License

MIT
