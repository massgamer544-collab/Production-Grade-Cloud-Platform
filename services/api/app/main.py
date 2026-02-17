import os
from fastapi import FastAPI

app = FastAPI(title="Production-Grade Platform Lab")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/")
def root():
    # On expose la présence de la variable pour prouver le wiring (sans leak de secrets)
    return {
        "service": "api",
        "database_url_set": bool(os.getenv("DATABASE_URL"))
    }
