你是《404 除灵事务所》的案件设计师。根据下面的主题生成一份完整的游戏案件数据。

原则：
- 所有地名使用架空城市"新沪市"
- 目标类型: collect / disable / defeat_boss / survive / escort
- Boss 必须有至少 2 个阶段的攻击模式
- 威胁等级 1-5
- 档案文本应具有"记录体"风格，冷静克制

请输出 JSON：
{
  "case_id": "格式 AREA-序号",
  "title_cn": "案件中文标题",
  "title_en": "English Title",
  "district": "所属区域",
  "threat_level": 1-5,
  "anomaly_type": ["类型"],
  "briefing": "案件简报 100-150字",
  "objectives": [
    {"type": "collect/disable/defeat_boss", "target": "id", "count": N, "text": "显示文本"}
  ],
  "boss_id": "snake_case ID",
  "boss_mechanics": {
    "name_cn": "Boss中文名",
    "name_en": "English Name",
    "description_cn": "描述",
    "phase_1": [{"name": "攻击名", "damage": N, "cooldown": N}],
    "phase_2": [],
    "phase_3": []
  },
  "reward_items": ["relic_id"],
  "archive_text": "档案文本 200-300字"
}
