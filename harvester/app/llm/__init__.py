from abc import ABC, abstractmethod

class LLMProvider(ABC):
    @abstractmethod
    def chat(self, system_prompt: str, user_prompt: str) -> str:
        pass


class MockProvider(LLMProvider):
    def __init__(self):
        self._counter = 0

    def chat(self, system_prompt: str, user_prompt: str) -> str:
        self._counter += 1
        if "提取" in system_prompt or "extract" in system_prompt.lower():
            return self._mock_motif()
        elif "risk" in system_prompt.lower() or "审核" in system_prompt:
            return self._mock_risk()
        elif "案件" in system_prompt or "case" in system_prompt.lower() or "generate" in system_prompt.lower():
            return self._mock_case(user_prompt)
        elif "改写" in system_prompt or "rewrite" in system_prompt.lower() or "风格" in system_prompt:
            return self._mock_style()
        return '{"note": "unknown task"}'

    def _mock_motif(self) -> str:
        motifs = [
            '{"location":"废弃地铁站","time_period":"凌晨2-4点","anomaly_type":["空间异常","时间循环"],"core_motif":{"entity":"不存在的列车","rule":"只在特定时间出现","trigger":"注视监控画面"},"taboo_rule":"不要凝视超过30秒","horror_point":"乘客突然转向摄像头","game_potential":"高","suggested_mechanics":["限时收集","躲避视线"]}',
            '{"location":"旧城区公寓","time_period":"全天","anomaly_type":["空间异常","认知感染"],"core_motif":{"entity":"多余的楼层","rule":"电梯无法到达","trigger":"数窗户时发现"},"taboo_rule":"不要进入该楼层","horror_point":"楼层里的东西","game_potential":"高","suggested_mechanics":["解谜探索","Boss战"]}',
            '{"location":"任意地点","time_period":"夜晚到日出","anomaly_type":["空间异常","认知感染"],"core_motif":{"entity":"红色门","rule":"随机出现","trigger":"打开门"},"taboo_rule":"不要打开","horror_point":"通往童年住所","game_potential":"中","suggested_mechanics":["随机事件","选择分支"]}',
            '{"location":"旧公交站","time_period":"雾天夜晚","anomaly_type":["空间异常","规则异常"],"core_motif":{"entity":"幽灵公交44路","rule":"只搭载独行女性","trigger":"在旧站点等车"},"taboo_rule":"女性不要独行","horror_point":"失踪者最后位置","game_potential":"高","suggested_mechanics":["护送NPC","限时逃脱"]}',
            '{"location":"家中","time_period":"凌晨3点","anomaly_type":["时间异常","预言"],"core_motif":{"entity":"预知收音机","rule":"播放未来灾难预警","trigger":"通电"},"taboo_rule":"不要记录","horror_point":"预警成真","game_potential":"中","suggested_mechanics":["倒计时机制","选择干预"]}',
        ]
        return motifs[self._counter % len(motifs)]

    def _mock_risk(self) -> str:
        return '{"risk_level":2,"risk_tags":["public_domain","fictional"],"decision":"approved","reason":"公开来源的虚构故事，无版权问题"}'

    def _mock_case(self, user_prompt: str) -> str:
        i = self._counter % 3
        cases = [
            '{"case_id":"GLM-003","title_cn":"多余楼层","title_en":"The Extra Floor","display_name":"多余楼层（The Extra Floor）","district":"旧城区","threat_level":3,"anomaly_type":["空间异常","认知感染"],"briefing":"新沪市旧城区一栋公寓的居民发现了一个奇怪的现象：从外面看，楼有13层，但从里面数，楼梯在7层和8层之间多了一个平台。","objectives":[{"type":"collect","target":"floor_key","count":3,"text":"收集三层楼的钥匙"},{"type":"defeat_boss","target":"floor_guardian","text":"击败楼层守护者"}],"boss_id":"floor_guardian","boss_mechanics":{"name_cn":"楼层守护者","name_en":"Floor Guardian","description_cn":"守护多余楼层的未知存在","phase_1":[{"name":"门板投掷","damage":25,"cooldown":2.0}],"phase_2":[{"name":"空间折叠","damage":20,"cooldown":3.0}],"phase_3":[{"name":"楼层崩塌","damage":40,"cooldown":5.0}]},"reward_items":["old_key","building_pass"],"archive_text":"档案编号 GLM-003：经测量，该建筑外部高度为39.8米，内部楼梯总高度为41.2米。差值1.4米恰好对应一层楼的高度。建筑设计师承认图纸中有无法解释的空白区域，但坚称施工时并未建造。建议低楼层住户暂时搬离。"}',
            '{"case_id":"GLM-004","title_cn":"红色门","title_en":"The Red Door","display_name":"红色门（The Red Door）","district":"新沪市各区","threat_level":2,"anomaly_type":["空间异常","认知感染"],"briefing":"一扇红色的门随机出现在城市的各个角落。每次都在不同的位置。打开门的人报告说看到了一条通往自己童年住所的长廊。","objectives":[{"type":"collect","target":"door_memory","count":5,"text":"收集五段门的记忆"},{"type":"defeat_boss","target":"door_entity","text":"击败门中之物"}],"boss_id":"door_entity","reward_items":["red_key","memory_shard"],"archive_text":"档案编号 GLM-004：市政记录中不存在匹配该门的建筑许可。所有声称打开过门的人无法再次找到它。值得注意的是，多位目击者描述的童年住所已经不存在（已拆除或改建）。建议市民勿靠近任何不明来源的红色门。"}',
            '{"case_id":"GLM-005","title_cn":"幽灵公交","title_en":"Ghost Bus Route","display_name":"幽灵公交（Ghost Bus Route）","district":"公交44路沿线","threat_level":4,"anomaly_type":["空间异常","规则异常"],"briefing":"已停运25年的公交44路在雾天重新出现。该车只搭载独行女性，多名失踪者的最后定位均在44路站点附近。","objectives":[{"type":"survive","target":"bus_stop","count":1,"text":"在旧站点存活至公交出现"},{"type":"disable","target":"bus_engine","count":3,"text":"关闭三处发动机异常"},{"type":"defeat_boss","target":"bus_conductor","text":"击败公交售票员"}],"boss_id":"bus_conductor","reward_items":["old_ticket","fog_lantern"],"archive_text":"档案编号 GLM-005：公交44路于1999年因财政原因停运。所有车辆已报废。但在大雾天气，404事务所仍会接到关于该线路的投诉。请勿在雾天独自前往旧44路站点。如果你看到车灯，不要招手。"}',
        ]
        return cases[i]

    def _mock_style(self) -> str:
        return '{"briefing":"已改写完成。","archive_text":"已改写完成。"}'


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
