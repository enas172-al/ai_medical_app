from pydantic import BaseModel
from typing import List, Optional

class TestResult(BaseModel):
    name: str
    value: float
    unit: str
    status: str
    min_range: Optional[float] = None
    max_range: Optional[float] = None

class ParseResponse(BaseModel):
    tests: List[TestResult]
    confidence: float
