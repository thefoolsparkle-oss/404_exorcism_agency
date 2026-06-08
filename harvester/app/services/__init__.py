import os
from app.llm.factory import get_llm

PROMPTS_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "prompts")


def load_prompt(name: str) -> str:
    path = os.path.join(PROMPTS_DIR, name)
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    return ""


class SearchService:
    def __init__(self):
        self._mock_sources = [
            {
                "title": "The Midnight Train",
                "url": "https://example.com/creepypasta/midnight-train",
                "snippet": "A ghost train appears at a decommissioned station every night at 2:17 AM.",
                "raw_text": "Every night at 2:17 AM, the platform CCTV at Xinhu Metro Station catches something strange. A train pulls in. But this station was decommissioned 20 years ago.",
                "source_type": "creepypasta",
                "language": "en",
            },
            {
                "title": "The Building That Shouldn't Exist",
                "url": "https://example.com/forum/building",
                "snippet": "A construction worker discovers an extra floor between the 7th and 8th floor.",
                "raw_text": "My friend works construction and he told me about a building they were renovating. The blueprints showed 13 floors. But when they counted the windows from outside, there were 14.",
                "source_type": "forum_post",
                "language": "zh",
            },
            {
                "title": "The Red Door",
                "url": "https://example.com/news/red-door",
                "snippet": "A mysterious red door appears at random locations across the old town district.",
                "raw_text": "Residents of the old town district have reported a red door that appears at different locations. Never the same spot twice.",
                "source_type": "news",
                "language": "zh",
            },
            {
                "title": "Ghost Bus Route 44",
                "url": "https://example.com/blog/ghost-bus",
                "snippet": "Bus route 44 has been discontinued since 1999 but reappears on foggy nights.",
                "raw_text": "Bus route 44 in New Hu City has been officially discontinued since 1999. On foggy nights, people report seeing a vintage bus approaching.",
                "source_type": "blog",
                "language": "zh",
            },
            {
                "title": "The Prophetic Radio",
                "url": "https://example.com/nosleep/radio-warnings",
                "snippet": "An antique radio broadcasts warnings about future disasters.",
                "raw_text": "I bought an antique radio at a flea market. It doesn't work normally. But sometimes it turns on by itself and plays a woman's voice reading emergency broadcast warnings about future events.",
                "source_type": "nosleep",
                "language": "en",
            },
        ]

    def search(self, query: str = "") -> list:
        return self._mock_sources


class MotifExtractor:
    def __init__(self):
        self.llm = get_llm()
        self.system_prompt = load_prompt("extract_motif.md")

    def extract(self, source_text: str) -> dict:
        import json
        prompt = f"请从以下素材中提取怪谈主题：\n\n{source_text[:3000]}"
        response = self.llm.chat(self.system_prompt, prompt)
        try:
            return json.loads(response)
        except json.JSONDecodeError:
            return {"error": "parse_failed", "raw": response}


class RiskReviewer:
    def __init__(self):
        self.llm = get_llm()
        self.system_prompt = load_prompt("risk_review.md")

    def review(self, source: dict, motif: dict) -> dict:
        import json
        prompt = f"来源: {source.get('url','')}\n主题: {motif}"
        response = self.llm.chat(self.system_prompt, prompt)
        try:
            return json.loads(response)
        except json.JSONDecodeError:
            return {"risk_level": 0, "risk_tags": [], "decision": "approved"}


class CaseGenerator:
    def __init__(self):
        self.llm = get_llm()
        self.system_prompt = load_prompt("generate_case.md")
        self._counter = 0

    def generate(self, motif: dict, risk_tags: list) -> dict:
        import json
        self._counter += 1
        prompt = f"主题: {motif}\n风险标签: {risk_tags}"
        response = self.llm.chat(self.system_prompt, prompt)
        try:
            return json.loads(response)
        except json.JSONDecodeError:
            return {"error": "parse_failed"}


class StyleRewriter:
    def __init__(self):
        self.llm = get_llm()
        self.system_prompt = load_prompt("rewrite_style.md")

    def rewrite(self, draft: dict) -> dict:
        import json
        prompt = f"案件数据: {draft}"
        response = self.llm.chat(self.system_prompt, prompt)
        try:
            return json.loads(response)
        except json.JSONDecodeError:
            return draft


class Exporter:
    def export(self, cases: list, output_path: str) -> int:
        import json, os
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        game_format = []
        for case in cases:
            obj_list = case.get("objectives", [])
            if isinstance(obj_list, str):
                import json as j
                try:
                    obj_list = j.loads(obj_list)
                except Exception:
                    obj_list = []
            game_format.append({
                "case_id": case.get("case_id", ""),
                "title_cn": case.get("title_cn", ""),
                "title_en": case.get("title_en", ""),
                "display_name": case.get("display_name", case.get("title_cn", "")),
                "district": case.get("district", ""),
                "threat_level": case.get("threat_level", 1),
                "anomaly_type": case.get("anomaly_type", []),
                "briefing": case.get("briefing", ""),
                "objectives": obj_list,
                "boss_id": case.get("boss_id", ""),
                "reward_items": case.get("reward_items", []),
                "archive_text": case.get("archive_text", ""),
                "source_inspiration": [],
            })
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(game_format, f, ensure_ascii=False, indent=2, default=str)
        return len(game_format)
