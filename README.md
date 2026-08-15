# DYYZDocs · 都匀一中新生指南

面向都匀一中新生的生活与课程指南网站(纯静态、多页面)。

## 站点结构

| 文件 | 说明 |
| --- | --- |
| `index.html` / `DYYZDocs.html` | 首页(Hero + 板块导航),两者内容相同 |
| `preread.html` | 看前须知 |
| `essentials.html` | 新生须知 |
| `courses.html` | 课程建议(科目概览 9 科 · 选课建议 · 赋分制度,整合单页) |
| `life.html` | 校园生活 |
| `faq.html` | 常见问题 |
| `about.html` | 关于我们 |
| `style.css` | 全站共享样式 |
| `script.js` | 全站共享脚本(侧边栏折叠/移动端抽屉/分组状态跨页保持) |
| `404.html` | GitHub Pages 自定义 404 页 |
| `build.ps1` | 站点生成脚本(修改内容后运行可重新生成全部页面) |

所有页面共用与首页一致的左侧全目录引导栏,点击任意板块/科目即可跳转。

## 本地预览

```bash
# 方式一:Node.js(推荐)
npx serve .

# 方式二:Python
python -m http.server 8000
```

然后浏览器访问 <http://localhost:3000>(npx serve)或 <http://localhost:8000>(python)。

## 部署到 GitHub Pages

本仓库已配置 GitHub Actions 自动部署工作流(`.github/workflows/deploy-pages.yml`),按以下步骤操作一次即可:

1. **推送代码**到 GitHub(main 分支):
   ```bash
   git add -A
   git commit -m "更新站点内容"
   git push origin main
   ```
2. **开启 GitHub Pages**(只需一次):
   - 打开仓库页面 → **Settings** → 左侧 **Pages**
   - **Build and deployment** → **Source** 选择 **GitHub Actions**
3. 等待 Actions 任务(`Deploy to GitHub Pages`)运行完成(约 1 分钟)。
4. 访问站点:
   `https://mutsum1-wy.github.io/DYYZDocs/`

之后每次 `git push origin main`,站点都会自动重新部署。

## 内容维护

1. 修改页面内容:直接编辑对应的 HTML 文件,或编辑 `build.ps1` 后运行 `.\build.ps1` 重新生成全部页面。
2. 页面内容建议在 `build.ps1` 中维护(它是唯一内容源),重新生成会覆盖各 HTML 文件。
3. 提交并推送后自动上线。
