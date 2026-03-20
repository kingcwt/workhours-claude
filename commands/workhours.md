# 导出工时记录

根据 Git 全局钩子日志，生成格式化的工时 Markdown 文件。

## 数据来源

所有 Git 提交通过全局 post-commit 钩子自动记录，日志文件位于：
```
~/.workhours/git-commit-log.txt
```

如果该文件不存在，说明尚未安装钩子，请先运行安装脚本：
```bash
curl -fsSL https://raw.githubusercontent.com/kingcwt/workhours-claude/main/install.sh | sh
```

## 参数说明

`$ARGUMENTS` 支持以下参数（可组合使用）：

### --time <时间>
- 留空 → 默认本周（本周一 00:00 至今）
- `--time 今天` / `--time today`
- `--time 本周` / `--time week`
- `--time 上周` / `--time last week`
- `--time 本月` / `--time month`
- `--time 2026-03-20` → 指定某天
- `--time 2026-03-18~2026-03-20` → 指定日期范围

### --filter <项目>
排除指定项目（多个用英文逗号分隔）：
- `--filter geo_tool`
- `--filter geo_tool,wpt`

### --help
显示帮助信息。

```
用法：/workhours [--time <时间>] [--filter <项目>] [--help]

示例：
  /workhours
  /workhours --time 今天
  /workhours --time 上周
  /workhours --time 2026-03-20
  /workhours --time 2026-03-18~2026-03-20
  /workhours --time 本月 --filter geo_tool
  /workhours --filter wpt,cmc-ai
```

---

## 执行步骤

**第零步：解析参数**

从 `$ARGUMENTS` 中解析：
- 包含 `--help` → 输出帮助信息，结束
- 提取 `--time` 的值（默认「本周」）
- 提取 `--filter` 的值，逗号分割成列表

**第一步：检查日志文件**

运行以下命令确认日志文件存在：
```bash
ls -lh ~/.workhours/git-commit-log.txt
```

如果文件不存在，停止执行并提示用户先运行安装脚本（见上方数据来源）。

**第二步：确定时间范围**

根据 `--time` 的值确定 since/until（本地时区）：
- 无参数 / `本周` / `week` → 本周一 00:00 ～ 今天 23:59
- `今天` / `today` → 今天 00:00 ～ 23:59
- `上周` / `last week` → 上周一 00:00 ～ 上周日 23:59
- `本月` / `month` → 本月 1 日 00:00 ～ 今天 23:59
- `2026-03-20` → 当天 00:00 ～ 23:59
- `2026-03-18~2026-03-20` → 2026-03-18 00:00 ～ 2026-03-20 23:59

**第三步：读取并解析日志**

日志文件路径：`~/.workhours/git-commit-log.txt`

先用 grep 定位目标时间范围内的记录行号，再分段读取（避免直接读取整个大文件）：
```bash
grep -n "commit_time=<目标日期>" ~/.workhours/git-commit-log.txt
```

日志格式（每条记录以 `-----` 分隔）：
```
-----
captured_at=2026-03-19T03:31:45Z
commit_time=2026-03-19T11:31:45+08:00
project=wpt
repo=/Users/.../wpt
branch=main
hash=abc123
author=kingcwt <kingcwt@qq.com>
message<<EOF
feat: 调整编辑器UI
EOF
changed_files<<EOF
src/App.tsx
EOF
stats= 2 files changed, 10 insertions(+)
```

**第四步：过滤记录**

保留满足以下条件的提交：
1. `commit_time` 在目标时间范围内
2. `message` 不以 `checkpoint-` 开头（自动提交）
3. `message` 不以 `[agent]` 开头（AI agent 自动提交）
4. `project` 不在 `--filter` 排除列表中

**第五步：按模板生成 Markdown**

按日期分组，每天分上午（12:00 前）/ 下午（12:00 起），时间升序。

**第六步：保存文件**

保存到 `~/Desktop/工时记录_<时间范围>.md`，告知文件路径。

---

## 输出模板

```markdown
# 工时记录

**统计周期**：2026-03-17（周一）～ 2026-03-20（周四）
**导出时间**：2026-03-20 15:30
**项目过滤**：geo_tool、wpt（仅在使用 --filter 时显示此行）

---

## 2026-03-17 周一

### 上午

| 时间 | 项目 | 工作描述 |
|------|------|----------|
| 10:27 | geo_tool | feat: 调整适应症相关逻辑 |
| 11:15 | geo_tool | fix: 调整维度1图表匹配规则 |

### 下午

| 时间 | 项目 | 工作描述 |
|------|------|----------|
| 13:46 | cmc-ai | feat: 调整sov筛选页面 |
| 18:26 | geo_tool | feat: 新增适应症支持编辑和删除 |

---

**合计提交**：XX 条（已过滤 checkpoint 自动提交 X 条）
**涉及项目**：geo_tool、cmc-ai、wpt
```

## 注意事项

- 过滤掉 `checkpoint-` 开头的自动提交
- 过滤掉 `[agent]` 开头的 AI agent 提交
- 某天只有上午或只有下午时，只显示有内容的时间段
- 没有提交记录的天不输出
- 日志文件较大时，必须用 grep 定位行号后再分段读取
