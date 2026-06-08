# 404 除灵事务所 / 404 Exorcism Agency

> 新沪市异常案件档案 / New Hu City Anomaly Case Files

**2D 俯视角动作 Roguelite × 案件制怪谈调查 × 事务所经营 × 档案收集**

---

## 概述

你经营一家位于架空城市「新沪市」的除灵事务所。"异常"不只是鬼怪——它们是空间褶皱、数字污染、民俗失控、认知感染。每一份案件都是一个短关卡：进入异常现场，调查，战斗，击败 Boss，收容异常，归档。

1997 年灰线地铁 044 号列车载 35 名乘客失踪，三十年后异常碎片仍在隧道中扩散。你的任务是调查全部五个案件，还原真相。

## 技术栈

| 模块 | 技术 |
|------|------|
| 游戏引擎 | Godot 4 (GDScript) |
| 案件生成 | Python + FastAPI + MySQL |
| AI 辅助 | DeepSeek / OpenAI (可选) |
| 数据桥接 | JSON 导出 → Godot 读取 |

## 项目结构

```
├── game/                   # Godot 4 游戏本体
│   ├── scenes/             # 场景文件
│   │   ├── office/         # 事务所主场景
│   │   ├── combat/         # 战斗场景 / 敌人 / Boss
│   │   └── ui/             # HUD / 升级面板 / 结算 / 叙事
│   ├── scripts/            # GDScript 脚本
│   │   ├── core/           # GameManager / EventBus / SaveManager
│   │   ├── combat/         # 玩家 / 武器 / 技能 / 敌人 / Boss / 目标
│   │   ├── office/         # 事务所逻辑
│   │   └── ui/             # UI 控制器
│   └── data/               # JSON 数据
│       ├── cases/          # 案件数据
│       ├── characters/     # 角色数据
│       ├── skills/         # 技能 / 进化 / 遗物
│       ├── enemies/        # 敌人数据
│       └── narrative/      # 主线剧情文本
├── harvester/              # 怪谈采集器 (Python)
│   ├── app/                # FastAPI 应用
│   │   ├── routers/        # API 路由
│   │   ├── services/       # 搜索 / 提取 / 审核 / 生成 / 导出
│   │   └── llm/            # LLM Provider (Mock / OpenAI / DeepSeek)
│   ├── prompts/            # AI 提示词模板
│   └── tests/              # 测试
└── IMPLEMENTATION_PLAN.md  # 完整实施计划
```

## 快速开始

### Godot 游戏

1. 安装 [Godot 4](https://godotengine.org/)
2. 打开 `game/project.godot`
3. F5 运行

### 怪谈采集器

```bash
cd harvester
pip install -r requirements.txt
uvicorn app.main:app --reload
```

然后访问 `http://localhost:8000/docs` 查看 API 文档。

## 当前进度

| Phase | 状态 | 内容 |
|-------|------|------|
| 0 | ✓ | 项目初始化 |
| 1 | ✓ | 5 分钟战斗闭环 |
| 2 | ✓ | 案件系统 + 交互目标 |
| 3 | ✓ | 事务所 + 存档 + 角色选择 |
| 4 | ✓ | 怪谈采集器 (FastAPI + MySQL) |
| 5 | ✓ | 灰线地铁 5 案件 + 3 角色 + 12 技能 + 主线剧情 |

## 角色

| 角色 | 职业 | 风格 |
|------|------|------|
| 林锦 | 符咒黑客 | 远程穿透输出 |
| 徐招夜 | 民俗调查员 | 召唤物控场 |
| 白纸 | 半感染特工 | 近战吸血高防 |

## 技能

12 个可进化技能（含 5 条三阶进化链）：红符脉冲 → 超载电池 → 赤雷暴雨，纸人诱饵 → 香灰瓶 → 纸人夜行，鬼火无人机 → 黑客罗盘 → 鬼火群，铜钱剑阵 → 门神木牌 → 镇宅剑域，黑瞳凝视 → 腐化血清 → 死亡预兆。

## 许可

待定
