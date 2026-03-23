# workhours-claude

> 一行命令，把 Git 提交记录导出为工时 Markdown 文件。

在 Claude Code 中输入 `/workhours`，即可自动生成本周工时报告：

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
/workhours                                        # 导出本周工时（默认）
/workhours --time 今天                            # 导出今天
/workhours --time 上周                            # 导出上周
/workhours --time 本月                            # 导出本月
/workhours --time 2026-03-20                      # 导出指定日期
/workhours --time 2026-03-18~2026-03-20           # 导出日期范围
/workhours --filter geo_tool                      # 排除指定项目
/workhours --filter wpt,cmc-ai                    # 排除多个项目
/workhours --time 本月 --filter geo_tool          # 本月工时，排除某个项目
/workhours --c                                    # 纯文本模式，方便粘贴复制
/workhours --time 今天 --c                        # 今天 + 纯文本模式
/workhours --cp                                   # 按项目分组 + 工时统计
/workhours --time 今天 --cp                       # 今天按项目工时
/workhours --add 其他 "开会一小时 -t 1h" --am    # 添加今天上午记录
/workhours --add 其他 "需求评审 -t 2h" --pm      # 添加今天下午记录
/workhours --add 其他 "临时任务"                  # 按当前时间自动判断上下午
/workhours --help                                 # 查看帮助
```

导出文件保存到 `~/Desktop/工时记录_<时间范围>.md`。

## 输出模式

### 默认（表格模式）

```markdown
### 上午
| 时间  | 项目     | 工作描述                 |
|-------|----------|--------------------------|
| 10:27 | geo_tool | feat: 调整适应症相关逻辑 |
| 11:15 | wpt      | fix: 修复编辑器 UI 问题  |
```

### `--c` 纯文本模式

粘贴到钉钉、飞书、微信等不会乱格式。

```markdown
### 上午
`10:27` `geo_tool / main` feat: 调整适应症相关逻辑
`11:15` `wpt / main` fix: 修复编辑器 UI 问题
```

### `--cp` 按项目分组工时模式

自动统计每个项目的工时。提交信息末尾带 `-t 2h` 或 `-t 30m` 指定任务时长，无标记则按上午/下午时间段（各 4h）自动平均分配。

```markdown
## geo_tool `共 6.5h`

- 调整适应症相关逻辑 `1h`
- 调整维度1图表匹配规则 `1h`
- 新增适应症支持编辑和删除 `2h`
- 新增竞品其他两个名字 `1.5h`
- 调整受众视角提示词 `1h`

## cmc-ai `共 3h`

- 调整sov筛选页面 `1h`
- 调整分析方向相关UI `1h`
- 新增分析方向提示词 `1h`

---

**总计工时**：9.5h
**涉及项目**：geo_tool、cmc-ai
```

**工时计算规则：**
- 提交信息末尾带 `-t 2h` → 该任务花费 2 小时（展示时去掉 `-t` 标记）
- 提交信息末尾带 `-t 30m` → 该任务花费 30 分钟
- 无 `-t` 标记 → 自动平均分配（上午固定 4h，下午固定 4h，减去显式 `-t` 后平均）
- 当天未结束的时段（上午未过 12:00 / 下午未过 18:00）→ 无 `-t` 的记录显示为「待分配」

### `--add` 手动添加记录

用于不涉及 Git 提交的工作（开会、需求评审等）。

```bash
/workhours --add 其他 "开会讨论需求 -t 1h" --am   # 添加到今天上午
/workhours --add 其他 "技术方案评审 -t 2h" --pm   # 添加到今天下午
/workhours --add 其他 "临时沟通"                   # 按当前时间自动判断
```

- `--am` → 写入今天上午（时间戳 09:00）
- `--pm` → 写入今天下午（时间戳 14:00）
- 不传 → 当前时间 < 12:00 视为上午，≥ 12:00 视为下午

## 注意事项

- 安装后的首次提交才开始记录，历史提交不会被补录
- 自动过滤 `checkpoint-` 和 `[agent]` 开头的自动化提交
- 使用 `--filter` 排除项目后，工时会基于剩余项目重新计算

## License

MIT
