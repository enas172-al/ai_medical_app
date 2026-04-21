import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from models import ParseResponse
from ner_engine import parse_medical_text

app = FastAPI(title="ai_medical_app API", version="1.0", description="Hybrid NER Medical Text Parser")

class OCRRequest(BaseModel):
    text: str

@app.post("/parse-medical-text", response_model=ParseResponse)
def parse_text(request: OCRRequest):
    if not request.text or len(request.text.strip()) == 0:
        raise HTTPException(status_code=400, detail="Empty text provided in OCRRequest.")
        
    try:
        # Run our SpaCy/Rules Engine
        result = parse_medical_text(request.text)
        
        return ParseResponse(
            tests=result["tests"],
            confidence=result["confidence"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
def root():
    return {"message": "AI Medical App Backend is running. Target /parse-medical-text"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
