#!/usr/bin/env bash
# ============================================================
# DSH Web GUI 启动脚本
# 用法: ./dsh-web.sh [dsh web 参数...]
# 停止服务: 在终端中按 Ctrl+C
# ============================================================

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly WEB_URL="${DSH_WEB_URL:-http://127.0.0.1:3080}"

cd -- "$SCRIPT_DIR"

# 检查 dsh 命令是否可用
if ! command -v dsh >/dev/null 2>&1; then
    printf '%s\n' \
        '[错误] 未找到 dsh 命令。' \
        '请先全局安装 DSH: npm install -g @deepseek-ai/dsh' >&2
    exit 127
fi

# 兼容 Linux、macOS、Windows Git Bash 和 WSL。
open_url() {
    local url="$1"

    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url" >/dev/null 2>&1
    elif command -v open >/dev/null 2>&1; then
        open "$url" >/dev/null 2>&1
    elif command -v explorer.exe >/dev/null 2>&1; then
        explorer.exe "$url" >/dev/null 2>&1
    elif command -v cmd.exe >/dev/null 2>&1; then
        cmd.exe /c start "" "$url" >/dev/null 2>&1
    else
        printf '未找到可用的浏览器打开命令，请手动访问 %s\n' "$url" >&2
        return 0
    fi
}

printf '正在启动 DSH Web GUI ...\n访问地址: %s\n按 Ctrl+C 可停止服务\n\n' "$WEB_URL"

# 延迟打开浏览器；如果服务提前退出，EXIT trap 会取消该任务。
( sleep 3; open_url "$WEB_URL" ) &
browser_job_pid=$!
trap 'kill "$browser_job_pid" 2>/dev/null || true' EXIT

if dsh web "$@"; then
    exit_code=0
else
    exit_code=$?
fi

printf '\nDSH Web 已退出 (exit code: %d)\n' "$exit_code"
exit "$exit_code"

