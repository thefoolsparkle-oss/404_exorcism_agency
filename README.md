# 404 除灵事务所 / 404 Exorcism Agency

> 新沪市异常案件档案 · 2D 俯视角动作 Roguelite

你经营一家位于架空城市「新沪市」的除灵事务所。异常不只是鬼怪——是空间褶皱、数字污染、民俗失控、认知感染。每一份案件都是一个关卡：进入现场、调查、战斗、击败 Boss、归档。

**1997 年灰线地铁 044 号列车载 35 名乘客失踪。三十年后，碎片仍在扩散。**

---

## 内容

| 类别 | 数量 | 详情 |
|------|------|------|
| 案件 | **10** | 灰线地铁（5）+ 老城区（5），各有完整简报/目标/结案剧情 |
| Boss | **5** | 灰线列车员、站台暗影、镜中守护者、广播寄生体、逆行列车长 |
| 敌人 | **11** | 空座乘客、逆行客、暗影碎片、镜中复制体、被魅惑乘客、时间回响、纸鸟、巷猫、香炉娃娃、夜行人、低频噪音影 |
| 角色 | **3** | 林锦（符咒黑客/远程穿透）、徐招夜（民俗调查员/召唤控场）、白纸（半感染特工/近战吸血） |
| 技能 | **12** | 5 条三阶进化链 |
| 遗物 | **16** | 10 件灰线掉落 + 6 件老城区掉落 |
| 音频 | **14** | 环境音、战斗/ Boss BGM、全技能/受击/升级程序化音效 |
| 背景 | **动态** | 地铁隧道程序化渲染 + 图片替换支持 |

---

## 技术栈

| 模块 | 技术 |
|------|------|
| 游戏引擎 | Godot 4.6 (GDScript) |
| 案件生成 | Python + FastAPI + MySQL |
| AI 辅助 | DeepSeek / OpenAI（可选） |
| 数据桥接 | JSON 导出 → Godot 运行时读取 |

---

## 快速开始

### Godot 游戏

```
1. 安装 Godot 4
2. 用 Godot 打开 game/project.godot
3. F5 运行
```

### 怪谈采集器（可选）

```bash
cd harvester
pip install -r requirements.txt
uvicorn app.main:app --reload
```

---

## 项目结构

```
├── game/                     # Godot 4 游戏
│   ├── scenes/               # 场景文件 (office / combat / boss / ui)
│   ├── scripts/              # GDScript (core / combat / boss / office / ui)
│   ├── data/                 # JSON 数据 (cases / characters / skills / enemies / narrative)
│   ├── assets/               # 贴图 (characters / bosses / backgrounds)
│   └── tests/                # 集成测试
├── harvester/                # 怪谈采集器 (Python FastAPI)
└── IMPLEMENTATION_PLAN.md    # 完整实施计划
```

---

## 进度

| Phase | 内容 |
|-------|------|
| ✓ | 战斗闭环（WASD移动 / 自动瞄准 / 升级选技能） |
| ✓ | 案件系统（收集/拆除/Boss击败目标） |
| ✓ | 事务所（角色选择 / 案件终端 / 档案库） |
| ✓ | 存档系统（资源 / 案件进度 / 人物解锁） |
| ✓ | 5 灰线案件 + 5 老城区案件 + 主线剧情 |
| ✓ | 5 独立 Boss（各含多阶段/独特技能） |
| ✓ | 程序化音频（环境音 / 战斗BGM / Boss音乐 / 全SFX） |
| ✓ | 程序化背景渲染 |
| ○ | 4 老城区 Boss 独立脚本 |
| ○ | 升级台系统 |
| ○ | 更多案件（目标 30+） |
