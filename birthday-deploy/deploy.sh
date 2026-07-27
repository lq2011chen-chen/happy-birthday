#!/bin/bash
# ===== 部署生日页面到 GitHub Pages =====
# 用法: bash deploy.sh

set -e

REPO_NAME="birthday-lq"
GH_USER="lq2011chen-glitch"
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================="
echo "  🎂 部署到 GitHub Pages"
echo "=============================="
echo ""

# 检查 git
if ! command -v git &>/dev/null; then
    echo "❌ 请先安装 git: https://git-scm.com/"
    exit 1
fi

# 检查 GitHub CLI
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
    echo "✅ 检测到 GitHub CLI，自动部署..."
    cd "$DIR"
    git init
    git checkout -b main 2>/dev/null || true
    git add -A
    git commit -m "🎂 Happy Birthday"
    gh repo create "$REPO_NAME" --public --description "Happy Birthday"       --push --source . 2>/dev/null ||     git push -u origin main 2>/dev/null ||     git push -u origin master
    sleep 2
    # 开 Pages
    gh api repos/$GH_USER/$REPO_NAME/pages -X POST \
      --field source.branch=main --field source.path=/ 2>/dev/null && \
    echo "✅ Pages 已开启" || echo "⚠️ 手动开启 Pages（见下文）"
    echo ""
    echo "https://$GH_USER.github.io/$REPO_NAME/"
    exit 0
fi

# 没有 gh，走 SSH 方式
echo "正在检查 SSH 密钥..."
if [ ! -f ~/.ssh/id_ed25519.pub ] && [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "❌ 没有找到 SSH 公钥"
    echo ""
    echo "建议直接用浏览器部署（最简单，无需命令行操作）："
    echo "──────────────────────────────"
    echo "1. 打开 https://github.com/new"
    echo "2. 仓库名填: $REPO_NAME"
    echo "3. 选 Public，点 Create repository"
    echo "4. 在新页面点 uploading an existing file"
    echo "5. 从 Finder 打开桌面文件夹:"
    echo "   cd $DIR && open ."
    echo "6. 把文件夹里所有文件拖到浏览器上传"
    echo "7. 点 Commit changes"
    echo "8. 去 Settings > Pages，Source 选 main，/(root)，Save"
    echo "9. 等 2 分钟，访问:"
    echo "   https://$GH_USER.github.io/$REPO_NAME/"
    echo "──────────────────────────────"
    exit 1
fi

# 有 SSH 密钥，直接走 SSH
echo "✅ 检测到 SSH 密钥"
echo "请确认已把公钥添加到 GitHub:"
echo "  1. 打开 https://github.com/settings/keys"
echo "  2. 点 New SSH key"
echo "  3. 粘贴下面这行:"
cat ~/.ssh/id_*.pub 2>/dev/null | head -1
echo ""
read -p "已添加？(y/n): " added
if [ "$added" != "y" ]; then
    echo "添加后再运行脚本"
    exit 1
fi

cd "$DIR"
git init
git checkout -b main 2>/dev/null || true
git add -A
git commit -m "🎂 Happy Birthday"
git remote add origin "git@github.com:$GH_USER/$REPO_NAME.git"
if git push -u origin main 2>&1; then
    echo ""
    echo "✅ 推送成功！"
    echo "手动开启 GitHub Pages："
    echo "  1. https://github.com/$GH_USER/$REPO_NAME/settings/pages"
    echo "  2. Source 选 main，/(root)，Save"
    echo "  3. 等 2 分钟后访问："
    echo "     https://$GH_USER.github.io/$REPO_NAME/"
else
    echo ""
    echo "❌ 推送失败。可能是仓库不存在。"
    echo "先手动创建仓库："
    echo "  1. https://github.com/new"
    echo "  2. 仓库名: $REPO_NAME"
    echo "  3. 选 Public，不要勾选任何初始化选项"
    echo "  4. 点 Create repository"
    echo "  5. 重新运行脚本"
fi
