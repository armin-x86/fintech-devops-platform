from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.models import Asset, Insight, HealthResponse
from app.services import get_assets, calculate_insights
import logging
import os
from pythonjsonlogger import jsonlogger

app = FastAPI(title="Portfolio API", version="1.0.0")

def _configure_logging() -> None:
    level = os.getenv("LOG_LEVEL", "INFO").upper()
    root = logging.getLogger()
    root.setLevel(level)
    handler = logging.StreamHandler()
    formatter = jsonlogger.JsonFormatter("%(asctime)s %(levelname)s %(name)s %(message)s")
    handler.setFormatter(formatter)
    root.handlers = [handler]


_configure_logging()
logger = logging.getLogger("app")

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ALLOW_ORIGINS", "*").split(","), # CORS should be set to our domain but in my test env without LB and live app, I wasn't able to set it to specific rule
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health", response_model=HealthResponse)
def health_check():
    logger.info("health_check")
    return HealthResponse(status="healthy", version="1.0.0")

@app.get("/assets", response_model=list[Asset])
def list_assets():
    logger.info("list_assets")
    return get_assets()

@app.get("/insights", response_model=list[Insight])
def list_insights():
    logger.info("list_insights")
    assets = get_assets()
    return calculate_insights(assets)
