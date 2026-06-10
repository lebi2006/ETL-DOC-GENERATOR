# Tech Stack — LENS ETL Script Documentation Generator

## Final Tech Stack

| # | Component | Technology | Version | Purpose |
|---|---|---|---|---|
| 1 | Programming Language | Python | 3.10.11 | Core language that runs the entire tool end to end |
| 2 | Frontend | Streamlit | 1.33.0 | Web UI where users upload ETL folder and view generated docs |
| 3 | Backend | FastAPI | 0.110.0 | Lightweight REST API connecting frontend to all AI modules |
| 4 | API Server | Uvicorn | 0.29.0 | ASGI server that runs the FastAPI application |
| 5 | LLM | Ollama + Llama3 | Latest | Free local LLM — generates plain English documentation and explanations |
| 6 | Embeddings | Sentence Transformers | 2.7.0 | Converts ETL documentation text into vectors for FAISS search |
| 7 | Vector Database | FAISS | 1.8.0 | Stores embedded documentation and retrieves relevant context for RAG |
| 8 | RAG Framework | LangChain | 0.1.16 | Orchestrates agent loop and connects all AI components |
| 9 | Python Parsing | AST Module | Built-in | Reads and understands Python ETL files without needing comments |
| 10 | SQL Parsing | sqlparse | 0.5.0 | Reads and understands SQL ETL files — extracts tables and operations |
| 11 | Diagram Generation | Graphviz | 15.0.0 | Draws automatic data flow diagrams — source to transformation to target |
| 12 | Impact Analysis | NetworkX | 3.3 | Builds dependency graph — shows what breaks if an ETL script changes |
| 13 | Database | SQLite | Built-in | Stores parsed ETL metadata and generated documentation results |
| 14 | ORM | SQLAlchemy | 2.0.29 | Manages SQLite database operations cleanly |
| 15 | PDF Export | fpdf2 | 2.7.9 | Converts generated documentation into downloadable PDF reports |
| 16 | HTTP Client | requests | 2.31.0 | Makes REST API calls to Ollama LLM server |
| 17 | Environment Management | python-dotenv | 1.0.1 | Manages configuration values like Ollama URL without hardcoding |
| 18 | Data Validation | Pydantic | 2.6.4 | Validates API request and response models in FastAPI |
| 19 | Markdown Processing | markdown | 3.6 | Processes and renders Markdown documentation output |
| 20 | MCP Tool | LangChain BaseTool | 0.1.16 | Custom ASTReaderTool wrapping parsers as agent-callable tool |
| 21 | Source Control | GitHub | — | Stores all project code and satisfies mandatory source control requirement |
| 22 | Collaboration | Discord | — | Team communication satisfying mandatory collaboration requirement |
| 23 | AI Coding Assistant | GitHub Copilot | — | Used during development — satisfies mandatory AI assisted development |

---

## How Each Technology Fixes a Market Gap

| Gap in Existing Solutions | Technology That Fixes It | How |
|---|---|---|
| No tool works on plain Python/SQL files | AST Module + sqlparse | Directly reads any .py or .sql file with zero pre-configuration |
| No free and open source solution | Ollama + Llama3 + all Python libraries | Everything runs locally for free — zero cost |
| No tool reads all files automatically | LangChain Agent Loop + pathlib | Loops through every file in folder without human involvement |
| No tool generates readable English docs | Ollama REST API via requests | Sends parsed metadata to LLM — gets back plain English explanation |
| No tool draws data flow diagram free | Graphviz | Automatically generates PNG diagrams for every ETL script |

---

## Installation Command

```bash
pip install -r requirements.txt
```

## External Tool Installation

| Tool | Download Link | Why Separate |
|---|---|---|
| Ollama | https://ollama.com/download | Runs as a local server — not a Python package |
| Graphviz | https://graphviz.org/download | Binary tool — Python library is just a wrapper |