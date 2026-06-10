# System Architecture — LENS ETL Script Documentation Generator

## Overview
LENS is a multi-layer AI-powered application that automatically reads 
ETL scripts and generates documentation, business explanations, flow 
diagrams, and impact analysis reports.

---

## System Architecture

```mermaid
flowchart TD
    A[👤 User — Streamlit Frontend\nUploads ETL folder path] -->|HTTP Request| B

    B[⚡ FastAPI Backend\nPOST /process\nGET /results\nGET /impact/filename]

    B --> C[🔍 Parser Layer]
    B --> D[🧠 AI Layer]
    B --> E[📊 Diagram + Impact Layer]

    C --> C1[AST Parser\npython_parser.py]
    C --> C2[SQL Parser\nsql_parser.py]

    C1 --> F[🔧 MCP Tool\nASTReaderTool\nLangChain BaseTool]
    C2 --> F

    D --> D1[llm_client.py\nOllama REST API]
    D --> D2[doc_generator.py\nDocumentation]
    D --> D3[business_explainer.py\nBusiness Purpose]
    D --> D4[rag_pipeline.py\nLangChain + FAISS]

    E --> E1[flow_diagram.py\nGraphviz PNG]
    E --> E2[impact_analysis.py\nNetworkX Graph]

    F --> G[(🗄️ Data Layer)]
    D --> G
    E --> G

    G --> G1[SQLite DB\nmetadata + results]
    G --> G2[output/docs\nMarkdown files]
    G --> G3[output/diagrams\nPNG files]
    G --> G4[output/reports\nPDF files]

    D1 --> H[🦙 Ollama Local LLM\nLlama3 on port 11434\nFree — No API key\nNo data leaves system]
```

---

## Agent Loop Flow

```mermaid
flowchart TD
    Start([🚀 START]) --> A[Pick next ETL file from folder]
    A --> B[🔧 ASTReaderTool MCP Tool\nReads and parses file]
    B --> C[📤 Send parsed metadata\nto Ollama REST API]
    C --> D[📝 Generate plain English\ndocumentation]
    C --> E[💼 Generate business\npurpose explanation]
    D --> F[🗺️ Graphviz draws\nflow diagram → PNG]
    E --> F
    F --> G[🔗 NetworkX builds\nimpact graph]
    G --> H[💾 Save all results to\nSQLite + output folders]
    H --> I{More files\nin folder?}
    I -->|YES| A
    I -->|NO| J[📤 Return all results\nto Streamlit frontend]
    J --> End([✅ END])
```

---

## Mandatory AI Capabilities Satisfied

| Capability | How Satisfied |
|---|---|
| ✅ Agent Loop | LangChain agent automatically loops through every ETL file in the folder |
| ✅ MCP Tool Built | ASTReaderTool — custom LangChain BaseTool wrapping both parsers |
| ✅ External API Integration | Ollama REST API called via requests at http://127.0.0.1:11434 |
