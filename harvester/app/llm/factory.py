from app.llm import MockProvider, OpenAIProvider
from app.config import settings


def get_llm():
    if settings.llm_provider == "mock":
        return MockProvider()
    return OpenAIProvider(
        api_key=settings.llm_api_key,
        base_url=settings.llm_base_url,
        model=settings.llm_model,
    )
