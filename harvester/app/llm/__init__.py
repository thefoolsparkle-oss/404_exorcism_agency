from abc import ABC, abstractmethod
import json


class LLMProvider(ABC):
    @abstractmethod
    def chat(self, system_prompt: str, user_prompt: str) -> str:
        pass


class MockProvider(LLMProvider):
    def __init__(self):
        self._counter = 0

    def chat(self, system_prompt: str, user_prompt: str) -> str:
        self._counter += 1
        prompt = system_prompt.lower()
        if "extract" in prompt or "提取" in prompt:
            return self._mock_motif()
        if "risk" in prompt or "审核" in prompt:
            return self._mock_risk()
        if "rewrite" in prompt or "改写" in prompt:
            return self._mock_style()
        if "case" in prompt or "generate" in prompt or "案件" in prompt or "生成" in prompt:
            return self._mock_case()
        return json.dumps({"note": "unknown task"}, ensure_ascii=False)

    def _mock_motif(self) -> str:
        motifs = [
            {
                "location": "灰线地铁站",
                "time_period": "凌晨 2 点至 4 点",
                "anomaly_type": ["空间异常", "时间循环"],
                "core_motif": {
                    "entity": "不存在的列车",
                    "rule": "只在特定时间出现在废弃站台",
                    "trigger": "持续观看监控画面",
                },
                "taboo_rule": "不要凝视屏幕超过 30 秒",
                "horror_point": "录像中的乘客会同时转头看向镜头",
                "game_potential": "高",
                "suggested_mechanics": ["限时收集", "躲避视线"],
            },
            {
                "location": "旧城区公寓",
                "time_period": "全天",
                "anomaly_type": ["空间异常", "认知感染"],
                "core_motif": {
                    "entity": "多余楼层",
                    "rule": "电梯无法抵达，楼梯会重复折返",
                    "trigger": "从外部清点窗户",
                },
                "taboo_rule": "不要进入不存在于图纸中的楼层",
                "horror_point": "楼层内传来住户已搬离多年的生活声",
                "game_potential": "高",
                "suggested_mechanics": ["解谜探索", "Boss 战"],
            },
            {
                "location": "任意街角",
                "time_period": "夜晚至日出",
                "anomaly_type": ["空间异常", "认知感染"],
                "core_motif": {
                    "entity": "红色门",
                    "rule": "随机出现，日出后消失",
                    "trigger": "打开门把手",
                },
                "taboo_rule": "不要打开来源不明的红门",
                "horror_point": "门后通向进入者童年住处的长廊",
                "game_potential": "中",
                "suggested_mechanics": ["随机事件", "选择分支"],
            },
        ]
        return json.dumps(motifs[self._counter % len(motifs)], ensure_ascii=False)

    def _mock_risk(self) -> str:
        return json.dumps(
            {
                "risk_level": 2,
                "risk_tags": ["public_domain", "fictional"],
                "decision": "approved",
                "reason": "仅借用都市传说氛围和结构，不复刻来源文本。",
            },
            ensure_ascii=False,
        )

    def _mock_case(self) -> str:
        cases = [
            {
                "case_id": "GLM-003",
                "title_cn": "多余楼层",
                "title_en": "The Extra Floor",
                "display_name": "多余楼层（The Extra Floor）",
                "district": "旧城区",
                "threat_level": 3,
                "anomaly_type": ["空间异常", "认知感染"],
                "briefing": "新沪市旧城区一栋公寓出现内部楼层数量与外部观测不一致的现象。住户报告夜间可听见来自夹层的脚步声，但楼层登记资料中不存在对应房间。",
                "objectives": [
                    {"type": "collect", "target": "floor_key", "count": 3, "text": "收集三枚楼层钥匙"},
                    {"type": "defeat_boss", "target": "floor_guardian", "count": 1, "text": "击败楼层守护者"},
                ],
                "boss_id": "floor_guardian",
                "boss_mechanics": {
                    "name_cn": "楼层守护者",
                    "name_en": "Floor Guardian",
                    "description_cn": "守护多余楼层的未知实体。",
                    "phase_1": [{"name": "门板投掷", "damage": 25, "cooldown": 2.0}],
                    "phase_2": [{"name": "空间折返", "damage": 20, "cooldown": 3.0}],
                    "phase_3": [{"name": "楼层坍缩", "damage": 40, "cooldown": 5.0}],
                },
                "reward_items": ["old_key", "building_pass"],
                "archive_text": "档案编号 GLM-003：测量结果显示，该建筑外部高度与内部楼梯累计高度存在 1.4 米差值。原设计图中对应位置为空白。建议低楼层住户暂时迁离，现场继续封控。",
            },
            {
                "case_id": "GLM-004",
                "title_cn": "红色门",
                "title_en": "The Red Door",
                "display_name": "红色门（The Red Door）",
                "district": "新沪市各区",
                "threat_level": 2,
                "anomaly_type": ["空间异常", "认知感染"],
                "briefing": "一扇红门在城市不同角落随机出现。目击者称门后走廊通向自己童年住所。门体在日出后消失，现场不留下安装痕迹。",
                "objectives": [
                    {"type": "collect", "target": "door_memory", "count": 5, "text": "收集五段门内记忆"},
                    {"type": "defeat_boss", "target": "door_entity", "count": 1, "text": "击败门中之物"},
                ],
                "boss_id": "door_entity",
                "boss_mechanics": {
                    "name_cn": "门中之物",
                    "name_en": "Door Entity",
                    "description_cn": "停留在门后长廊中的认知实体。",
                    "phase_1": [{"name": "记忆回声", "damage": 15, "cooldown": 1.8}],
                    "phase_2": [{"name": "走廊延展", "damage": 22, "cooldown": 3.0}],
                    "phase_3": [],
                },
                "reward_items": ["red_key", "memory_shard"],
                "archive_text": "档案编号 GLM-004：市政记录中不存在与该红门匹配的建筑许可。所有目击者均无法再次找到同一位置。建议市民不要靠近来源不明的红色门体。",
            },
            {
                "case_id": "GLM-005",
                "title_cn": "幽灵公交",
                "title_en": "Ghost Bus Route",
                "display_name": "幽灵公交（Ghost Bus Route）",
                "district": "公交 44 路沿线",
                "threat_level": 4,
                "anomaly_type": ["空间异常", "规则异常"],
                "briefing": "已停运多年的 44 路公交在浓雾天气重新出现。车辆仅在旧站点停靠，多名失踪者最后定位均在该线路附近。",
                "objectives": [
                    {"type": "survive", "target": "bus_stop", "count": 1, "text": "在旧站点存活至公交出现"},
                    {"type": "disable", "target": "bus_engine", "count": 3, "text": "关闭三处发动机异常"},
                    {"type": "defeat_boss", "target": "bus_conductor", "count": 1, "text": "击败公交售票员"},
                ],
                "boss_id": "bus_conductor",
                "boss_mechanics": {
                    "name_cn": "公交售票员",
                    "name_en": "Bus Conductor",
                    "description_cn": "维持幽灵公交运行规则的实体。",
                    "phase_1": [{"name": "撕票", "damage": 18, "cooldown": 1.5}],
                    "phase_2": [{"name": "雾灯召回", "damage": 24, "cooldown": 3.2}],
                    "phase_3": [{"name": "末班车碾压", "damage": 45, "cooldown": 6.0}],
                },
                "reward_items": ["old_ticket", "fog_lantern"],
                "archive_text": "档案编号 GLM-005：44 路公交于 1999 年停运，车辆均已报废。浓雾天气中仍有市民报告看到线路号。建议暂停相关旧站点夜间通行。",
            },
        ]
        return json.dumps(cases[self._counter % len(cases)], ensure_ascii=False)

    def _mock_style(self) -> str:
        return json.dumps(
            {
                "briefing": "文本已按内部档案语气改写，保留可执行目标与异常规则。",
                "archive_text": "记录已完成归档，后续观察重点为异常触发条件与复发现象。",
            },
            ensure_ascii=False,
        )


class OpenAIProvider(LLMProvider):
    def __init__(self, api_key: str, base_url: str, model: str):
        self.api_key = api_key
        self.base_url = base_url
        self.model = model

    def chat(self, system_prompt: str, user_prompt: str) -> str:
        import httpx

        resp = httpx.post(
            f"{self.base_url}/chat/completions",
            headers={"Authorization": f"Bearer {self.api_key}"},
            json={
                "model": self.model,
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                "temperature": 0.7,
            },
            timeout=60.0,
        )
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"]
