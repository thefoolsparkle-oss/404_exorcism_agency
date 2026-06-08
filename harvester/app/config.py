from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str = "sqlite:///harvester.db"
    llm_provider: str = "mock"
    llm_api_key: str = ""
    llm_base_url: str = ""
    llm_model: str = ""
    export_dir: str = "exports"
    search_api_key: str = ""
    search_engine_id: str = ""

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
