#!/bin/sh
# workhours-claude installer
# https://github.com/kingcwt/workhours-claude

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { printf "${GREEN}[workhours]${NC} %s\n" "$1"; }
info() { printf "${CYAN}[workhours]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[workhours]${NC} %s\n" "$1"; }
err()  { printf "${RED}[workhours]${NC} %s\n" "$1"; exit 1; }

# 本地测试时设置 LOCAL_REPO 变量：LOCAL_REPO=~/Desktop/workhours-claude sh install.sh
REPO_URL="https://raw.githubusercontent.com/kingcwt/workhours-claude/main"
HOOKS_DIR="$HOME/.workhours/hooks"
LOG_FILE="$HOME/.workhours/git-commit-log.txt"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"

echo ""
echo "  workhours-claude installer"
echo "  ──────────────────────────"
echo ""

# ── 1. 检测全局 hooks 路径 ──────────────────────────────────────────
CURRENT_HOOKS_PATH="$(git config --global core.hooksPath 2>/dev/null || echo '')"

if [ -n "$CURRENT_HOOKS_PATH" ]; then
  info "检测到已有全局 hooks 路径: $CURRENT_HOOKS_PATH"
  mkdir -p "$CURRENT_HOOKS_PATH"
  HOOKS_INSTALL_DIR="$CURRENT_HOOKS_PATH"
else
  info "未检测到全局 hooks 路径，将创建: $HOOKS_DIR"
  HOOKS_INSTALL_DIR="$HOOKS_DIR"
  mkdir -p "$HOOKS_INSTALL_DIR"
  git config --global core.hooksPath "$HOOKS_INSTALL_DIR"
  log "已设置 git config --global core.hooksPath = $HOOKS_INSTALL_DIR"
fi

# ── 2. 安装 post-commit hook ────────────────────────────────────────
POST_COMMIT="$HOOKS_INSTALL_DIR/post-commit"

if [ -f "$POST_COMMIT" ]; then
  # 已存在 post-commit，检查是否已包含 workhours
  if grep -q "workhours" "$POST_COMMIT" 2>/dev/null; then
    warn "post-commit hook 已包含 workhours，跳过安装"
  else
    # 追加到已有 hook 末尾
    warn "检测到已有 post-commit hook，将在末尾追加 workhours 逻辑"
    printf '\n# ── workhours hook ──\n' >> "$POST_COMMIT"
    if [ -n "$LOCAL_REPO" ]; then tail -n +4 "$LOCAL_REPO/hooks/post-commit" >> "$POST_COMMIT"
  else curl -fsSL "$REPO_URL/hooks/post-commit" | tail -n +4 >> "$POST_COMMIT"; fi
    log "已追加到现有 post-commit hook"
  fi
else
  # 全新安装
  if [ -n "$LOCAL_REPO" ]; then cp "$LOCAL_REPO/hooks/post-commit" "$POST_COMMIT"
  else curl -fsSL "$REPO_URL/hooks/post-commit" -o "$POST_COMMIT"; fi
  chmod +x "$POST_COMMIT"
  log "post-commit hook 安装完成: $POST_COMMIT"
fi

# ── 3. 创建日志目录 ─────────────────────────────────────────────────
mkdir -p "$(dirname "$LOG_FILE")"
log "日志目录: $(dirname "$LOG_FILE")"

# ── 4. 安装 Claude Code 命令 ────────────────────────────────────────
mkdir -p "$CLAUDE_COMMANDS_DIR"
if [ -n "$LOCAL_REPO" ]; then cp "$LOCAL_REPO/commands/workhours.md" "$CLAUDE_COMMANDS_DIR/workhours.md"
else curl -fsSL "$REPO_URL/commands/workhours.md" -o "$CLAUDE_COMMANDS_DIR/workhours.md"; fi
log "Claude Code 命令安装完成: $CLAUDE_COMMANDS_DIR/workhours.md"

# ── 完成 ────────────────────────────────────────────────────────────
echo ""
echo "  ✅ 安装完成！"
echo ""
echo "  下次 git commit 后，提交记录将自动写入："
echo "  $LOG_FILE"
echo ""
echo "  在 Claude Code 中使用："
echo "  /workhours            导出本周工时"
echo "  /workhours --time 今天   导出今天"
echo "  /workhours --help     查看全部用法"
echo ""
