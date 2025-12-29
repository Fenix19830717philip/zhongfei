# 芙蓉出海信息总港部署指南

## 1. 项目概述

芙蓉出海信息总港是一个为企业提供跨境服务的综合平台，包含企业服务、政策咨询、新闻资讯等功能，支持中英文双语切换，具有政府级别的权威感和可信度。

## 2. 系统架构

### 前端
- **技术栈**: 静态HTML + CSS + JavaScript
- **文件结构**: flocaetp-website/
  - index.html: 主页面
  - public/: 静态资源目录
  - package.json: 工程配置

### 后端
- **技术栈**: Node.js + Express + SQLite
- **文件结构**: flocaetp-server/
  - server.js: 主服务端代码
  - package.json: 依赖配置
  - flocaetp.db: SQLite数据库文件

## 3. 环境配置

### 3.1 基本环境要求
- Node.js 14.x 或更高版本
- npm 或 yarn 包管理器
- Python 3.x (用于开发环境快速测试)

### 3.2 安装依赖

#### 前端
```bash
cd flocaetp-website
npm install
```

#### 后端
```bash
cd flocaetp-server
npm install
```

## 4. 运行与测试

### 4.1 开发环境运行

#### 前端开发服务
```bash
cd flocaetp-website
npm run dev
```
访问地址: http://localhost:8080

#### 后端开发服务
```bash
cd flocaetp-server
npm run dev
```
访问地址: http://localhost:3000

#### 快速测试 (无需依赖)
```bash
cd flocaetp-website
python -m http.server 8000
```

### 4.2 API 测试

#### 健康检查
```bash
curl http://localhost:3000/api/health
```

#### 创建咨询
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"company_name": "Test Company", "email": "test@example.com", "message": "Hello World"}' \
  http://localhost:3000/api/consultations
```

## 5. 生产部署

### 5.1 前端部署

#### 生成构建产物
```bash
cd flocaetp-website
npm run build
```
构建文件将输出到 build/ 目录

#### 部署到静态网站服务
- **Cloudflare Pages**: 使用build目录部署
- **GitHub Pages**: 将build目录内容推送到仓库
- **Nginx**: 配置Nginx指向build目录

### 5.2 后端部署

#### 方案一：使用PM2管理进程
```bash
npm install -g pm2
cd flocaetp-server
pm2 start server.js --name flocaetp-api
```

#### 方案二：使用Docker
```bash
cat > Dockerfile << 'EOF'
FROM node:14-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
EOF

docker build -t flocaetp-api .
docker run -d -p 3000:3000 flocaetp-api
```

### 5.3 Nginx 配置 (已完成)

✅ **Task 4 已完成**: Nginx配置和反向代理设置已完成，包含以下功能：

- 静态文件服务 (前端网站)
- API反向代理 (/api路径)
- GZIP压缩优化
- 缓存控制策略
- CORS跨域支持
- 安全头设置
- 访问限制和错误处理
- 日志记录

**配置文件位置**: `/etc/nginx/sites-available/flocaetp`
**执行脚本**: `configure-nginx-proxy.sh` 或 `configure-nginx-proxy.ps1`
**验证脚本**: `verify-nginx-proxy.sh`

详细部署说明请参考: `NGINX_DEPLOYMENT_INSTRUCTIONS.md`
```

## 6. 环境变量

在 flocaetp-server/ 目录下创建 .env 文件

```env
PORT=3000
JWT_SECRET=your-secret-key-here
NODE_ENV=production
```

## 7. 数据库管理

### 7.1 SQLite 数据库文件
- 位置: flocaetp-server/flocaetp.db
- 使用工具: DB Browser for SQLite

### 7.2 表结构
- admins: 管理员信息
- consultations: 咨询数据
- news: 新闻资讯
- enterprises: 入驻企业

## 8. 常见问题

### Q: 为什么访问不了后端API?
A: 请确保后端服务已启动，并且防火墙允许端口3000

### Q: 如何修改默认管理员密码?
A: 使用bcrypt生成新密码哈希，然后更新数据库admins表

### Q: 前端如何配置API接口地址?
A: 修改 index.html 中的 API_BASE_URL 常量

## 9. 维护与监控

- **日志**: 使用 pm2 logs flocaetp-api 查看日志
- **备份**: 定期备份 flocaetp.db 文件
- **更新**: 使用 git pull 拉取最新代码，然后重启服务

## 10. 联系方式

如有问题，请联系开发团队：flocaetp-dev@example.com
