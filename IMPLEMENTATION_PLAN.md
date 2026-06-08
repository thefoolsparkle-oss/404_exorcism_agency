# 404 除灵事务所 — 完整实施计划

> 版本：V0.1  
> 日期：2026-06-08  
> 对应策划文档：`404_exorcism_agency_full_plan.docx`

---

## 目录

1. [总则与架构原则](#1-总则与架构原则)
2. [Phase 0：项目初始化](#2-phase-0项目初始化)
3. [Phase 1：5 分钟可玩战斗闭环](#3-phase-15-分钟可玩战斗闭环)
4. [Phase 2：案件系统](#4-phase-2案件系统)
5. [Phase 3：事务所经营系统](#5-phase-3事务所经营系统)
6. [Phase 4：怪谈采集器 MVP](#6-phase-4怪谈采集器-mvp)
7. [Phase 5：灰线地铁 MVP 发布](#7-phase-5灰线地铁-mvp-发布)
8. [Phase 6：正式扩展与 Steam Demo](#8-phase-6正式扩展与-steam-demo)
9. [附录 A：JSON Schema 完整定义](#9-附录-ajson-schema-完整定义)
10. [附录 B：信号事件总线参考](#10-附录-b信号事件总线参考)
11. [附录 C：数值表](#11-附录-c数值表)
12. [附录 D：测试清单](#12-附录-d测试清单)
13. [附录 E：AI 提示词模板](#13-附录-eai-提示词模板)

---

## 1. 总则与架构原则

### 1.1 项目结构（最终态）

```
E:\404 除灵事务所\
├── 404_exorcism_agency_full_plan.docx   # 策划文档
├── IMPLEMENTATION_PLAN.md              # 本文件
├── game/                               # Godot 4 游戏本体
│   ├── project.godot
│   ├── scenes/
│   │   ├── main/                       # 主菜单 / 加载页
│   │   ├── office/                     # 事务所（Phase 3）
│   │   ├── combat/                     # 战斗场景
│   │   │   ├── enemies/                # 敌人子场景
│   │   │   └── boss/                   # Boss 子场景
│   │   ├── ui/                         # UI 场景（HUD / 升级面板 / 结算）
│   │   └── events/                     # 事件点 / 选项事件
│   ├── scripts/
│   │   ├── core/                       # GameManager, SaveManager, DataLoader, EventBus
│   │   ├── combat/                     # PlayerController, EnemyAI, SkillSystem, WeaponSystem, SpawnDirector
│   │   ├── office/                     # CaseManager, ArchiveManager, UpgradeManager
│   │   └── ui/                         # HUDController, LevelUpPanel, ResultPanel
│   ├── data/                           # JSON 数据文件（game 直接读取）
│   │   ├── cases/                      # approved_cases.json
│   │   ├── characters/                 # characters.json
│   │   ├── skills/                     # skills.json, evolutions.json, relics.json
│   │   ├── enemies/                    # enemies.json, bosses.json
│   │   └── localization/              # zh_cn.json, en.json
│   └── assets/                         # 美术/音效（Phase 1 全部占位）
│       ├── characters/
│       ├── enemies/
│       ├── bosses/
│       ├── backgrounds/
│       ├── ui/
│       ├── icons/
│       ├── vfx/
│       └── audio/
├── harvester/                          # 怪谈采集器（Phase 4+）
│   ├── app/
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── models/                     # SQLAlchemy models
│   │   ├── schemas/                    # Pydantic schemas
│   │   ├── routers/                    # sources, motifs, cases, exports
│   │   ├── services/
│   │   │   ├── search_service.py
│   │   │   ├── source_fetcher.py
│   │   │   ├── motif_extractor.py
│   │   │   ├── risk_filter.py
│   │   │   ├── case_generator.py
│   │   │   ├── style_rewriter.py
│   │   │   └── exporter.py
│   │   └── llm/
│   │       ├── provider_base.py
│   │       ├── deepseek_provider.py
│   │       ├── openai_provider.py
│   │       └── mock_provider.py
│   ├── prompts/
│   │   ├── extract_motif.md
│   │   ├── risk_review.md
│   │   ├── generate_case.md
│   │   └── rewrite_style.md
│   ├── exports/                        # 导出 JSON → game/data/cases/
│   ├── tests/
│   └── requirements.txt
└── docker-compose.yml                  # MySQL + Harvester（Phase 4+）
```

### 1.2 核心铁则

| 规则 | 说明 |
|------|------|
| **game 不直连 MySQL** | MySQL 只属于 harvester；game 只读 JSON |
| **harvester 负责生成** | 采集 → 提取 → 审核 → 导出 JSON |
| **先跑通再扩展** | 每阶段验收标准必须达成后才进入下一阶段 |
| **占位优先** | 美术/音效一律用占位资源，不阻塞代码 |
| **每功能一提交** | 一个功能完成即 git commit，禁止 50+ 文件的大提交 |
| **代码模块化** | 场景与逻辑解耦；每个 .gd 文件单一职责 |
| **文本格式** | 代码/文件名/JSON key：英文 snake_case；显示文本：中文 + 英文副名 |
| **硬约束** | 不做 3D，不做开放世界，不做传统 RPG，不做联网对战 |

### 1.3 环境与工具

| 工具 | 版本 | 用途 | Phase |
|------|------|------|-------|
| Godot | 4.4.1 stable (标准版) | 游戏引擎 | 1+ |
| GDScript | Godot 内置 | 游戏脚本 | 1+ |
| Python | 3.11+ | 采集器后端 | 4+ |
| FastAPI | latest | Web API | 4+ |
| MySQL | 8.0+（Docker） | 采集器数据库 | 4+ |
| SQLAlchemy + Alembic | latest | ORM + 迁移 | 4+ |
| Docker Desktop | latest | MySQL 容器 | 4+ |
| Git | any | 版本控制 | 0+ |
| VS Code / Cursor | any | 代码编辑 | 0+ |
| DeepSeek / OpenAI API | — | LLM 调用 | 4+ |

---

## 2. Phase 0：项目初始化

### 2.1 目标

建立两个空项目骨架，验证 Godot 可运行、FastAPI 可启动、MySQL 可连接。

### 2.2 验收标准

- [ ] Godot 4 项目创建成功，编辑器可打开
- [ ] `F5` 运行项目可看到窗口
- [ ] 目录结构按规划创建完毕
- [ ] Git 仓库初始化，`.gitignore` 就位
- [ ] （可选）FastAPI 项目创建，`/health` 返回 OK
- [ ] （可选）MySQL 可连接

### 2.3 操作步骤

#### 2.3.1 Godot 项目初始化

1. 打开 Godot 4.4.1
2. 新建项目 → 路径 `E:\404 除灵事务所\game\`
3. 渲染器选 `Forward+`（2D 游戏用兼容模式亦可）
4. 创建目录结构：

```
game/
├── project.godot          # 自动生成
├── scenes/
│   ├── main/
│   ├── combat/
│   │   ├── enemies/
│   │   └── boss/
│   ├── ui/
│   └── office/
├── scripts/
│   ├── core/
│   ├── combat/
│   ├── ui/
│   └── office/
├── data/
│   ├── cases/
│   ├── characters/
│   ├── skills/
│   ├── enemies/
│   └── localization/
└── assets/
    ├── characters/
    ├── enemies/
    ├── bosses/
    ├── backgrounds/
    ├── ui/
    ├── icons/
    ├── vfx/
    └── audio/
```

#### 2.3.2 .gitignore 内容

```gitignore
# Godot
.godot/
*.import
*.translation
export/
export_presets.cfg

# Python
__pycache__/
*.pyc
.venv/
venv/

# IDE
.vscode/
.idea/

# OS
Thumbs.db
.DS_Store

# Secrets
.env
*.env
secrets/
```

#### 2.3.3 Git 仓库

```bash
cd "E:\404 除灵事务所"
git init
git add .
git commit -m "Phase 0: project initialization — Godot, FastAPI, MySQL scaffolding"
```

#### 2.3.4 project.godot 初始配置

- 项目名称：`404 Exorcism Agency`
- 窗口尺寸：1920×1080（可缩放）
- 初始场景：`res://scenes/main/main.tscn`（暂缺，先留空）
- 自动加载单例（稍后在 Phase 1 添加）：`EventBus`

### 2.4 文件清单

| 文件 | 状态 | 说明 |
|------|------|------|
| `game/project.godot` | 新建 | Godot 自动生成后手动编辑窗口设置 |
| `.gitignore` | 新建 | 如上内容 |
| `game/scenes/main/` | 空目录 | 预留主菜单 |
| `game/scenes/combat/` | 空目录 | 预留战斗 |
| `game/scenes/ui/` | 空目录 | 预留 UI |
| `game/scripts/core/` | 空目录 | 预留核心脚本 |
| `game/scripts/combat/` | 空目录 | 预留战斗脚本 |
| `game/scripts/ui/` | 空目录 | 预留 UI 脚本 |
| `game/data/**/*` | 空目录 | 预留数据文件 |
| `game/assets/**/*` | 空目录 | 预留资源 |
| `harvester/` 目录树 | 暂不创建 | Phase 4 再建 |

---

## 3. Phase 1：5 分钟可玩战斗闭环

### 3.1 目标

一个独立的 Godot 战斗原型：打开项目 → 进入战斗 → WASD 移动 → 敌人刷出追踪 → 自动攻击 → 杀敌掉经验 → 升级三选一 → Boss 出现 → 胜利/失败结算。

### 3.2 验收标准（完整清单）

- [ ] 项目 `F5` 运行后可进入战斗场景
- [ ] 玩家 WASD 移动流畅，摄像机跟随
- [ ] 敌人周期性生成并追踪玩家
- [ ] 玩家自动攻击最近敌人（子弹/投射物可见）
- [ ] 敌人有血量、被击杀后消失并掉落经验球
- [ ] 玩家拾取经验球，经验条上涨
- [ ] 经验满后游戏暂停，弹出三选一技能面板
- [ ] 共有 5 个基础技能可选、可升级
- [ ] 技能效果正确（穿透、链式、AOE、召唤、护盾）
- [ ] 存活约 120 秒后 Boss「灰线列车员」出现
- [ ] Boss 有 4 种攻击模式
- [ ] 击败 Boss → 显示「任务完成」结算
- [ ] 玩家死亡 → 显示「任务失败」结算
- [ ] 结算面板可重新开始或退出
- [ ] 所有敌人/玩家/Boss 使用占位图形

### 3.3 子阶段拆分

| 子阶段 | 内容 | 依赖 |
|--------|------|------|
| **1.0** | EventBus 单例 + GameManager 状态机 | 无 |
| **1.1** | 战斗场景 + 玩家移动 + 摄像机 | 1.0 |
| **1.2** | 敌人生成 + 基础 AI | 1.1 |
| **1.3** | 自动攻击系统 + 投射物 | 1.1 |
| **1.4** | 血量系统 + 伤害 + 死亡 | 1.2, 1.3 |
| **1.5** | 经验球 + 经验条 + 升级检测 | 1.4 |
| **1.6** | 技能系统 + 三选一 UI | 1.5 |
| **1.7** | Boss 战 | 1.2, 1.4 |
| **1.8** | 胜利/失败结算面板 | 1.7 |
| **1.9** | 数值平衡 + 全流程验证 | 全部 |

### 3.4 子阶段详细设计

---

#### **子阶段 1.0：EventBus + GameManager 状态机**

##### 文件

| 文件 | 路径 |
|------|------|
| `event_bus.gd` | `game/scripts/core/event_bus.gd` |
| `game_manager.gd` | `game/scripts/core/game_manager.gd` |

##### EventBus（自动加载单例）

```gdscript
# event_bus.gd — 全局信号总线
extends Node

# 战斗生命周期
signal combat_started()
signal combat_ended(victory: bool)
signal combat_paused()
signal combat_resumed()

# 玩家
signal player_health_changed(current: int, max_hp: int)
signal player_died()
signal player_leveled_up(new_level: int)

# 敌人
signal enemy_spawned(enemy_instance: Node2D)
signal enemy_killed(enemy_type: String, position: Vector2)
signal boss_spawned()
signal boss_health_changed(current: int, max_hp: int)
signal boss_defeated()

# 经验
signal experience_dropped(position: Vector2, amount: int)
signal experience_collected(amount: int)

# 技能
signal skill_acquired(skill_id: String, tier: int)

# 游戏管理
signal request_pause()
signal request_resume()
signal request_restart()
signal request_main_menu()
```

##### GameManager 状态机

```
状态枚举：
  MAIN_MENU
  COMBAT_LOADING
  COMBAT_ACTIVE
  COMBAT_PAUSED
  COMBAT_VICTORY
  COMBAT_DEFEAT

转换：
  MAIN_MENU → COMBAT_LOADING（点击开始）
  COMBAT_LOADING → COMBAT_ACTIVE（加载完成）
  COMBAT_ACTIVE → COMBAT_PAUSED（升级/暂停）
  COMBAT_PAUSED → COMBAT_ACTIVE（选择完毕/恢复）
  COMBAT_ACTIVE → COMBAT_VICTORY（Boss 死亡）
  COMBAT_ACTIVE → COMBAT_DEFEAT（玩家死亡）
  COMBAT_VICTORY → MAIN_MENU（点击返回）
  COMBAT_DEFEAT → MAIN_MENU（点击返回）
  COMBAT_VICTORY → COMBAT_LOADING（点击重试）
  COMBAT_DEFEAT → COMBAT_LOADING（点击重试）
```

```gdscript
# game_manager.gd — 游戏状态机
extends Node

enum GameState {
    MAIN_MENU,
    COMBAT_LOADING,
    COMBAT_ACTIVE,
    COMBAT_PAUSED,
    COMBAT_VICTORY,
    COMBAT_DEFEAT
}

var current_state: GameState = GameState.MAIN_MENU

func _ready() -> void:
    EventBus.request_pause.connect(_on_request_pause)
    EventBus.request_resume.connect(_on_request_resume)
    EventBus.request_restart.connect(_on_request_restart)
    EventBus.request_main_menu.connect(_on_request_main_menu)
    EventBus.player_died.connect(_on_player_died)
    EventBus.boss_defeated.connect(_on_boss_defeated)

func change_state(new_state: GameState) -> void:
    current_state = new_state
    match new_state:
        GameState.COMBAT_ACTIVE:
            get_tree().paused = false
        GameState.COMBAT_PAUSED:
            get_tree().paused = true
        GameState.COMBAT_VICTORY, GameState.COMBAT_DEFEAT:
            get_tree().paused = true

func _on_request_pause() -> void:
    if current_state == GameState.COMBAT_ACTIVE:
        change_state(GameState.COMBAT_PAUSED)
        EventBus.combat_paused.emit()

func _on_request_resume() -> void:
    if current_state == GameState.COMBAT_PAUSED:
        change_state(GameState.COMBAT_ACTIVE)
        EventBus.combat_resumed.emit()

func _on_request_restart() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_request_main_menu() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_player_died() -> void:
    change_state(GameState.COMBAT_DEFEAT)
    EventBus.combat_ended.emit(false)

func _on_boss_defeated() -> void:
    change_state(GameState.COMBAT_VICTORY)
    EventBus.combat_ended.emit(true)
```

##### 项目设置

在 `project.godot` 中添加自动加载：

```
[autoload]

EventBus="*res://scripts/core/event_bus.gd"
GameManager="*res://scripts/core/game_manager.gd"
```

---

#### **子阶段 1.1：战斗场景 + 玩家移动 + 摄像机**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `main.tscn` | `game/scenes/main/main.tscn` | 入口场景 |
| `main.gd` | `game/scripts/main/main.gd` | 入口脚本（开始按钮） |
| `combat.tscn` | `game/scenes/combat/combat.tscn` | 战斗场景 |
| `player.tscn` | `game/scenes/combat/player.tscn` | 玩家场景 |
| `player_controller.gd` | `game/scripts/combat/player_controller.gd` | 玩家移动+逻辑 |

##### main.tscn 节点树

```
Main (Node2D)
└── margin_container (MarginContainer)
    └── vbox (VBoxContainer)
        ├── title_label (Label) "404 除灵事务所"
        ├── subtitle_label (Label) "New Hu City Anomaly Files"
        ├── spacer (Control)
        ├── start_button (Button) "进入任务"
        └── quit_button (Button) "退出游戏"
```

##### combat.tscn 节点树

```
Combat (Node2D)
├── ground (ColorRect)              # 深色背景 3840×2160
├── border_lines (Node2D)           # 四周边界线（占位）
├── obstacles (Node2D)              # 障碍物容器（Phase 1 可为空）
├── entities (Node2D)               # 实体容器
│   ├── player (Player)             # 玩家实例
│   └── enemies (Node2D)            # 敌人生成点
├── projectiles (Node2D)            # 投射物容器
├── experience_orbs (Node2D)        # 经验球容器
├── camera (Camera2D)               # 摄像机
│   └── bounds (CollisionShape2D)   # 摄像机边界
└── ui_layer (CanvasLayer)
    ├── hud (HUD)                   # Phase 1.4+
    ├── level_up_panel (LevelUpPanel) # Phase 1.6+
    └── result_panel (ResultPanel)  # Phase 1.8+
```

##### player.tscn 节点树

```
Player (CharacterBody2D)
├── collision_shape (CollisionShape2D)  # CircleShape2D, radius=20
├── visual (ColorRect)                  # 40×40, 蓝色系 ColorRect
├── auto_aim_indicator (ColorRect)      # 小红色指示器（瞄准方向）
├── hitbox (Area2D)                     # 受击区域
│   └── hitbox_collision (CollisionShape2D)  # CircleShape2D, radius=20
└── pickup_area (Area2D)                # 拾取区域
    └── pickup_collision (CollisionShape2D)  # CircleShape2D, radius=50
```

##### PlayerController.gd

```gdscript
# player_controller.gd — 玩家移动 + 属性
extends CharacterBody2D

# 属性
@export var max_hp: int = 100
@export var move_speed: float = 200.0

var current_hp: int = max_hp
var level: int = 1
var experience: int = 0
var experience_to_next: int = 30

func _ready() -> void:
    current_hp = max_hp
    EventBus.player_health_changed.emit(current_hp, max_hp)

func _physics_process(_delta: float) -> void:
    var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = input_dir * move_speed
    move_and_slide()

    # 限制在地图边界内
    global_position.x = clamp(global_position.x, 50, 3790)
    global_position.y = clamp(global_position.y, 50, 2110)

func take_damage(amount: int) -> void:
    current_hp -= amount
    EventBus.player_health_changed.emit(current_hp, max_hp)
    if current_hp <= 0:
        current_hp = 0
        EventBus.player_died.emit()

func add_experience(amount: int) -> void:
    experience += amount
    while experience >= experience_to_next:
        experience -= experience_to_next
        level += 1
        experience_to_next = _calculate_xp_for_level(level)
        EventBus.request_pause.emit()
        EventBus.player_leveled_up.emit(level)

func _calculate_xp_for_level(lvl: int) -> int:
    return 20 + lvl * 10
```

##### 摄像机设置

- Camera2D 挂在 combat.tscn 根节点下
- `drag_horizontal_enabled = true`, `drag_vertical_enabled = true`
- `limit_smoothed = true`
- 四边界：`limit_left = 0`, `limit_right = 3840`, `limit_top = 0`, `limit_bottom = 2160`
- 地图尺寸：3840 × 2160（约 2× 窗口尺寸）

##### 输入映射（Project Settings → Input Map）

| Action | Key |
|--------|-----|
| `move_up` | W |
| `move_down` | S |
| `move_left` | A |
| `move_right` | D |
| `skill_1` | Space |
| `skill_2` | Q |
| `skill_3` | E |
| `skill_4` | R |
| `skill_5` | F |
| `skill_choice_1` | 1 |
| `skill_choice_2` | 2 |
| `skill_choice_3` | 3 |
| `pause` | Escape |
| `confirm` | Enter |

---

#### **子阶段 1.2：敌人生成 + 基础 AI**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `spawn_director.gd` | `game/scripts/combat/spawn_director.gd` | 刷怪控制器 |
| `enemy_base.tscn` | `game/scenes/combat/enemies/enemy_base.tscn` | 敌人基类场景 |
| `enemy_ai.gd` | `game/scripts/combat/enemy_ai.gd` | 敌人 AI 脚本 |
| `health_component.gd` | `game/scripts/combat/health_component.gd` | 通用血量组件 |
| `enemies.json` | `game/data/enemies/enemies.json` | 敌人数据 |

##### 敌人类型（Phase 1 三类）

| ID | 显示名 | 视觉 | 行为 |
|----|--------|------|------|
| `empty_seat_passenger` | 空座乘客 | 30×30 灰白色矩形 | 高速近身，碰撞伤害 |
| `low_frequency_shade` | 低频噪音影 | 36×36 暗紫色矩形 | 中速接近，远程发射子弹 |
| `reverse_walker` | 逆行客 | 32×32 暗红色矩形 | 每 3 秒闪现到玩家身后 |

##### enemies.json

```json
{
  "empty_seat_passenger": {
    "id": "empty_seat_passenger",
    "name_cn": "空座乘客",
    "name_en": "Empty-Seat Passenger",
    "hp": 30,
    "move_speed": 150.0,
    "damage": 15,
    "contact_damage": true,
    "attack_range": 0,
    "attack_cooldown": 0.0,
    "projectile_speed": 0,
    "experience_drop": 10,
    "size": 30,
    "color": "dimgray"
  },
  "low_frequency_shade": {
    "id": "low_frequency_shade",
    "name_cn": "低频噪音影",
    "name_en": "Low-Frequency Noise Shade",
    "hp": 50,
    "move_speed": 80.0,
    "damage": 20,
    "contact_damage": false,
    "attack_range": 400.0,
    "attack_cooldown": 1.5,
    "projectile_speed": 250.0,
    "experience_drop": 15,
    "size": 36,
    "color": "darkviolet"
  },
  "reverse_walker": {
    "id": "reverse_walker",
    "name_cn": "逆行客",
    "name_en": "Reverse Walker",
    "hp": 40,
    "move_speed": 120.0,
    "damage": 25,
    "contact_damage": true,
    "attack_range": 0,
    "attack_cooldown": 0.0,
    "projectile_speed": 0,
    "experience_drop": 15,
    "size": 32,
    "color": "darkred",
    "special": "teleport",
    "teleport_cooldown": 3.0
  }
}
```

##### EnemyAI.gd

```gdscript
# enemy_ai.gd — 敌人 AI
extends CharacterBody2D

@export var enemy_id: String = ""
@export var max_hp: int = 30
@export var move_speed: float = 100.0
@export var damage: int = 10
@export var contact_damage: bool = true
@export var attack_range: float = 0.0
@export var attack_cooldown: float = 0.0
@export var projectile_speed: float = 200.0
@export var experience_drop: int = 10
@export var color: Color = Color.DIM_GRAY

var current_hp: int
var attack_timer: float = 0.0
var teleport_timer: float = 0.0
var teleport_cooldown: float = 3.0
var is_reverse_walker: bool = false

@onready var visual: ColorRect = $visual
@onready var player: CharacterBody2D = null
@onready var projectile_scene: PackedScene = preload("res://scenes/combat/enemy_projectile.tscn")

func _ready() -> void:
    current_hp = max_hp
    visual.color = color
    visual.size = Vector2(enemy_id.size if... )  # 根据配置设置大小
    if enemy_id == "reverse_walker":
        is_reverse_walker = true

func _physics_process(delta: float) -> void:
    if player == null:
        return

    # 逆向客：闪现逻辑
    if is_reverse_walker:
        teleport_timer -= delta
        if teleport_timer <= 0:
            _teleport_behind_player()
            teleport_timer = teleport_cooldown

    # 追踪玩家
    var direction: Vector2 = (player.global_position - global_position).normalized()
    var distance: float = global_position.distance_to(player.global_position)

    # 近战敌人：直接冲向玩家
    if contact_damage:
        velocity = direction * move_speed
    # 远程敌人：保持距离，到射程内停止移动并攻击
    else:
        if distance > attack_range * 1.2:
            velocity = direction * move_speed
        elif distance < attack_range * 0.5:
            velocity = -direction * move_speed * 0.5
        else:
            velocity = Vector2.ZERO
            attack_timer -= delta
            if attack_timer <= 0:
                _shoot(direction)
                attack_timer = attack_cooldown

    move_and_slide()

func _teleport_behind_player() -> void:
    # 闪现到玩家面向的反方向后方
    var behind: Vector2 = player.global_position
    var dir_to_player: Vector2 = (player.global_position - global_position).normalized()
    if dir_to_player.length() > 0:
        behind = player.global_position - dir_to_player * 80.0
    global_position = behind

func _shoot(direction: Vector2) -> void:
    var proj: Area2D = projectile_scene.instantiate()
    proj.global_position = global_position
    proj.direction = direction
    proj.speed = projectile_speed
    proj.damage = damage
    get_tree().current_scene.get_node("projectiles").add_child(proj)

func take_damage(amount: int) -> void:
    current_hp -= amount
    var flash_tween: Tween = create_tween()
    flash_tween.tween_property(visual, "modulate", Color.RED, 0.1)
    flash_tween.tween_property(visual, "modulate", Color.WHITE, 0.1)
    if current_hp <= 0:
        _die()

func _die() -> void:
    EventBus.enemy_killed.emit(enemy_id, global_position)
    EventBus.experience_dropped.emit(global_position, experience_drop)
    queue_free()
```

##### SpawnDirector.gd

```gdscript
# spawn_director.gd — 刷怪控制器
extends Node2D

@export var spawn_interval_min: float = 3.0
@export var spawn_interval_max: float = 1.0    # 随时间缩短
@export var ramp_duration: float = 120.0         # 渐变时长
@export var boss_spawn_time: float = 120.0
@export var spawn_area_size: Vector2 = Vector2(500, 500)
@export var min_spawn_distance: float = 400.0

var timer: float = 0.0
var next_spawn: float = 3.0
var game_timer: float = 0.0
var boss_spawned: bool = false
var enabled: bool = false

var enemy_scenes: Dictionary = {
    "empty_seat_passenger": preload("res://scenes/combat/enemies/enemy_base.tscn"),
    "low_frequency_shade": preload("res://scenes/combat/enemies/enemy_base.tscn"),
    "reverse_walker": preload("res://scenes/combat/enemies/enemy_base.tscn")
}
var enemy_data: Dictionary = {}

@onready var player: CharacterBody2D = $"../entities/player"
@onready var enemies_container: Node2D = $"../entities/enemies"

func _ready() -> void:
    enemy_data = DataLoader.load_json("res://data/enemies/enemies.json")
    EventBus.combat_started.connect(_on_combat_started)
    EventBus.combat_ended.connect(_on_combat_ended)
    EventBus.combat_paused.connect(_on_paused)
    EventBus.combat_resumed.connect(_on_resumed)

func _on_combat_started() -> void:
    enabled = true
    game_timer = 0.0
    timer = 0.0
    next_spawn = spawn_interval_min
    boss_spawned = false

func _on_combat_ended(_victory: bool) -> void:
    enabled = false

func _on_paused() -> void:
    enabled = false

func _on_resumed() -> void:
    enabled = true

func _process(delta: float) -> void:
    if not enabled:
        return

    game_timer += delta

    # Boss 时间到
    if game_timer >= boss_spawn_time and not boss_spawned:
        _spawn_boss()
        return

    # 敌人刷新
    timer += delta
    if timer >= next_spawn:
        timer = 0.0
        _spawn_enemy()
        # 随时间加速刷怪
        var t: float = min(game_timer / ramp_duration, 1.0)
        next_spawn = lerp(spawn_interval_min, spawn_interval_max, t)

func _spawn_enemy() -> void:
    var spawn_pos: Vector2 = _get_spawn_position()
    var enemy_type: String = _choose_enemy_type()
    var enemy: CharacterBody2D = enemy_scenes[enemy_type].instantiate()
    enemy.global_position = spawn_pos
    enemy.enemy_id = enemy_type
    var data: Dictionary = enemy_data[enemy_type]
    enemy.max_hp = data.hp
    enemy.move_speed = data.move_speed
    enemy.damage = data.damage
    enemy.contact_damage = data.contact_damage
    enemy.attack_range = data.attack_range
    enemy.attack_cooldown = data.attack_cooldown
    enemy.projectile_speed = data.projectile_speed
    enemy.experience_drop = data.experience_drop
    enemy.color = Color(data.color)
    enemies_container.add_child(enemy)
    EventBus.enemy_spawned.emit(enemy)

func _get_spawn_position() -> Vector2:
    # 在玩家周围 spawn_area_size 范围外生成
    var angle: float = randf_range(0, TAU)
    var dist: float = randf_range(min_spawn_distance, min_spawn_distance + 300)
    var pos: Vector2 = player.global_position + Vector2.RIGHT.rotated(angle) * dist
    pos.x = clamp(pos.x, 50, 3790)
    pos.y = clamp(pos.y, 50, 2110)
    return pos

func _choose_enemy_type() -> String:
    # 按时间解锁敌人类型
    var types: Array[String] = ["empty_seat_passenger"]
    if game_timer > 30:
        types.append("reverse_walker")
    if game_timer > 60:
        types.append("low_frequency_shade")
    return types[randi() % types.size()]

func _spawn_boss() -> void:
    boss_spawned = true
    var boss_scene: PackedScene = preload("res://scenes/combat/boss/grey_line_conductor.tscn")
    var boss: Node2D = boss_scene.instantiate()
    boss.global_position = Vector2(1920, 300)
    enemies_container.add_child(boss)
    EventBus.boss_spawned.emit()
```

##### enemy_base.tscn 节点树

```
EnemyBase (CharacterBody2D)
├── visual (ColorRect)                    # 占位色块
├── collision_shape (CollisionShape2D)    # CircleShape2D
└── hitbox (Area2D)                       # 受击检测
    └── hitbox_collision (CollisionShape2D)
```

---

#### **子阶段 1.3：自动攻击系统 + 投射物**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `weapon_system.gd` | `game/scripts/combat/weapon_system.gd` | 自动瞄准+开火 |
| `projectile.gd` | `game/scripts/combat/projectile.gd` | 玩家投射物 |
| `enemy_projectile.tscn` | `game/scenes/combat/enemy_projectile.tscn` | 敌人子弹 |
| `player_projectile.tscn` | `game/scenes/combat/player_projectile.tscn` | 玩家子弹 |

##### WeaponSystem.gd

```gdscript
# weapon_system.gd — 挂载在 Player 节点下
extends Node2D

@export var base_attack_interval: float = 0.5
@export var base_damage: int = 10
@export var projectile_speed: float = 400.0
@export var attack_range: float = 500.0

var current_damage: int
var current_attack_interval: float
var attack_timer: float = 0.0
var multishot: int = 1
var pierce_count: int = 0

var projectile_scene: PackedScene = preload("res://scenes/combat/player_projectile.tscn")

func _ready() -> void:
    current_damage = base_damage
    current_attack_interval = base_attack_interval

func _process(delta: float) -> void:
    attack_timer -= delta
    if attack_timer <= 0:
        var target: Node2D = _find_nearest_enemy()
        if target:
            _shoot(target)
            attack_timer = current_attack_interval

func _find_nearest_enemy() -> Node2D:
    var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
    var nearest: Node2D = null
    var nearest_dist: float = attack_range
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        var dist: float = global_position.distance_to(enemy.global_position)
        if dist < nearest_dist:
            nearest_dist = dist
            nearest = enemy
    return nearest

func _shoot(target: Node2D) -> void:
    var base_dir: Vector2 = (target.global_position - global_position).normalized()
    var spread_angle: float = deg_to_rad(10.0)

    for i in range(multishot):
        var angle_offset: float = (i - (multishot - 1) / 2.0) * spread_angle
        var dir: Vector2 = base_dir.rotated(angle_offset)
        var proj: Area2D = projectile_scene.instantiate()
        proj.global_position = global_position
        proj.direction = dir
        proj.speed = projectile_speed
        proj.damage = current_damage
        proj.pierce_remaining = pierce_count
        get_tree().current_scene.get_node("projectiles").add_child(proj)
```

##### Projectile.gd（玩家子弹）

```gdscript
# projectile.gd — 玩家投射物
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: int = 10
var pierce_remaining: int = 0
var lifetime: float = 3.0

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    # 自动销毁计时器
    var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
    timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta
    # 边界外销毁
    var pos: Vector2 = global_position
    if pos.x < 0 or pos.x > 3840 or pos.y < 0 or pos.y > 2160:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("enemy") or body.is_in_group("boss"):
        body.take_damage(damage)
        if pierce_remaining <= 0:
            queue_free()
        else:
            pierce_remaining -= 1
```

##### player_projectile.tscn 节点树

```
PlayerProjectile (Area2D)
├── visual (ColorRect)   # 8×8 亮黄色小方块
└── collision_shape (CollisionShape2D)  # 8×8
```

##### enemy_projectile.tscn 节点树

```
EnemyProjectile (Area2D)
├── visual (ColorRect)   # 6×6 暗红色小方块
└── collision_shape (CollisionShape2D)  # 6×6
```

对应的敌人子弹脚本同理，方向为朝向玩家。

---

#### **子阶段 1.4：血量系统 + 伤害 + 死亡**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `health_component.gd` | `game/scripts/combat/health_component.gd` | （可选，逻辑内聚在 EnemyAI/PlayerController 即可） |
| `damage_number.gd` | `game/scripts/combat/damage_number.gd` | 伤害跳字（可选） |

##### 碰撞伤害

- 玩家 hitbox (Area2D) 检测到敌人 body 进入 → 玩家受到 `enemy.damage` 伤害
- 给玩家添加短暂无敌帧（0.3s），防止连续碰撞秒杀
- 敌人之间不互相碰撞检测

##### 玩家死亡

```gdscript
# 在 PlayerController 中
signal died

func _on_hitbox_body_entered(body: Node2D) -> void:
    if body.is_in_group("enemy") and invincible_timer <= 0:
        if body.get("contact_damage"):
            take_damage(body.damage)
            invincible_timer = 0.3

func _process(delta: float) -> void:
    if invincible_timer > 0:
        invincible_timer -= delta
        visual.modulate.a = 0.5 + sin(Time.get_ticks_msec() * 0.03) * 0.5
    else:
        visual.modulate.a = 1.0
```

##### 伤害跳字（可选，提升反馈感）

```gdscript
# damage_number.gd
extends Label

func _ready() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "position", position + Vector2(0, -50), 0.8)
    tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8)
    tween.tween_callback(queue_free)
```

---

#### **子阶段 1.5：经验球 + 经验条 + 升级检测**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `experience_orb.gd` | `game/scripts/combat/experience_orb.gd` | 经验球 |
| `experience_orb.tscn` | `game/scenes/combat/experience_orb.tscn` | 经验球场景 |

##### experience_orb.tscn 节点树

```
ExperienceOrb (Area2D)
├── visual (ColorRect)       # 10×10 绿色小方块
├── collision_shape (CollisionShape2D)  # radius=10
└── magnet_area (Area2D)     # 被吸附范围
    └── magnet_collision (CollisionShape2D)  # radius=80
```

##### ExperienceOrb.gd

```gdscript
# experience_orb.gd
extends Area2D

@export var experience_amount: int = 10
@export var pickup_speed: float = 300.0
@export var magnet_range: float = 80.0
@export var lifetime: float = 30.0

var being_picked_up: bool = false
var target: Node2D = null

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)
    var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
    timer.timeout.connect(_fade_out)

func _physics_process(delta: float) -> void:
    if being_picked_up and is_instance_valid(target):
        var dir: Vector2 = (target.global_position - global_position).normalized()
        global_position += dir * pickup_speed * delta

func _on_area_entered(area: Area2D) -> void:
    # Player 的 pickup_area 进入磁吸范围
    if area.get_parent().is_in_group("player"):
        being_picked_up = true
        target = area.get_parent()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        body.add_experience(experience_amount)
        EventBus.experience_collected.emit(experience_amount)
        queue_free()

func _fade_out() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    tween.tween_callback(queue_free)
```

##### 经验条 UI（HUD 的一部分）

在 HUD 场景中：

```
XPBar (Control)
├── background (ColorRect)     # 深色底
├── fill (ColorRect)           # 绿色填充
└── level_label (Label)        # "Lv.1"
```

```gdscript
# 在 HUDController 中响应经验变化
func _on_experience_collected(amount: int) -> void:
    # 更新经验条
    pass  # 具体逻辑见 HUD 部分
```

---

#### **子阶段 1.6：技能系统 + 三选一 UI**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `skill_system.gd` | `game/scripts/combat/skill_system.gd` | 技能管理器 |
| `skills.json` | `game/data/skills/skills.json` | 技能数据 |
| `level_up_panel.tscn` | `game/scenes/ui/level_up_panel.tscn` | 三选一面板 |
| `level_up_panel.gd` | `game/scripts/ui/level_up_panel.gd` | 面板逻辑 |

##### skills.json（5 个基础技能）

```json
{
  "red_talisman_pulse": {
    "id": "red_talisman_pulse",
    "name_cn": "红符脉冲",
    "name_en": "Red Talisman Pulse",
    "description_cn": "投射物穿透 +1 名敌人",
    "description_en": "Projectiles pierce +1 enemy",
    "type": "passive",
    "max_tier": 2,
    "tiers": [
      {"pierce_bonus": 1, "damage_mult": 1.0},
      {"pierce_bonus": 2, "damage_mult": 1.2}
    ]
  },
  "azure_talisman_chain": {
    "id": "azure_talisman_chain",
    "name_cn": "青符锁链",
    "name_en": "Azure Talisman Chain",
    "description_cn": "每隔 5 秒连锁闪电弹跳 3 次",
    "description_en": "Every 5s, chain lightning bounces 3 times",
    "type": "active_interval",
    "max_tier": 2,
    "tiers": [
      {"interval": 5.0, "bounces": 3, "damage": 15, "range": 200},
      {"interval": 4.0, "bounces": 5, "damage": 25, "range": 300}
    ]
  },
  "thunder_seal_array": {
    "id": "thunder_seal_array",
    "name_cn": "雷鸣符阵",
    "name_en": "Thunder Seal Array",
    "description_cn": "每隔 8 秒在身边释放雷电环",
    "description_en": "Every 8s, release a lightning ring around you",
    "type": "active_interval",
    "max_tier": 2,
    "tiers": [
      {"interval": 8.0, "damage": 25, "radius": 150},
      {"interval": 6.0, "damage": 40, "radius": 220}
    ]
  },
  "will_o_wisp_drone": {
    "id": "will_o_wisp_drone",
    "name_cn": "鬼火无人机",
    "name_en": "Will-o-Wisp Drone",
    "description_cn": "召唤无人机自动攻击附近敌人",
    "description_en": "Summon a drone that auto-attacks nearby enemies",
    "type": "summon",
    "max_tier": 2,
    "tiers": [
      {"count": 1, "damage": 8, "attack_interval": 1.0, "range": 250},
      {"count": 2, "damage": 12, "attack_interval": 0.7, "range": 350}
    ]
  },
  "firewall_barrier": {
    "id": "firewall_barrier",
    "name_cn": "防火墙障",
    "name_en": "Firewall Barrier",
    "description_cn": "每隔 15 秒生成护盾，持续 3 秒",
    "description_en": "Every 15s, gain a shield for 3s",
    "type": "active_interval",
    "max_tier": 2,
    "tiers": [
      {"interval": 15.0, "duration": 3.0},
      {"interval": 10.0, "duration": 5.0}
    ]
  }
}
```

##### SkillSystem.gd

```gdscript
# skill_system.gd — 挂载在 Player 节点下
extends Node2D

var acquired_skills: Dictionary = {}    # skill_id → current_tier (1-based)
var skill_data: Dictionary = {}
var cooldown_timers: Dictionary = {}    # skill_id → remaining time

# 子节点
var drone_container: Node2D
var drone_scene: PackedScene = preload("res://scenes/combat/drone.tscn")

# 引用
@onready var weapon: WeaponSystem = $"../weapon_system"
@onready var player: CharacterBody2D = $".."

func _ready() -> void:
    skill_data = DataLoader.load_json("res://data/skills/skills.json")

func _process(delta: float) -> void:
    _process_interval_skills(delta)

func acquire_skill(skill_id: String) -> void:
    if not acquired_skills.has(skill_id):
        acquired_skills[skill_id] = 1
        cooldown_timers[skill_id] = 0.0
    else:
        var current_tier: int = acquired_skills[skill_id]
        var max_tier: int = skill_data[skill_id].max_tier
        if current_tier < max_tier:
            acquired_skills[skill_id] = current_tier + 1
        # 已达最大等级时不执行

    _apply_skill_effect(skill_id)
    EventBus.skill_acquired.emit(skill_id, acquired_skills[skill_id])

func _apply_skill_effect(skill_id: String) -> void:
    var tier: int = acquired_skills[skill_id]
    var tier_data: Dictionary = skill_data[skill_id].tiers[tier - 1]
    var type: String = skill_data[skill_id].type

    match skill_id:
        "red_talisman_pulse":
            weapon.pierce_count += tier_data.pierce_bonus
            weapon.current_damage = int(weapon.base_damage * tier_data.damage_mult)

        "azure_talisman_chain":
            # 计时器触发
            pass  # _process_interval_skills 中处理

        "thunder_seal_array":
            pass

        "will_o_wisp_drone":
            _spawn_drones(tier_data.count, tier_data.damage, tier_data.attack_interval, tier_data.range)

        "firewall_barrier":
            pass

func _process_interval_skills(delta: float) -> void:
    for skill_id in acquired_skills:
        var tier: int = acquired_skills[skill_id]
        var tier_data: Dictionary = skill_data[skill_id].tiers[tier - 1]
        var type: String = skill_data[skill_id].type

        if type != "active_interval":
            continue

        if not cooldown_timers.has(skill_id):
            cooldown_timers[skill_id] = 0.0

        cooldown_timers[skill_id] -= delta
        if cooldown_timers[skill_id] <= 0:
            match skill_id:
                "azure_talisman_chain":
                    _trigger_chain_lightning(tier_data)
                "thunder_seal_array":
                    _trigger_thunder_ring(tier_data)
                "firewall_barrier":
                    _trigger_shield(tier_data)
            cooldown_timers[skill_id] = tier_data.interval

func _trigger_chain_lightning(data: Dictionary) -> void:
    var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
    enemies.sort_custom(func(a, b): return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position))
    var bounced: int = 0
    var current_pos: Vector2 = player.global_position
    var hit_enemies: Array[Node2D] = []
    for enemy in enemies:
        if enemy in hit_enemies:
            continue
        if current_pos.distance_to(enemy.global_position) > data.range:
            continue
        enemy.take_damage(data.damage)
        hit_enemies.append(enemy)
        current_pos = enemy.global_position
        bounced += 1
        if bounced >= data.bounces:
            break
    # TODO: 画出闪电视觉效果（Line2D，瞬时）

func _trigger_thunder_ring(data: Dictionary) -> void:
    # AOE 伤害
    var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
    for enemy in enemies:
        if player.global_position.distance_to(enemy.global_position) <= data.radius:
            enemy.take_damage(data.damage)
    # TODO: 视觉效果（Circle 闪现）

func _trigger_shield(data: Dictionary) -> void:
    player.invincible = true
    var timer: SceneTreeTimer = get_tree().create_timer(data.duration)
    timer.timeout.connect(func(): player.invincible = false)
    # TODO: 视觉反馈（蓝色光环）

func _spawn_drones(count: int, damage: int, interval: float, range_val: float) -> void:
    # 移除旧无人机
    for child in drone_container.get_children():
        child.queue_free()
    for i in range(count):
        var drone: Node2D = drone_scene.instantiate()
        drone.damage = damage
        drone.attack_interval = interval
        drone.attack_range = range_val
        drone.orbit_angle = (TAU / count) * i
        drone.orbit_radius = 80
        drone.orbit_speed = 2.0
        drone.target_player = player
        drone_container.add_child(drone)
```

##### LevelUpPanel.gd

```gdscript
# level_up_panel.gd — 三选一技能面板
extends CanvasLayer

@onready var card_container: HBoxContainer = $panel/vbox/cards
@onready var title_label: Label = $panel/vbox/title

var skill_card_scene: PackedScene = preload("res://scenes/ui/skill_card.tscn")
var available_choices: Array[String] = []
var skill_data: Dictionary = {}
var acquired_skills: Dictionary = {}

func _ready() -> void:
    visible = false
    skill_data = DataLoader.load_json("res://data/skills/skills.json")
    EventBus.combat_paused.connect(_on_combat_paused)

func _on_combat_paused() -> void:
    # 只有当是因为升级触发的暂停才显示
    await get_tree().process_frame
    if GameManager.current_state != GameManager.GameState.COMBAT_PAUSED:
        return
    _populate_choices()
    visible = true

func _populate_choices() -> void:
    # 清空旧卡片
    for child in card_container.get_children():
        child.queue_free()

    # 随机选 3 个技能（偏向未获得的、低等级的）
    var skills: Array = skill_data.keys()
    skills.shuffle()
    available_choices.clear()
    for skill_id in skills:
        if available_choices.size() >= 3:
            break
        if not acquired_skills.has(skill_id):
            available_choices.append(skill_id)
        elif acquired_skills[skill_id] < skill_data[skill_id].max_tier:
            available_choices.append(skill_id)

    # 补足 3 个（全满级时）
    while available_choices.size() < 3:
        available_choices.append(skills[randi() % skills.size()])

    # 创建卡片
    for i in range(3):
        var card: Control = skill_card_scene.instantiate()
        card.skill_id = available_choices[i]
        card.skill_data = skill_data[available_choices[i]]
        card.current_tier = acquired_skills.get(available_choices[i], 0)
        card.selected.connect(_on_skill_selected)
        card.index = i + 1
        card_container.add_child(card)

func _on_skill_selected(skill_id: String) -> void:
    acquired_skills[skill_id] = acquired_skills.get(skill_id, 0) + 1
    visible = false
    EventBus.request_resume.emit()
```

##### LevelUpPanel.tscn 节点树

```
LevelUpPanel (CanvasLayer)
└── panel (Panel) [anchored center, 800×400]
    └── vbox (VBoxContainer)
        ├── title (Label) "选择一项升级"
        └── cards (HBoxContainer)
            ├── SkillCard1
            ├── SkillCard2
            └── SkillCard3
```

##### SkillCard.tscn 节点树

```
SkillCard (Panel) [custom min size 200×300]
└── vbox (VBoxContainer)
    ├── icon (ColorRect) [80×80, 技能颜色]
    ├── name_label (Label) [技能名]
    ├── desc_label (Label) [描述，自动换行]
    └── key_hint (Label) "按 1/2/3 选择"
```

##### SkillCard.gd

```gdscript
# skill_card.gd
extends Panel

signal selected(skill_id: String)

var skill_id: String = ""
var skill_data: Dictionary = {}
var current_tier: int = 0
var index: int = 1

@onready var name_label: Label = $vbox/name_label
@onready var desc_label: Label = $vbox/desc_label
@onready var key_hint: Label = $vbox/key_hint

func _ready() -> void:
    name_label.text = skill_data.name_cn
    key_hint.text = "按 %d 选择" % index
    if current_tier == 0:
        desc_label.text = skill_data.description_cn
    else:
        desc_label.text = skill_data.description_cn + "\n（升级至 Tier %d）" % (current_tier + 1)
    gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        selected.emit(skill_id)

func _input(event: InputEvent) -> void:
    if visible and event is InputEventKey and event.pressed:
        if event.keycode == KEY_1 and index == 1:
            selected.emit(skill_id)
        elif event.keycode == KEY_2 and index == 2:
            selected.emit(skill_id)
        elif event.keycode == KEY_3 and index == 3:
            selected.emit(skill_id)
```

注意：键盘选择在 LevelUpPanel 统管更合理，SkillCard 单独监听会导致重复触发。建议键盘输入统一在 LevelUpPanel 的 `_input` 中处理。

---

#### **子阶段 1.7：Boss 战**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `grey_line_conductor.tscn` | `game/scenes/combat/boss/grey_line_conductor.tscn` | Boss 场景 |
| `grey_line_conductor.gd` | `game/scripts/combat/boss/grey_line_conductor.gd` | Boss AI |

##### grey_line_conductor.tscn 节点树

```
GreyLineConductor (CharacterBody2D) [group="boss"]
├── visual (ColorRect)          # 120×120 灰色大矩形
├── collision_shape (CollisionShape2D)  # 60×60
├── hitbox (Area2D)
│   └── hitbox_collision (CollisionShape2D)
├── boss_hp_bar (ProgressBar)   # 头顶血条
└── attack_indicators (Node2D)  # 攻击预警区域
```

##### Boss 数据

| 属性 | 值 |
|------|-----|
| HP | 500 |
| Move Speed | 100 |
| Contact Damage | 30 |
| Phase 1 (100%-60%) | 票钳冲刺 + 召唤乘客 |
| Phase 2 (60%-30%) | + 广播静态 |
| Phase 3 (30%-0%) | + 最后一站（狂怒） |

##### GreyLineConductor.gd

```gdscript
# grey_line_conductor.gd
extends CharacterBody2D

@export var max_hp: int = 500
@export var move_speed: float = 100.0

var current_hp: int
var phase: int = 1
var attack_timer: float = 0.0

# 各技能冷却
var ticket_punch_cooldown: float = 3.0
var ticket_punch_timer: float = 0.0
var summon_cooldown: float = 8.0
var summon_timer: float = 5.0    # 初始延迟
var broadcast_cooldown: float = 6.0
var broadcast_timer: float = 0.0
var enraged: bool = false

@onready var player: CharacterBody2D = $"../../player"
@onready var hp_bar: ProgressBar = $boss_hp_bar

func _ready() -> void:
    current_hp = max_hp
    hp_bar.max_value = max_hp
    hp_bar.value = current_hp

func _physics_process(delta: float) -> void:
    if not is_instance_valid(player):
        return

    _update_phase()
    _update_cooldowns(delta)
    _chase_player()
    move_and_slide()

func _update_phase() -> void:
    var hp_percent: float = float(current_hp) / float(max_hp)
    if hp_percent <= 0.3:
        phase = 3
        if not enraged:
            enraged = true
            move_speed *= 1.5
            ticket_punch_cooldown *= 0.7
            visual.color = Color.DARK_RED
    elif hp_percent <= 0.6:
        phase = 2

func _update_cooldowns(delta: float) -> void:
    ticket_punch_timer -= delta
    summon_timer -= delta
    broadcast_timer -= delta

    # 票钳冲刺
    if ticket_punch_timer <= 0:
        _ticket_punch()
        ticket_punch_timer = ticket_punch_cooldown

    # 召唤乘客
    if summon_timer <= 0:
        _summon_passengers()
        summon_timer = summon_cooldown

    # 广播静态（Phase 2+）
    if phase >= 2 and broadcast_timer <= 0:
        _broadcast_static()
        broadcast_timer = broadcast_cooldown

func _chase_player() -> void:
    var dir: Vector2 = (player.global_position - global_position).normalized()
    velocity = dir * move_speed

func _ticket_punch() -> void:
    # 蓄力 0.5s → 冲刺 300px，路径上接触伤害翻倍
    var charge_pos: Vector2 = global_position
    var dash_dir: Vector2 = (player.global_position - global_position).normalized()

    # 预警指示器
    var indicator: ColorRect = ColorRect.new()
    indicator.color = Color(1, 0, 0, 0.3)
    indicator.size = Vector2(300, 60)
    indicator.global_position = charge_pos + dash_dir * 150 - Vector2(150, 30)
    indicator.rotation = dash_dir.angle()
    get_parent().add_child(indicator)

    var tween: Tween = create_tween()
    tween.tween_interval(0.5)
    tween.tween_callback(func():
        indicator.queue_free()
        # 冲刺
        var dash_tween: Tween = create_tween()
        dash_tween.tween_property(self, "global_position", charge_pos + dash_dir * 300, 0.3)
    )

func _summon_passengers() -> void:
    for i in range(2 + phase):
        var enemy: CharacterBody2D = enemy_scene.instantiate()
        enemy.enemy_id = "empty_seat_passenger"
        enemy.global_position = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
        get_parent().add_child(enemy)

func _broadcast_static() -> void:
    # AOE 范围减速 + 伤害
    var radius: float = 250.0
    var indicator: ColorRect = ColorRect.new()
    indicator.color = Color(0.5, 0, 0.5, 0.3)
    indicator.size = Vector2(radius * 2, radius * 2)
    indicator.global_position = global_position - Vector2(radius, radius)
    get_parent().add_child(indicator)

    var tween: Tween = create_tween()
    tween.tween_interval(0.8)
    tween.tween_callback(func():
        indicator.queue_free()
        if player.global_position.distance_to(global_position) <= radius:
            player.take_damage(20)
            player.move_speed *= 0.5
            get_tree().create_timer(2.0).timeout.connect(func(): player.move_speed *= 2.0)
    )

func take_damage(amount: int) -> void:
    current_hp -= amount
    hp_bar.value = current_hp
    EventBus.boss_health_changed.emit(current_hp, max_hp)
    # 受伤闪烁
    var flash_tween: Tween = create_tween()
    flash_tween.tween_property(visual, "modulate", Color.WHITE, 0.1)
    flash_tween.tween_property(visual, "modulate", Color.GRAY, 0.1)
    if current_hp <= 0:
        _die()

func _die() -> void:
    EventBus.boss_defeated.emit()
    # 死亡特效
    var tween: Tween = create_tween()
    tween.tween_property(visual, "modulate:a", 0.0, 0.5)
    tween.tween_callback(queue_free)
```

---

#### **子阶段 1.8：胜利/失败结算面板**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `result_panel.tscn` | `game/scenes/ui/result_panel.tscn` | 结算面板 |
| `result_panel.gd` | `game/scripts/ui/result_panel.gd` | 结算逻辑 |

##### result_panel.tscn 节点树

```
ResultPanel (CanvasLayer) [visible=false]
└── panel (Panel) [anchored center, 500×400]
    └── vbox (VBoxContainer)
        ├── title_label (Label) "任务完成" / "任务失败"
        ├── stats_label (Label) "击杀: X | 等级: Y | 存活: Zs"
        ├── spacer (Control)
        ├── restart_button (Button) "重新挑战"
        └── quit_button (Button) "返回主菜单"
```

##### ResultPanel.gd

```gdscript
# result_panel.gd
extends CanvasLayer

@onready var title_label: Label = $panel/vbox/title_label
@onready var stats_label: Label = $panel/vbox/stats_label
@onready var panel: Panel = $panel

var kill_count: int = 0
var final_level: int = 1
var survival_time: float = 0.0

func _ready() -> void:
    visible = false
    EventBus.combat_ended.connect(_on_combat_ended)
    EventBus.enemy_killed.connect(func(_t): kill_count += 1)
    EventBus.player_leveled_up.connect(func(lv): final_level = lv)

func _on_combat_ended(victory: bool) -> void:
    if victory:
        title_label.text = "任务完成"
        title_label.add_theme_color_override("font_color", Color.GREEN)
    else:
        title_label.text = "任务失败"
        title_label.add_theme_color_override("font_color", Color.RED)

    stats_label.text = "击杀: %d | 等级: %d" % [kill_count, final_level]
    visible = true

func _on_restart_pressed() -> void:
    EventBus.request_restart.emit()

func _on_quit_pressed() -> void:
    EventBus.request_main_menu.emit()
```

---

#### **子阶段 1.9：HUD**

##### 文件

| 文件 | 路径 | 说明 |
|------|------|------|
| `hud.tscn` | `game/scenes/ui/hud.tscn` | 游戏内 HUD |
| `hud_controller.gd` | `game/scripts/ui/hud_controller.gd` | HUD 逻辑 |

##### hud.tscn 节点树

```
HUD (CanvasLayer)
├── hp_panel (PanelContainer) [top-left]
│   ├── hp_label (Label) "HP"
│   ├── hp_bar (ProgressBar)
│   └── hp_text (Label) "100/100"
├── xp_panel (PanelContainer) [bottom-center]
│   ├── xp_label (Label) "Lv.1"
│   ├── xp_bar (ProgressBar)
│   └── xp_text (Label) "0/30"
├── timer_label (Label) [top-center]
├── boss_hp (ProgressBar) [top-center, hidden until boss spawns]
└── skill_icons (HBoxContainer) [bottom-right]
```

##### HUDController.gd

```gdscript
# hud_controller.gd
extends CanvasLayer

@onready var hp_bar: ProgressBar = $hp_panel/hp_bar
@onready var hp_text: Label = $hp_panel/hp_text
@onready var xp_bar: ProgressBar = $xp_panel/xp_bar
@onready var xp_text: Label = $xp_panel/xp_text
@onready var level_label: Label = $xp_panel/xp_label
@onready var timer_label: Label = $timer_label
@onready var boss_hp: ProgressBar = $boss_hp
@onready var skill_icons: HBoxContainer = $skill_icons

func _ready() -> void:
    EventBus.player_health_changed.connect(_on_player_health_changed)
    EventBus.player_leveled_up.connect(_on_player_level_up)
    EventBus.boss_spawned.connect(func(): boss_hp.visible = true)
    EventBus.boss_health_changed.connect(_on_boss_health_changed)
    EventBus.combat_started.connect(func(): boss_hp.visible = false)

func _process(_delta: float) -> void:
    if GameManager.current_state == GameManager.GameState.COMBAT_ACTIVE:
        var time_sec: float = $"../../spawn_director".game_timer
        timer_label.text = "%.0fs" % time_sec

func _on_player_health_changed(current: int, max_hp: int) -> void:
    hp_bar.max_value = max_hp
    hp_bar.value = current
    hp_text.text = "%d/%d" % [current, max_hp]
    if float(current) / float(max_hp) < 0.3:
        hp_text.add_theme_color_override("font_color", Color.RED)
    else:
        hp_text.add_theme_color_override("font_color", Color.WHITE)

func _on_player_level_up(new_level: int) -> void:
    level_label.text = "Lv.%d" % new_level

func _on_boss_health_changed(current: int, max_hp: int) -> void:
    boss_hp.max_value = max_hp
    boss_hp.value = current
```

---

### 3.5 数据加载器（DataLoader）

```gdscript
# data_loader.gd — 静态 JSON 加载工具
extends Node

static func load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("DataLoader: file not found: %s" % path)
        return {}
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    var text: String = file.get_as_text()
    var json: JSON = JSON.new()
    var error: Error = json.parse(text)
    if error != OK:
        push_error("DataLoader: JSON parse error: %s" % json.get_error_message())
        return {}
    return json.data
```

### 3.6 Phase 1 整体文件清单（按创建顺序）

| 序号 | 文件 | 依赖 |
|------|------|------|
| 1 | `scripts/core/event_bus.gd` | 无 |
| 2 | `scripts/core/game_manager.gd` | EventBus |
| 3 | `scripts/core/data_loader.gd` | 无 |
| 4 | `scenes/main/main.tscn` + `main.gd` | GameManager |
| 5 | `data/enemies/enemies.json` | 无 |
| 6 | `data/skills/skills.json` | 无 |
| 7 | `scenes/combat/combat.tscn` | 无 |
| 8 | `scenes/combat/player.tscn` | 无 |
| 9 | `scripts/combat/player_controller.gd` | EventBus |
| 10 | `scripts/combat/weapon_system.gd` | Player |
| 11 | `scenes/combat/player_projectile.tscn` + `projectile.gd` | WeaponSystem |
| 12 | `scenes/combat/enemies/enemy_base.tscn` + `enemy_ai.gd` | EnemyData |
| 13 | `scenes/combat/enemy_projectile.tscn` | Enemy |
| 14 | `scripts/combat/spawn_director.gd` | Enemy, Player |
| 15 | `scripts/combat/experience_orb.gd` + tscn | Player |
| 16 | `scripts/combat/skill_system.gd` | Skills.json |
| 17 | `scripts/combat/drone.tscn` + `drone.gd` | SkillSystem |
| 18 | `scenes/ui/skill_card.tscn` + `skill_card.gd` | Skills.json |
| 19 | `scenes/ui/level_up_panel.tscn` + `level_up_panel.gd` | SkillCard |
| 20 | `scenes/ui/hud.tscn` + `hud_controller.gd` | EventBus |
| 21 | `scenes/combat/boss/grey_line_conductor.tscn` + `.gd` | Enemy, Player |
| 22 | `scenes/ui/result_panel.tscn` + `result_panel.gd` | EventBus |

---

## 4. Phase 2：案件系统

> **依赖：Phase 1 完成**

### 4.1 目标

战斗不再孤立运行，而是从"案件"进入。案件定义目标、敌人类型、Boss、地图机制、奖励。

### 4.2 新增/修改文件

| 文件 | 操作 | 说明 |
|------|------|------|
| `data/cases/approved_cases.json` | 新建 | 案件数据（硬编码，非 harvester 导出） |
| `scripts/office/case_manager.gd` | 新建 | 案件加载、目标追踪、完成判断 |
| `scenes/ui/case_briefing.tscn` + `.gd` | 新建 | 案件简报面板（任务前） |
| `scripts/combat/objective_tracker.gd` | 新建 | 战斗中目标进度追踪 |
| `hud_controller.gd` | 修改 | 添加目标进度显示 |
| `result_panel.gd` | 修改 | 根据目标完成度判断成败 |

### 4.3 案件数据格式

```json
{
  "case_id": "GLM-001",
  "title_cn": "灰线末班车",
  "title_en": "The Grey Line Last Train",
  "display_name": "灰线末班车（The Grey Line Last Train）",
  "district": "灰线地铁（Grey Line Metro）",
  "threat_level": 2,
  "anomaly_type": ["空间异常", "广播感染", "乘客替换"],
  "briefing": "凌晨 2:17，新沪市地铁系统突然显示一列不应存在的灰色线路...",
  "objectives": [
    {"type": "collect", "target": "time_ticket", "count": 3, "text": "找到三张时间票"},
    {"type": "disable", "target": "broadcast_device", "count": 4, "text": "关闭四个异常广播器"},
    {"type": "defeat_boss", "target": "grey_line_conductor", "text": "击败灰线列车员"}
  ],
  "boss_id": "grey_line_conductor",
  "reward_items": ["broken_monthly_pass", "low_frequency_broadcast_module"],
  "archive_text": "请不要查询终点站。如果广播中出现你的名字，不要回应。即使车门没有打开，也不要试图下车。"
}
```

### 4.4 CaseManager 职责

- 加载 `approved_cases.json`
- 提供当前选中案件的数据
- 案件简报展示
- 战斗开始前注入案件配置到 SpawnDirector / Boss

### 4.5 地图特殊机制（按案件区分）

案件数据中增加 `map_modifiers`：

```json
"map_modifiers": [
  {"type": "periodic_darkness", "interval": 90, "duration": 15, "description": "每90秒灯光熄灭15秒"},
  {"type": "broadcast_paranoia", "threshold_distance": 200, "slowness": 0.5, "description": "靠近广播器时移动速度减半"}
]
```

### 4.6 验收标准

- [ ] 可从案件列表选择案件进入战斗
- [ ] 战斗前显示案件简报
- [ ] 战斗中 HUD 显示案件目标进度
- [ ] 完成全部目标后触发 Boss（目标型触发，替换时间型触发）
- [ ] 案件完成/失败后正确结算

---

## 5. Phase 3：事务所经营系统

> **依赖：Phase 2 完成**

### 5.1 目标

添加事务所主场景，包含案件终端、档案墙、升级台、存档管理。实现完整游戏循环。

### 5.2 新增文件

| 文件 | 说明 |
|------|------|
| `scenes/office/office_main.tscn` | 事务所主场景 |
| `scripts/office/office_main.gd` | 事务所逻辑 |
| `scenes/office/case_terminal.tscn` + `.gd` | 案件终端（选择案件） |
| `scenes/office/archive_wall.tscn` + `.gd` | 档案墙（查看已结案件） |
| `scenes/office/upgrade_bench.tscn` + `.gd` | 升级台（永久强化） |
| `scripts/core/save_manager.gd` | 存档管理 |
| `data/characters/characters.json` | 角色数据（至少 3 个） |
| `data/skills/relics.json` | 遗物数据 |
| `data/localization/zh_cn.json` | 中文本地化 |
| `data/localization/en.json` | 英文本地化 |

### 5.3 游戏循环

```
事务所主场景
  ├─ 案件终端 → 选案件 + 选角色 + 装备遗物
  ├─ 战斗场景（Phase 2）
  ├─ 结算 → 返回事务所
  ├─ 档案墙 → 查看已结案件文本
  └─ 升级台 → 永久数值提升（消耗资源）
```

### 5.4 SaveManager

- 存档格式：JSON 文件存于 `user://save.json`
- 包含：已解锁角色、永久升级等级、已结案件 ID 列表、资源数量

### 5.5 验收标准

- [ ] 事务所场景可正常进入和交互
- [ ] 案件终端可浏览和选择案件
- [ ] 存档可保存和读取（退出重进数据不丢失）
- [ ] 档案墙显示已结案件的档案文本
- [ ] 升级台可消耗资源提升永久属性

---

## 6. Phase 4：怪谈采集器 MVP

> **依赖：Phase 3 完成**

### 6.1 目标

建立 `harvester/` 子项目，实现从灵异故事素材到可审批案件草案的完整流水线。

### 6.2 系统流水线

```
搜索 Agent → 来源 URL
    ↓
提取 Agent → 主题（地点/异常类型/禁忌规则/恐怖点/游戏潜力）
    ↓
审核 Agent → 风险标签 + 审核决定
    ↓
生成 Agent → 案件草案（含 objectives/boss/mechanics）
    ↓
风格统一 Agent → 统一文风
    ↓
人工审核 → approved / rejected / rewrite_needed
    ↓ (仅 approved)
导出 Agent → JSON → game/data/cases/approved_cases.json
```

### 6.3 数据库表（MySQL `anomaly_harvester`）

```sql
CREATE TABLE sources (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(512) NOT NULL,
    url TEXT NOT NULL,
    url_hash CHAR(64) GENERATED ALWAYS AS (SHA2(url, 256)) STORED,
    source_type VARCHAR(64),
    language VARCHAR(32),
    snippet TEXT,
    raw_text MEDIUMTEXT,
    license_status VARCHAR(64) DEFAULT 'unknown',
    collected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    risk_level TINYINT DEFAULT 0,
    UNIQUE KEY uq_source_url_hash (url_hash)
);

CREATE TABLE motifs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    source_id BIGINT NOT NULL,
    location VARCHAR(255),
    time_period VARCHAR(255),
    anomaly_type JSON,
    core_motif JSON,
    taboo_rule TEXT,
    horror_point TEXT,
    game_potential TEXT,
    risk_tags JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (source_id) REFERENCES sources(id)
);

CREATE TABLE case_drafts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    case_id VARCHAR(64) UNIQUE,
    title_cn VARCHAR(255) NOT NULL,
    title_en VARCHAR(255),
    district VARCHAR(255),
    threat_level TINYINT,
    anomaly_type JSON,
    briefing TEXT,
    objectives JSON,
    boss VARCHAR(255),
    boss_mechanics JSON,
    reward_items JSON,
    archive_text TEXT,
    source_ids JSON,
    similarity_note TEXT,
    review_status ENUM('pending','approved','rejected','rewrite_needed') DEFAULT 'pending',
    reviewer_note TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE exports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    export_name VARCHAR(255),
    file_path TEXT,
    case_count INT,
    exported_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 6.4 FastAPI 目录结构

```
harvester/
├── app/
│   ├── main.py                 # FastAPI 入口 + /health
│   ├── config.py               # 环境配置
│   ├── database.py             # SQLAlchemy 连接
│   ├── models/
│   │   ├── __init__.py
│   │   ├── source.py
│   │   ├── motif.py
│   │   ├── case_draft.py
│   │   └── export.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── source.py
│   │   ├── motif.py
│   │   ├── case_draft.py
│   │   └── export.py
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── sources.py
│   │   ├── motifs.py
│   │   ├── cases.py
│   │   ├── exports.py
│   │   └── admin.py            # 人工审核后台
│   ├── services/
│   │   ├── search_service.py     # Google Search API / 手动导入
│   │   ├── source_fetcher.py     # 抓取全文
│   │   ├── motif_extractor.py    # LLM 提取主题
│   │   ├── risk_filter.py        # LLM 风险评估
│   │   ├── case_generator.py     # LLM 生成草案
│   │   ├── style_rewriter.py     # LLM 统一文风
│   │   └── exporter.py           # 导出 JSON
│   └── llm/
│       ├── provider_base.py      # 抽象基类
│       ├── deepseek_provider.py
│       ├── openai_provider.py
│       └── mock_provider.py      # 开发用 mock
├── prompts/
│   ├── extract_motif.md
│   ├── risk_review.md
│   ├── generate_case.md
│   └── rewrite_style.md
├── exports/
│   └── approved_cases.json       # 导出的最终文件
├── tests/
│   ├── test_search.py
│   ├── test_extractor.py
│   ├── test_risk.py
│   └── test_generator.py
├── requirements.txt
└── alembic.ini
```

### 6.5 验收标准

- [ ] FastAPI `/health` 返回 OK
- [ ] MySQL 可连接，Alembic 迁移成功
- [ ] Mock provider 下完整流水线跑通（搜索 → 提取 → 审核 → 生成 → 导出）
- [ ] `approved_cases.json` 可成功被游戏加载
- [ ] 人工审核后台可查看、批准、驳回、要求重写
- [ ] 重复 URL 正确去重

---

## 7. Phase 5：灰线地铁 MVP 发布

> **依赖：Phase 3 + Phase 4 完成**

### 7.1 交付物

- 1 个可玩角色
- 1 个案件集（灰线地铁 5 个案件）
- 12 个技能（5 基础 × 2 等级 + 扩展）
- 5 种敌人
- 10 个遗物
- itch.io 可玩版

### 7.2 内容清单

| 内容 | 数量 | 状态 |
|------|------|------|
| 角色 | 1（林锦） | 完整 |
| 案件 | GLM-001 ~ GLM-005 | 完整 |
| Boss | 灰线列车员、站台暗影、指路人、广播寄生体、逆行列车员 | 完整 |
| 敌人 | 5 种常规敌人 | 完整 |
| 技能 | 12 个（5 基础 + 扩展 + 进化） | 完整 |
| 遗物 | 10 个 | 完整 |
| 背景 | 地铁车厢、站台、通道、控制室 | 占位图 |
| 音效 | 攻击、技能、Boss、环境 | 占位/免费素材 |
| BGM | 战斗、Boss、事务所 | 免费素材 |

### 7.3 验收标准

- [ ] 游戏在 Windows PC 上稳定运行
- [ ] 5 个案件全部可完成
- [ ] 存档系统可靠
- [ ] 事务所经营循环完整
- [ ] itch.io 页面创建并上传可玩版
- [ ] 收集 5 人以上反馈

---

## 8. Phase 6：正式扩展与 Steam Demo

> **依赖：Phase 5 完成**

### 8.1 交付物

- 3 个可玩角色（林锦、徐招夜、白纸）
- 5 个案件集（灰线地铁 + 至少 4 个其他地区）
- 30+ 案件
- 8+ Boss
- 完整美术资源
- Steam 页面 + 正式 Demo

### 8.2 验收标准

- [ ] 游戏内容量满足 3-5 小时单局时长（全案件）
- [ ] 全部角色/技能/Boss 平衡可玩
- [ ] 美术和音效资源到位
- [ ] Steam 页面通过审核
- [ ] 正式 Demo 可下载

---

## 9. 附录 A：JSON Schema 完整定义

### 9.1 skills.json

```typescript
// 技能定义
interface Skill {
  id: string;               // snake_case 英文 ID
  name_cn: string;          // 中文显示名
  name_en: string;          // 英文显示名
  description_cn: string;   // 中文描述
  description_en: string;   // 英文描述
  type: "passive" | "active_interval" | "active_manual" | "summon" | "toggle";
  max_tier: number;         // 最大等级 (1-3)
  tiers: SkillTier[];       // 每级数据
  icon_color?: string;      // 占位图标颜色
}

interface SkillTier {
  // 通用字段
  damage_mult?: number;
  // 穿透
  pierce_bonus?: number;
  // 定时
  interval?: number;
  // 连锁
  bounces?: number;
  damage?: number;
  range?: number;
  // 召唤
  count?: number;
  attack_interval?: number;
  // 护盾
  duration?: number;
  // AOE
  radius?: number;
}
```

### 9.2 enemies.json

```typescript
interface Enemy {
  id: string;
  name_cn: string;
  name_en: string;
  hp: number;
  move_speed: number;
  damage: number;
  contact_damage: boolean;
  attack_range: number;       // 0 = 纯近战
  attack_cooldown: number;
  projectile_speed: number;   // 0 = 无投射物
  experience_drop: number;
  size: number;               // 占位矩形边长
  color: string;              // 占位颜色 (CSS color name)
  special?: "teleport" | "shield" | "split" | "explode" | null;
  special_cooldown?: number;
}
```

### 9.3 approved_cases.json

```typescript
interface Case {
  case_id: string;                 // 如 "GLM-001"
  title_cn: string;
  title_en: string;
  display_name: string;            // 含双语的显示名
  district: string;
  threat_level: number;            // 1-5
  anomaly_type: string[];
  briefing: string;
  objectives: Objective[];
  boss_id: string;
  reward_items: string[];          // 遗物 ID 列表
  archive_text: string;
  map_modifiers?: MapModifier[];
  source_inspiration: SourceRef[];
}

interface Objective {
  type: "collect" | "disable" | "defeat_boss" | "survive" | "escort";
  target: string;     // 目标实体 ID
  count: number;      // 需要完成次数
  text: string;       // 显示文本
}

interface MapModifier {
  type: string;        // "periodic_darkness" | "broadcast_paranoia" | ...
  interval?: number;
  duration?: number;
  description: string;
}

interface SourceRef {
  title: string;
  url: string;
  usage: string;       // "inspiration_only" | "adapted" | "public_domain"
}
```

### 9.4 save.json 存档格式

```typescript
interface SaveData {
  version: number;
  play_time_seconds: number;
  completed_cases: string[];           // case_id 列表
  unlocked_characters: string[];       // character_id 列表
  resources: {
    anomaly_essence: number;           // 异常精华（货币）
    broken_circuit: number;            // 破损回路（稀有货币）
  };
  permanent_upgrades: Record<string, number>;  // upgrade_id → level
  settings: {
    master_volume: number;
    music_volume: number;
    sfx_volume: number;
    language: "zh_cn" | "en";
  };
}
```

---

## 10. 附录 B：信号事件总线参考

### 完整信号清单

| 信号 | 参数 | 发出者 | 监听者 |
|------|------|--------|--------|
| `combat_started` | — | SpawnDirector | HUD, Player |
| `combat_ended` | `victory: bool` | GameManager | ResultPanel, SpawnDirector |
| `combat_paused` | — | GameManager | SpawnDirector, LevelUpPanel |
| `combat_resumed` | — | GameManager | SpawnDirector, LevelUpPanel |
| `player_health_changed` | `current: int, max_hp: int` | PlayerController | HUD |
| `player_died` | — | PlayerController | GameManager |
| `player_leveled_up` | `new_level: int` | PlayerController | HUD, LevelUpPanel |
| `enemy_spawned` | `enemy: Node2D` | SpawnDirector | — |
| `enemy_killed` | `type: String, pos: Vector2` | EnemyAI | ResultPanel |
| `boss_spawned` | — | SpawnDirector | HUD |
| `boss_health_changed` | `current: int, max_hp: int` | Boss | HUD |
| `boss_defeated` | — | Boss | GameManager |
| `experience_dropped` | `pos: Vector2, amount: int` | EnemyAI | XP Orb Spawner |
| `experience_collected` | `amount: int` | XP Orb | HUD, PlayerController |
| `skill_acquired` | `skill_id: String, tier: int` | SkillSystem | HUD (skill icons) |
| `request_pause` | — | PlayerController (level up) | GameManager |
| `request_resume` | — | LevelUpPanel | GameManager |
| `request_restart` | — | ResultPanel | GameManager |
| `request_main_menu` | — | ResultPanel | GameManager |

---

## 11. 附录 C：数值表

### 11.1 玩家基础数值

| 属性 | 值 | 公式 |
|------|-----|------|
| 最大 HP | 100 | — |
| 移动速度 | 200 px/s | — |
| 基础攻击力 | 10 | — |
| 攻击间隔 | 0.5s | — |
| 子弹速度 | 400 px/s | — |
| 攻击范围 | 500 px | — |
| 初始弹数 | 1 | — |
| 穿透数 | 0 | — |
| 无敌帧（受击后） | 0.3s | — |

### 11.2 升级经验

| 等级 | 所需经验 | 累计经验 |
|------|----------|----------|
| 1 → 2 | 30 | 30 |
| 2 → 3 | 40 | 70 |
| 3 → 4 | 50 | 120 |
| 4 → 5 | 60 | 180 |
| 5 → 6 | 70 | 250 |
| n → n+1 | 20 + n × 10 | — |

### 11.3 刷怪曲线

| 游戏时间 | 刷怪间隔 | 解锁敌人类型 |
|----------|----------|--------------|
| 0-30s | 3.0s | 空座乘客 |
| 30-60s | 2.5s | + 逆行客 |
| 60-90s | 2.0s | + 低频噪音影 |
| 90-120s | 1.5s | 全部 |
| 120s | — | Boss 出现 |

### 11.4 敌人数值

| 敌人 | HP | 速度 | 伤害 | 经验 |
|------|-----|------|------|------|
| 空座乘客 | 30 | 150 | 15 (碰撞) | 10 |
| 逆行客 | 40 | 120 | 25 (碰撞) | 15 |
| 低频噪音影 | 50 | 80 | 20 (远程) | 15 |

### 11.5 Boss 数值

| Boss | HP | 速度 | 接触伤害 |
|------|-----|------|----------|
| 灰线列车员 | 500 | 100 | 30 |
| → Phase 2 (<60%) | 500 | 100 | 30 (+ 广播静态) |
| → Phase 3 (<30%) | 500 | 150 | 30 (+ 狂怒加速) |

### 11.6 技能数值

| 技能 | Tier 1 | Tier 2 |
|------|--------|--------|
| 红符脉冲 | 穿透 +1, 伤害 ×1.0 | 穿透 +2, 伤害 ×1.2 |
| 青符锁链 | 5s 冷却, 弹跳 3, 伤害 15, 范围 200 | 4s, 弹跳 5, 伤害 25, 范围 300 |
| 雷鸣符阵 | 8s, 伤害 25, 半径 150 | 6s, 伤害 40, 半径 220 |
| 鬼火无人机 | 1 架, 伤害 8, 1s 攻速, 范围 250 | 2 架, 伤害 12, 0.7s, 范围 350 |
| 防火墙障 | 15s 冷却, 持续 3s | 10s, 持续 5s |

---

## 12. 附录 D：测试清单

### 12.1 Phase 1 手动测试

```
功能测试
├── [ ] F5 运行不崩溃
├── [ ] WASD 移动流畅，无卡顿
├── [ ] 摄像机跟随玩家
├── [ ] 玩家不能移出地图边界
├── [ ] 敌人随游戏时间刷出
├── [ ] 敌人追踪玩家
├── [ ] 低频噪音影在射程内停止并射击
├── [ ] 逆行客定时闪现到玩家身后
├── [ ] 玩家自动面向最近敌人
├── [ ] 子弹正确射出并消失于边界
├── [ ] 子弹击中敌人，敌人掉血
├── [ ] 敌人 HP 归零后死亡并掉落经验球
├── [ ] 经验球向玩家磁吸
├── [ ] 玩家拾取经验球后经验条上涨
├── [ ] 经验条满后暂停并弹出升级面板
├── [ ] 三选一面板显示 3 个不同技能
├── [ ] 选择技能后面板关闭，游戏继续
├── [ ] 技能效果正确（穿透/连锁/AOE/无人机/护盾）
├── [ ] 再次获得同一技能时升级而非重复
├── [ ] 120 秒后 Boss 出现
├── [ ] Boss 四种攻击模式正常工作
├── [ ] Boss HP 归零后显示胜利面板
├── [ ] 玩家 HP 归零后显示失败面板
├── [ ] 胜利/失败面板可重新开始
├── [ ] 胜利/失败面板可返回主菜单

性能测试
├── [ ] 屏幕上有 50+ 敌人时不掉帧（60fps）
├── [ ] 100+ 子弹同时存在不卡顿

边界测试
├── [ ] 所有敌人被杀死后刷新正常工作
├── [ ] 连续快速升级不崩溃
├── [ ] 所有技能满级后再升级正常处理
├── [ ] Boss 被秒杀不报错
├── [ ] 快速按下暂停/恢复不崩溃
```

### 12.2 Phase 2 手动测试

```
├── [ ] 案件简报正确显示
├── [ ] 案件目标在 HUD 中实时追踪
├── [ ] 地图特殊机制正确触发
├── [ ] 完成所有目标后 Boss 出现
├── [ ] 结算显示案件特有奖励
```

### 12.3 Phase 3 手动测试

```
├── [ ] 事务所场景加载正常
├── [ ] 案件终端可浏览案件列表
├── [ ] 选择不同案件进入不同战斗
├── [ ] 存档保存后退出重进数据恢复
├── [ ] 档案墙显示已完成案件
├── [ ] 升级台消耗资源提升属性
├── [ ] 不同角色可选
```

### 12.4 Phase 4 测试

```
├── [ ] /health 端点返回 200
├── [ ] 数据库表创建成功
├── [ ] Mock 搜索返回假数据
├── [ ] Mock 提取返回主题
├── [ ] Mock 审核返回风险标签
├── [ ] Mock 生成返回案件草案
├── [ ] 导出 JSON 格式符合游戏加载要求
├── [ ] 重复 URL 被去重
├── [ ] 审核状态流转正确
├── [ ] 真 API 调用正常（接入后）
```

---

## 13. 附录 E：AI 提示词模板

> 注：以下模板在 harvester 的 `prompts/` 目录中以 Markdown 文件形式存储。

### 13.1 主题提取（extract_motif.md）

```
你是《404 除灵事务所》的怪谈调查员。请从以下灵异故事素材中提取关键元素，
用于制作游戏案件。

要求：
- 只提取主题、氛围、结构，禁止复制原文
- 输出 JSON 格式

素材：
{source_text}

输出 JSON：
{
  "location": "地点（架空化，如'灰线地铁'而非真实站名）",
  "time_period": "时间背景",
  "anomaly_type": ["空间异常", "认知感染", "数字污染", "民俗失控" 等],
  "core_motif": {
    "entity": "核心异常实体",
    "rule": "异常行为的规则/禁忌",
    "trigger": "触发条件"
  },
  "taboo_rule": "如果存在禁忌规则",
  "horror_point": "最令人不安的点",
  "game_potential": "转化为游戏关卡的潜力评估（高/中/低）",
  "suggested_mechanics": ["建议的游戏机制"]
}
```

### 13.2 风险评估（risk_review.md）

```
你是《404 除灵事务所》的版权与伦理审核员。请审查以下素材和草案。

判断标准：
1. 是否直接复制原文？→ 否决
2. 是否涉及真实受害者/未破案件？→ 否决
3. 是否使用真实地址/校名/医院？→ 否决
4. 是否侵犯原作者版权？→ 否决
5. 是否仅为氛围借鉴？→ 通过
6. 是否适合游戏化？→ 考虑年龄分级

素材信息：
- 来源: {source_url}
- 执照状态: {license_status}
- 提取的主题: {motif}

请输出 JSON：
{
  "risk_level": 0-5,
  "risk_tags": ["copyright", "privacy", "real_violence", "minors", "etc"],
  "decision": "approved | rewrite_needed | rejected",
  "reason": "简要理由",
  "modification_suggestions": "如需修改，这里给建议"
}
```

### 13.3 案件生成（generate_case.md）

```
你是《404 除灵事务所》的案件设计师。请根据下面的主题生成一个完整的游戏案件数据包。

案件设计原则：
- 所有地名使用架空城市"新沪市"
- 目标类型: collect / disable / defeat_boss / survive / escort
- Boss 必须有至少 2 种攻击模式
- 威胁等级 1-5
- 档案文本应具有"记录体"风格，冷静而不失诡异

主题：
{extracted_motif}

风险标签：
{risk_tags}

请输出 JSON：
{
  "case_id": "自动生成（格式 AREA-序号）",
  "title_cn": "案件中文标题",
  "title_en": "English Case Title",
  "display_name": "中文（English）",
  "district": "所属区域",
  "threat_level": 1-5,
  "anomaly_type": ["异常类型"],
  "briefing": "案件简报，100-150 字",
  "objectives": [
    {"type": "collect|disable|defeat_boss|survive|escort", "target": "id", "count": N, "text": "显示文本"}
  ],
  "boss_id": "boss 的 snake_case ID",
  "boss_mechanics": {
    "name_cn": "Boss 中文名",
    "name_en": "Boss English Name",
    "description_cn": "Boss 描述",
    "phase_1": [{"name": "攻击名", "description": "描述", "damage": N, "cooldown": N}],
    "phase_2": [...],
    "phase_3": [...]
  },
  "reward_items": ["relic_id_1", "relic_id_2"],
  "archive_text": "游戏内档案文本，200-300 字",
  "map_modifiers": [
    {"type": "modifier_type", "description": "中文描述", "params": {}}
  ]
}
```

### 13.4 风格统一（rewrite_style.md）

```
你是《404 除灵事务所》的文字编辑。请将以下案件文本统一为游戏内风格。

风格要求：
- 冷静、克制的"异常事件记录"口吻
- 类似政府内部档案或民间调查报告
- 中文为主，英文术语用括号标注
- 禁止使用感叹号
- 禁止使用"恐怖""可怕""令人毛骨悚然"等主观感叹词
- 用事实描述让读者自己感到不安
- 字数控制：简报 100-150 字，档案 200-300 字

原文：
{case_draft_text}

请输出改写后的简报和档案文本。
```

### 13.5 美术资源提示词（stable-diffusion / Holopix，Phase 5+）

```
你是《404 除灵事务所》的概念设计师。游戏风格为：传统民俗 + 近未来科技 + 低调诡谲 + 灰暗冷色调。

请生成以下内容的 AI 绘图提示词：

角色：{character_name}
要求：全身立绘，1024×1536 PNG，正面或 3/4 面，站立姿势，无表情或微表情。
风格关键词：dark atmospheric, chinese urban fantasy, modern exorcist, 
weathered clothing, subtle tech details, muted colors, dramatic rim lighting,
concept art style, professional illustration

英文提示词：
```
A full-body character portrait of {character_name}, a {role}, 
{clothing details}, standing pose, {special trait}, 
dark atmospheric, chinese urban fantasy, modern exorcist aesthetic,
weathered tactical clothing with subtle tech glowing details,
muted gray-blue color palette with accent {accent_color},
dramatic rim lighting, sharp focus, concept art style,
professional game illustration, 1024x1536
```

---

## 14. 实施总结

| Phase | 名称 | 预计文件数 | 核心交付 |
|-------|------|------------|----------|
| 0 | 项目初始化 | ~5 | 空骨架 + Godot 可运行 |
| 1 | 战斗闭环 | ~22 | 5 分钟可玩原型 |
| 2 | 案件系统 | ~5 新 + 3 改 | 案件驱动的战斗 |
| 3 | 事务所经营 | ~8 新 + 2 改 | 完整游戏循环 |
| 4 | 采集器 MVP | ~30 | FastAPI + MySQL 流水线 |
| 5 | 灰线地铁 MVP | ~20 | itch.io 可玩版 |
| 6 | 扩展与 Steam | ~40 | 正式 Demo |

**总预计文件数：~130 文件**

> 本计划与策划文档 `404_exorcism_agency_full_plan.docx` 配合使用。策划文档回答"做什么、为什么"，本计划回答"怎么做、在哪做、按什么顺序做"。
