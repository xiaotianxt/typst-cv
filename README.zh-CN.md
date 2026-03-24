# typst-cv

[English](README.md) | [简体中文](README.zh-CN.md)

[![Build](https://img.shields.io/github/actions/workflow/status/xiaotianxt/typst-cv/ci.yml?branch=main&label=build)](https://github.com/xiaotianxt/typst-cv/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/xiaotianxt/typst-cv?label=release)](https://github.com/xiaotianxt/typst-cv/releases)
[![License](https://img.shields.io/github/license/xiaotianxt/typst-cv)](LICENSE)
[![GitHub Template](https://img.shields.io/badge/GitHub-template-181717?logo=github)](https://github.com/xiaotianxt/typst-cv/generate)
[![Typst](https://img.shields.io/badge/Typst-0.14%2B-239DAD?logo=typst&logoColor=white)](https://typst.app)

<p align="center">
  <img src="assets/project-hero.svg" alt="typst-cv 项目宣传图" />
</p>

<p align="center">
  一个基于 Typst 的模块化简历模板仓库，用一份内容源生成多份针对不同岗位的一页简历。
</p>

<p align="center">
  <img src="assets/resume-preview.png" alt="简历预览图" width="720" />
</p>

## 这个模板解决什么问题

- 每段工作经历、每个项目都独立成文件
- 同一份内容可以组合出多个岗位定向版本
- 支持编译时临时覆盖，快速拼装定制版简历
- Typst 和 YAML 都尽量保持简单，可读、可改、可维护
- 自带 GitHub Actions，推送后自动编译所有 profile

## 快速开始

1. 安装 [Typst](https://typst.app)。
2. 替换 `base.yml`、`profiles.yml` 和 `modules/` 里的示例内容。
3. 编译默认版本：

```bash
make compile PROFILE=software-engineer
```

输出文件位于 `build/software-engineer.pdf`。

## 示例 profile

- `software-engineer`：偏通用的软件工程简历
- `infra-platform`：偏平台、后端、稳定性方向
- `ml-systems`：偏机器学习基础设施和 GPU 系统方向
- `research-heavy`：项目优先、经历其次

查看所有 profile：

```bash
make profiles
```

编译全部 profile：

```bash
make all
```

监听单个 profile：

```bash
make watch PROFILE=infra-platform
```

运行检查：

```bash
make check-all
```

重新生成 README 里的预览图：

```bash
make preview PROFILE=software-engineer
```

## 仓库结构

```text
.
├── main.typ
├── base.yml
├── profiles.yml
├── modules/
│   ├── work/
│   └── projects/
├── lib/
│   ├── style.typ
│   ├── modules.typ
│   └── utils.typ
├── scripts/style-check.sh
└── .github/workflows/ci.yml
```

## 工作方式

- `base.yml` 保存个人信息、教育经历、技能等共享内容。
- `modules/work/*.yml` 每个文件对应一段工作经历。
- `modules/projects/*.yml` 每个文件对应一个项目。
- `profiles.yml` 通过模块 key 组合不同岗位版本。
- `main.typ` 根据选定的 profile 输出最终 PDF。

也支持不改 `profiles.yml`，直接在编译时临时指定模块：

```bash
typst compile main.typ build/custom.pdf \
  --input profile=software-engineer \
  --input work=northstar-cloud,aperture-ai \
  --input projects=distributed-cache,query-engine
```

## 中文支持

- 模板默认保持无 warning，并使用英文示例数据。
- 如果你要渲染中文内容，最合理的做法是在 `main.typ` 里把 `headingfont` 和 `bodyfont` 指向你本机已经安装的中文字体。
- 如果你的机器没有可用中文字体，建议安装 `Source Han Serif SC`、`Noto Serif CJK SC` 或 `Songti SC`。

示例配置：

```typst
#let uservars = (
  ..default-uservars,
  headingfont: ("Songti SC", "Source Han Serif SC", "Noto Serif CJK SC"),
  bodyfont: ("Songti SC", "Source Han Serif SC", "Noto Serif CJK SC"),
  margin: 0.40in,
  fontsize: 10pt,
  linespacing: 6pt,
)
```

## 自定义建议流程

1. 先替换 `base.yml` 里的身份信息。
2. 再按经历和项目逐个维护 `modules/` 下的文件。
3. 用 `profiles.yml` 组合你真正会投递的简历版本。
4. 提交前跑一次 `make check-all`。

也可以通过 `sectionOrder` 调整章节顺序，可用值为 `education`、`work`、`projects`、`skills`。

## 发布建议

1. 创建一个新的 GitHub 仓库。
2. 将仓库标记为 template repository。
3. 把 `assets/project-hero.svg` 或 `assets/resume-preview.png` 设为社交预览图。
4. 仓库描述可以用：

> Modular Typst resume template for role-specific one-page CVs.

## License

MIT
