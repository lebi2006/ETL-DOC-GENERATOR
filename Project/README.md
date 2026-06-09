# ⚙️ ETL Script Documentation Generator
> **Hackathon Project — DE-05**
> Automatically generate documentation, business explanations, flow diagrams, and impact analysis for any ETL script using AI.

---

## 🚨 The Problem
In real companies, data engineers write hundreds of ETL scripts. Nobody documents them. New developers waste weeks understanding old code. One broken script can silently destroy entire data pipelines — and nobody knows what depends on what.

**4 gaps we fix:**

| Gap | Pain | Our Solution |
|---|---|---|
| No Documentation | Nobody knows what scripts do | AI generates plain English docs instantly |
| No Business Context | Nobody knows WHY scripts exist | LLM explains business purpose and risk |
| No Visual Flow | Can't see how data moves | Auto-generated Source→Transform→Target diagrams |
| No Impact Analysis | Changes break things silently | Dependency graph shows blast radius |

---

## 🚀 Features

- 📄 **Auto Documentation** — Plain English explanation of every ETL script
- 💼 **Business Purpose** — Why it exists, who uses it, what breaks if it fails
- 🔀 **Flow Diagrams** — Visual data flow: Source → Transformation → Target
- 💥 **Impact Analysis** — Dependency graph with risk levels (LOW/MEDIUM/HIGH)
- 🤖 **Ask AI** — Natural language Q&A about your ETL scripts
- 📥 **PDF Export** — Full report downloadable instantly
- ⚡ **Instant Results** — Pre-generated cache + template fallback, no waiting

---

## 🛠️ Tech Stack

| Technology | Role |
|---|---|
| Python AST | Reads Python scripts without running them |
| sqlparse | Parses SQL scripts |
| Ollama + Llama3 | Free local LLM for documentation |
| Sentence Transformers | Converts text to vectors |
| FAISS | Vector store for AI search |
| Graphviz | Generates flow diagrams |
| NetworkX | Builds dependency graphs |
| FastAPI | Backend API |
| Streamlit | Frontend UI |
| fpdf2 | PDF export |
| SQLite | Local database |

---

## 📁 Project Structure
etl-doc-generator/
├── etl_samples/          # Sample ETL scripts
├── parser/               # Python AST + SQL parsers
├── ai/                   # LLM client, doc generator, RAG pipeline
├── diagram/              # Graphviz flow diagrams
├── impact/               # NetworkX impact analysis
├── export/               # PDF report generator
├── backend/              # FastAPI backend
├── frontend/             # Streamlit frontend
├── output/               # Generated docs, diagrams, reports
├── run_pregenerate.py    # Pre-generate all outputs for demo
└── requirements.txt
---

## ⚡ Quick Start

### 1. Clone the repo
```bash
git clone https://github.com/lebi2006/etl-doc-generator.git
cd etl-doc-generator
```

### 2. Create virtual environment
```bash
python -m venv venv
venv\Scripts\activate
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
pip install python-multipart
```

### 4. Install and start Ollama
```bash
# Download from https://ollama.com
ollama pull llama3
ollama serve
```

### 5. Pre-generate outputs (run once)
```bash
python run_pregenerate.py
```

### 6. Start backend
```bash
uvicorn backend.main:app --reload --port 8000
```

### 7. Start frontend
```bash
streamlit run frontend/app.py
```

Open **http://localhost:8501**

---

## 🎯 How to Use

1. **📂 Analyze Scripts** → Click "Analyze Sample ETL Files" or upload your own
2. **🔀 Flow Diagrams** → Generate visual data flow diagrams
3. **💥 Impact Analysis** → See risk levels and dependencies
4. **📄 Documentation** → AI-generated plain English docs
5. **💼 Business Purpose** → Why each script exists
6. **🤖 Ask AI** → Ask anything about your scripts
7. **⬇️ Download PDF** → Full report in sidebar

---

## 🆕 Upload Your Own ETL Script

Any Python or SQL ETL script works. Example structure:

```python
import pandas as pd
import sqlite3

conn = sqlite3.connect("database.db")
df = pd.read_csv("data/your_data.csv")
df = df[df["value"] > 100]
df["new_col"] = df["value"] * 0.1
df.to_sql("your_table", conn, if_exists="replace", index=False)
conn.close()
```

---

## 👩‍💻 Team
Built with ❤️ at our first hackathon by a team of 4 beginner developers.

---

## 📄 License
MIT