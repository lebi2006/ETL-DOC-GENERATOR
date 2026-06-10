# System Architecture — LENS ETL Script Documentation Generator

## Overview
LENS is a multi-layer AI-powered application that automatically reads ETL 
scripts and generates documentation, business explanations, flow diagrams, 
and impact analysis reports.

---

## Architecture Diagram (Text Representation)
┌─────────────────────────────────────────────────────────────┐
│                    STREAMLIT FRONTEND                        │
│              (User uploads ETL folder path)                  │
└─────────────────────┬───────────────────────────────────────┘
│ HTTP Request
▼
┌─────────────────────────────────────────────────────────────┐
│                    FASTAPI BACKEND                           │
│                  (REST API Layer)                            │
│     POST /process   GET /results   GET /impact/{file}       │
└──────┬──────────────┬──────────────────────┬────────────────┘
│              │                      │
▼              ▼                      ▼
┌──────────┐  ┌───────────────┐    ┌─────────────────┐
│  PARSER  │  │   AI LAYER    │    │  DIAGRAM +      │
│  LAYER   │  │               │    │  IMPACT LAYER   │
│          │  │ llm_client    │    │                 │
│ AST      │  │ doc_generator │    │ flow_diagram    │
│ Parser   │  │ biz_explainer │    │ (Graphviz)      │
│          │  │ rag_pipeline  │    │                 │
│ SQL      │  │ (LangChain +  │    │ impact_analysis │
│ Parser   │  │  FAISS)       │    │ (NetworkX)      │
└──────┬───┘  └───────┬───────┘    └────────┬────────┘
│              │                     │
▼              ▼                     │
┌──────────────────────────┐               │
│      MCP TOOL            │               │
│   ASTReaderTool          │               │
│ (LangChain BaseTool)     │               │
└──────────────────────────┘               │
│              │                     │
▼              ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                                │
│         SQLite DB        output/docs      output/diagrams   │
│       (metadata +        (Markdown)          (PNG)          │
│        results)          output/reports                     │
│                             (PDF)                           │
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│                    OLLAMA (LOCAL LLM)                        │
│              Llama3 running on port 11434                    │
│         Free — No API key — No data leaves system           │
└─────────────────────────────────────────────────────────────┘
---

## Module Descriptions

### 1. Streamlit Frontend (`frontend/app.py`)
- Entry point for all users
- Accepts ETL folder path as input
- Calls FastAPI backend via HTTP
- Displays documentation, diagrams, business purpose, impact analysis
- Provides PDF export button

### 2. FastAPI Backend (`backend/main.py`)
- REST API layer connecting frontend to all processing modules
- Three endpoints: process, results, impact
- Handles CORS for Streamlit connection
- Orchestrates the full agent loop

### 3. Parser Layer
- `parser/python_parser.py` — Uses Python AST module to parse `.py` ETL files
- `parser/sql_parser.py` — Uses sqlparse to parse `.sql` ETL files
- Extracts sources, transformations, and targets from every file

### 4. MCP Tool (`mcp_tool/ast_reader_tool.py`)
- Custom LangChain BaseTool — ASTReaderTool
- Agent calls this tool to read any ETL file
- Wraps both parsers in a single callable tool interface
- Satisfies mandatory MCP Tool requirement

### 5. AI Layer (`ai/`)
- `llm_client.py` — Connects to Ollama REST API at port 11434
- `doc_generator.py` — Generates plain English documentation
- `business_explainer.py` — Explains business purpose of each ETL script
- `rag_pipeline.py` — FAISS vector store + Sentence Transformers for RAG

### 6. Diagram Layer (`diagram/flow_diagram.py`)
- Uses Graphviz to draw directed data flow diagrams
- Green nodes = sources, Blue nodes = transformations, Orange nodes = targets
- Saves PNG to `output/diagrams/`

### 7. Impact Analysis (`impact/impact_analysis.py`)
- Uses NetworkX to build dependency graph across all ETL scripts
- Identifies downstream scripts and tables affected by any change
- Returns severity levels for each impact

### 8. Export Layer (`export/pdf_exporter.py`)
- Uses fpdf2 to generate PDF reports
- Includes documentation, business purpose, and impact sections
- Saves to `output/reports/`

### 9. Database Layer (`database/db_handler.py`)
- SQLite database stores all parsed metadata and generated results
- Enables GET /results endpoint to retrieve past processing runs

---

## Agent Loop Flow
START
│
▼
Pick next ETL file from folder
│
▼
ASTReaderTool (MCP Tool) reads and parses file
│
▼
Send parsed metadata to Ollama via REST API
│
├──→ Generate plain English documentation
├──→ Generate business purpose explanation
│
▼
Graphviz draws flow diagram → saves PNG
│
▼
NetworkX builds impact graph → returns affected nodes
│
▼
Save all results to SQLite + output folders
│
▼
Any more files? → YES → go back to top
→ NO  → return all results to frontend
END
---

## Mandatory AI Capabilities Satisfied

| Capability | How |
|---|---|
| Agent Loop | LangChain agent loops through every ETL file automatically |
| MCP Tool (Built) | ASTReaderTool — custom built LangChain BaseTool |
| External API Integration | Ollama REST API called via requests at port 11434 |
