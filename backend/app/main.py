from fastapi import FastAPI

app = FastAPI(title="Polibatam Microcredential API", version="1.0.0")

@app.get("/")
def read_root():
    return {"message": "Welcome to Polibatam Microcredential API"}
