# MarkText 项目上下文

## 项目概述

**MarkText** 是一个下一代 Markdown 编辑器，专注于速度和可用性。它是一个简单、优雅的开源 Markdown 编辑器，采用 WYSIWYG（所见即所得）实时预览技术。

### 核心特性

- **实时预览（WYSIWYG）**：清洁简洁的界面，提供无干扰的写作体验
- **Markdown 规范支持**：支持 CommonMark、GitHub Flavored Markdown (GFM) 和 Pandoc Markdown
- **Markdown 扩展**：数学表达式（KaTeX）、Front Matter、表情符号等
- **多种编辑模式**：源代码模式、打字机模式、专注模式
- **主题系统**：Cadmium Light、Material Dark、Graphite Light、Ulysses Light、One Dark 等
- **导出功能**：支持输出 HTML 和 PDF 文件
- **跨平台**：支持 Linux、macOS 和 Windows

### 技术栈

- **框架**：Electron（跨平台桌面应用）
- **前端**：Vue 2.x + Vuex（状态管理）+ Vue Router
- **UI 组件**：Element UI
- **编辑器核心**：
  - Muya（自定义 Markdown 编辑器引擎，基于块结构）
  - CodeMirror（源代码模式编辑器）
- **构建工具**：Webpack + Babel
- **包管理**：Yarn
- **测试**：Karma + Mocha + Chai（单元测试），Playwright（E2E 测试）

## 项目结构

```
marktext/
├ .electron-vue/        # Electron + Vue 构建配置
├ build/                # 生成的二进制文件（构建后）
├ dist/                 # 部署构建文件
├ docs/                 # 文档和资产
│   ├── dev/              # 开发者文档
│  └ i18n/             # 国际化文档
├ resources/            # 构建时使用的应用资源
├ src/                  # 源代码
│   ├── common/           # 通用代码（仅使用 Node.js API）
│   ├── main/             # Electron 主进程代码
│   ├── muya/             # MarkText 核心编辑器引擎（纯 JS）
│  └ renderer/         # Electron 渲染器进程（前端 UI）
├ static/               # 应用资产（图片、主题等）
├ test/                 # 测试代码
│   ├── e2e/              # 端到端测试
│  └ unit/             # 单元测试
├ tools/                # 开发工具脚本
├ package.json          # 项目配置
└ yarn.lock             # 依赖锁定文件
```

### 架构说明

MarkText 采用 Electron 的多进程架构：

1. **主进程（`src/main/`）**
   - 应用入口：`src/main/index.js`
   - 负责：文件系统 I/O、窗口管理、菜单、快捷键、偏好设置、拼写检查
   - 使用 Electron 主进程 API

2. **渲染器进程（`src/renderer/`）**
   - 应用入口：`src/renderer/main.js`
   - 负责：UI 组件、状态管理（Vuex）、编辑器窗口内容
   - 每个编辑器窗口运行独立的渲染器进程

3. **Muya 核心（`src/muya/`）**
   - 纯 JavaScript 实现，不使用 Electron 或 Node.js API
   - 提供实时预览和 Markdown 编辑功能
   - 基于块结构的数据存储
   - 支持 CommonMark 和 GFM 规范

4. **通用代码（`src/common/`）**
   - 可在主进程和渲染器进程中使用的共享代码

## 开发与构建

### 环境要求

- **Node.js**：>= v16 但 < v17
- **Yarn**：包管理器
- **Python**：>= v3.6（用于 node-gyp）
- **C++ 编译器**：用于原生模块编译

**Linux 额外依赖**：
```bash
sudo apt-get install libx11-dev libxkbfile-dev libsecret-1-dev libfontconfig-dev
```

### 常用命令

```bash
# 安装依赖
yarn install

# 开发模式（热重载）
yarn run dev

# 构建应用
yarn run build

# 仅构建二进制文件（不打包）
yarn run build:bin

# 代码检查
yarn run lint

# 自动修复代码风格问题
yarn run lint:fix

# 运行单元测试
yarn run unit

# 运行 E2E 测试
yarn run e2e

# 运行所有测试
yarn run test

# 构建 Muya 核心
yarn run build:muya
```

### 发布构建

```bash
# Linux
yarn run release:linux

# macOS
yarn run release:mac

# Windows
yarn run release:win
```

## 代码规范

### ESLint 配置

项目使用 ESLint 进行代码风格检查，基于以下规则：

- **缩进**：2 个空格
- **分号**：不使用分号（`semi: ['error', 'never']`）
- **标准**：遵循 StandardJS 规范
- **Vue**：使用 `plugin:vue/base`
- **文档**：推荐使用 JSDoc

### 代码风格指南

- 使用 ES6+ 语法
- 遵循"最佳实践"
- 2 空格缩进
- 不使用分号
- 使用 JSDoc 编写文档注释

### Git 工作流

1. 从 `develop` 分支创建功能分支
2. 提交 PR 到 `develop` 分支
3. PR 需要：
   - 通过 ESLint 检查
   - 所有测试通过
   - 通过 CI 检查
   - 在 PR 描述中引用相关 issue

## 重要文件说明

| 文件 | 说明 |
|------|------|
| `package.json` | 项目配置、依赖项和脚本 |
| `.eslintrc.js` | ESLint 配置 |
| `electron-builder.yml` | Electron Builder 打包配置 |
| `babel.config.js` | Babel 转译配置 |
| `vetur.config.js` | Vetur（Vue 工具）配置 |
| `src/main/index.js` | 主进程入口 |
| `src/renderer/main.js` | 渲染器进程入口 |
| `docs/dev/ARCHITECTURE.md` | 详细架构文档 |
| `docs/dev/BUILD.md` | 详细构建说明 |
| `CONTRIBUTING.md` | 贡献指南 |

## 设计理念

MarkText 的核心理念是**保持简洁、简单和最小化**。

- 界面不应分散用户注意力
- 功能应可通过设置启用/禁用
- 默认提供最小化的优秀界面
- 持续改进但不增加复杂性

## 测试

### 单元测试

- 框架：Karma + Mocha + Chai
- 配置：`test/unit/karma.conf.js`
- 运行：`yarn run unit`

### E2E 测试

- 框架：Playwright
- 配置：`test/e2e/playwright.config.js`
- 运行：`yarn run e2e`

### Markdown 规范测试

- CommonMark 规范测试：`test/specs/commonMark/run.spec.js`
- GFM 规范测试：`test/specs/gfm/run.spec.js`
- 运行：`yarn run test:specs`

## 常见问题

### 如何添加新功能？

1. 先打开 issue 讨论功能设计
2. 在 PR 中提供详细的理由说明
3. 确保代码通过 lint 和测试
4. 提交 PR 到 `develop` 分支

### 如何修复 Bug？

1. 搜索现有 issue
2. 在 PR 标题中使用 `fix: #<issue号> <简短描述>` 格式
3. 提供详细的 Bug 描述和复现步骤
4. 添加测试用例防止回归

### 许可证

本项目采用 **MIT** 许可证，详见 `LICENSE` 文件。

## 相关链接

- [官方网站](https://github.com/marktext/marktext)
- [开发者文档](docs/dev/README.md)
- [用户文档](docs/README.md)
- [贡献指南](CONTRIBUTING.md)
- [更新日志](.github/CHANGELOG.md)
