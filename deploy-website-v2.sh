#!/bin/bash

# 芙蓉出海服务总部港 - 网站v2部署脚本

set -e

echo "=========================================="
echo "芙蓉出海服务总部港 - 网站v2部署开始"
echo "=========================================="

# 配置变量
WEBSITE_DIR="/var/www/html"
BACKUP_DIR="/var/backups/flocaetp-website"
SOURCE_DIR="./flocaetp-website-v2"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ 错误: 源目录 $SOURCE_DIR 不存在"
    exit 1
fi

echo "📁 源目录: $SOURCE_DIR"
echo "🎯 目标目录: $WEBSITE_DIR"
echo "💾 备份目录: $BACKUP_DIR"

# 创建备份目录
echo "📦 创建备份目录..."
sudo mkdir -p "$BACKUP_DIR"

# 备份现有网站（如果存在）
if [ -d "$WEBSITE_DIR" ] && [ "$(ls -A $WEBSITE_DIR)" ]; then
    echo "💾 备份现有网站..."
    sudo cp -r "$WEBSITE_DIR" "$BACKUP_DIR/backup_$TIMESTAMP"
    echo "✅ 备份完成: $BACKUP_DIR/backup_$TIMESTAMP"
fi

# 清空目标目录
echo "🧹 清空目标目录..."
sudo rm -rf "$WEBSITE_DIR"/*

# 复制新网站文件
echo "📋 复制新网站文件..."
sudo cp -r "$SOURCE_DIR"/* "$WEBSITE_DIR/"

# 设置正确的文件权限
echo "🔐 设置文件权限..."
sudo chown -R www-data:www-data "$WEBSITE_DIR"
sudo find "$WEBSITE_DIR" -type d -exec chmod 755 {} \;
sudo find "$WEBSITE_DIR" -type f -exec chmod 644 {} \;

# 创建必要的目录结构
echo "📁 创建必要的目录结构..."
sudo mkdir -p "$WEBSITE_DIR/assets/images/"{hero,services,news,partners,flags,qr}
sudo mkdir -p "$WEBSITE_DIR/pages/"{services,news,enterprises,admin}

# 创建默认图片占位符（如果不存在）
echo "🖼️ 创建图片占位符..."
create_placeholder_image() {
    local dir="$1"
    local filename="$2"
    local size="$3"
    
    if [ ! -f "$WEBSITE_DIR/assets/images/$dir/$filename" ]; then
        # 创建简单的SVG占位符
        sudo tee "$WEBSITE_DIR/assets/images/$dir/$filename" > /dev/null << EOF
<svg width="$size" height="$size" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#f0f0f0"/>
  <text x="50%" y="50%" text-anchor="middle" dy=".3em" fill="#999">$filename</text>
</svg>
EOF
    fi
}

# 创建国旗图片占位符
create_placeholder_image "flags" "cn.png" "32"
create_placeholder_image "flags" "us.png" "32"

# 创建默认新闻图片
create_placeholder_image "news" "default.jpg" "400"

# 创建默认合作伙伴logo
create_placeholder_image "partners" "default.png" "200"

# 创建二维码占位符
create_placeholder_image "qr" "wechat.png" "120"
create_placeholder_image "qr" "service.png" "120"

# 验证关键文件
echo "✅ 验证部署文件..."
key_files=(
    "index.html"
    "assets/css/main.css"
    "assets/css/components.css"
    "assets/css/pages/home.css"
    "assets/js/main.js"
    "assets/js/i18n.js"
    "assets/js/api.js"
    "assets/js/pages/home.js"
    "assets/i18n/zh.json"
    "assets/i18n/en.json"
    "pages/services/index.html"
    "pages/contact.html"
)

missing_files=()
for file in "${key_files[@]}"; do
    if [ ! -f "$WEBSITE_DIR/$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo "⚠️  警告: 以下关键文件缺失:"
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
fi

# 重启Nginx以确保配置生效
echo "🔄 重启Nginx服务..."
sudo systemctl reload nginx

# 检查Nginx状态
if sudo systemctl is-active --quiet nginx; then
    echo "✅ Nginx服务运行正常"
else
    echo "❌ Nginx服务异常，请检查配置"
    sudo systemctl status nginx
fi

# 显示部署结果
echo ""
echo "=========================================="
echo "✅ 网站v2部署完成！"
echo "=========================================="
echo "🌐 网站地址: http://8.129.110.102/"
echo "📁 网站目录: $WEBSITE_DIR"
echo "💾 备份位置: $BACKUP_DIR/backup_$TIMESTAMP"
echo ""
echo "🔍 部署验证:"
echo "   - 访问首页: http://8.129.110.102/"
echo "   - 服务中心: http://8.129.110.102/pages/services/"
echo "   - 联系我们: http://8.129.110.102/pages/contact.html"
echo ""
echo "📝 注意事项:"
echo "   - 请确保后端API服务正在运行"
echo "   - 检查所有页面的国际化功能"
echo "   - 测试联系表单提交功能"
echo "   - 验证AI聊天功能（需要后端支持）"
echo ""

# 显示网站文件统计
echo "📊 网站文件统计:"
echo "   - HTML文件: $(find $WEBSITE_DIR -name "*.html" | wc -l) 个"
echo "   - CSS文件: $(find $WEBSITE_DIR -name "*.css" | wc -l) 个"
echo "   - JS文件: $(find $WEBSITE_DIR -name "*.js" | wc -l) 个"
echo "   - 总文件数: $(find $WEBSITE_DIR -type f | wc -l) 个"
echo "   - 总大小: $(du -sh $WEBSITE_DIR | cut -f1)"

echo ""
echo "🎉 部署完成！请访问网站进行测试。"