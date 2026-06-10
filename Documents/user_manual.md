# User Manual — LENS ETL Script Documentation Generator

**Version:** 1.0
**Team:** ETLens AI
**Project:** DE-05 — Infinite Solutions Company Project

---

## What is LENS?

LENS is a free AI-powered tool that automatically reads your ETL Python 
and SQL scripts and generates:
- Plain English documentation
- Business purpose explanation
- Data flow diagram
- Impact analysis report

No manual writing. No expensive tools. Just point LENS at your ETL 
folder and get complete documentation in seconds.

---

## System Requirements

| Requirement | Minimum |
|---|---|
| Operating System | Windows 10 or above |
| Python Version | 3.10 or above |
| RAM | 8 GB minimum (16 GB recommended for Llama3) |
| Storage | 10 GB free (for Llama3 model — 4.7 GB) |
| Internet | Required only for initial setup |

---

## Step 1 — Install Prerequisites

### 1A — Install Python
Download Python 3.10 or above from https://python.org
During installation tick **Add Python to PATH**

### 1B — Install Ollama
Download from https://ollama.com/download
Install like normal software.

Open terminal and run:
```bash
ollama pull llama3
```
This downloads the Llama3 model. Takes 10-15 minutes.

### 1C — Install Graphviz
Download from https://graphviz.org/download
During installation tick **Add Graphviz to system PATH**

---

## Step 2 — Setup the Project

Open terminal and run:

```bash
cd etl-doc-generator
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

---

## Step 3 — Configure Environment

Open the `.env` file and verify:
OLLAMA_BASE_URL=http://127.0.0.1:11434
OLLAMA_MODEL=llama3
OUTPUT_DIR=output
DB_PATH=database/etl_docs.db

---

## Step 4 — Start Ollama Server

Open a new terminal window and run:

```bash
ollama serve
```

Keep this terminal open. You should see:
Listening on 127.0.0.1:11434
If you see "Only one usage of each socket address" — Ollama is 
already running. That is fine. Continue.

---

## Step 5 — Start the Application

Open your project terminal with venv activated and run:

```bash
python run.py
```

This starts both the FastAPI backend and Streamlit frontend together.

---

## Step 6 — Using the Application

**Open your browser and go to:**
http://localhost:8501

You will see the LENS web interface.

### How to generate documentation:

**Step 1:** Enter the path to your ETL scripts folder in the input box.
Example: `E:\my_company\etl_scripts`

**Step 2:** Click the **Process ETL Files** button.

**Step 3:** Wait for processing. For 3 files it takes about 30-60 seconds.

**Step 4:** View results:
- Click any file name in the sidebar to see its documentation
- The **Documentation** tab shows plain English explanation
- The **Business Purpose** tab shows why the ETL exists
- The **Flow Diagram** tab shows the data flow PNG diagram
- The **Impact Analysis** tab shows what breaks if this file changes

**Step 5:** Click **Export PDF** to download the full report.

---

## Step 7 — Testing with Sample Files

To test with our provided sample ETL files run:

```bash
# In the Streamlit UI enter this path:
etl_samples/
```

You will see documentation generated for:
- `sample_orders.py` — Orders ETL pipeline
- `sample_hr.py` — HR payroll ETL pipeline
- `sample_sales.sql` — Sales summary SQL ETL

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `ollama serve` gives socket error | Ollama already running — ignore and continue |
| Streamlit not opening | Make sure venv is activated and run `python run.py` again |
| LLM response is slow | Llama3 takes 30-60 seconds on first run — be patient |
| Graphviz diagram not generated | Restart terminal after Graphviz installation so PATH updates |
| Package not found error | Run `pip install -r requirements.txt` again with venv activated |
| Port 8000 already in use | Change FastAPI port in `backend/main.py` from 8000 to 8001 |

---

## Output Files Location

| Output Type | Location |
|---|---|
| Markdown documentation | `output/docs/` |
| Flow diagram PNG | `output/diagrams/` |
| PDF reports | `output/reports/` |
| SQLite database | `database/etl_docs.db` |

---

## Contact

**Team ETLens AI**
Infinite Solutions Company Project — DE-05