# Test Cases — LENS ETL Script Documentation Generator

---

## Test Case 1 — Python ETL Parser

**Component:** `parser/python_parser.py`
**Test File:** `etl_samples/sample_orders.py`

| Field | Details |
|---|---|
| Input | `etl_samples/sample_orders.py` |
| Expected Sources | `['data/orders.csv']` |
| Expected Targets | `['big_orders']` |
| Expected Transformations | `['filter/condition', 'rename', 'new column: processed']` |
| Actual Output | ✅ Matched expected output |
| Status | PASS |

---

## Test Case 2 — Python ETL Parser (Multi Source)

**Component:** `parser/python_parser.py`
**Test File:** `etl_samples/sample_hr.py`

| Field | Details |
|---|---|
| Input | `etl_samples/sample_hr.py` |
| Expected Sources | `['data/employees.csv', 'data/attendance.csv']` |
| Expected Targets | `['hr_report']` |
| Expected Transformations | `['merge', 'filter/condition', 'new column: bonus']` |
| Actual Output | ✅ Matched expected output |
| Status | PASS |

---

## Test Case 3 — SQL ETL Parser

**Component:** `parser/sql_parser.py`
**Test File:** `etl_samples/sample_sales.sql`

| Field | Details |
|---|---|
| Input | `etl_samples/sample_sales.sql` |
| Expected Sources | `['orders', 'customers']` |
| Expected Targets | `['sales_summary']` |
| Expected Transformations | `['join', 'where', 'count', 'sum']` |
| Actual Output | ✅ Matched expected output |
| Status | PASS |

---

## Test Case 4 — MCP Tool (Valid Python File)

**Component:** `mcp_tool/ast_reader_tool.py`

| Field | Details |
|---|---|
| Input | `etl_samples/sample_orders.py` |
| Expected Output | JSON with file, type, sources, targets, transformations |
| Actual Output | ✅ Correct JSON returned |
| Status | PASS |

---

## Test Case 5 — MCP Tool (Valid SQL File)

**Component:** `mcp_tool/ast_reader_tool.py`

| Field | Details |
|---|---|
| Input | `etl_samples/sample_sales.sql` |
| Expected Output | JSON with file, type, sources, targets, transformations |
| Actual Output | ✅ Correct JSON returned |
| Status | PASS |

---

## Test Case 6 — MCP Tool (Invalid File)

**Component:** `mcp_tool/ast_reader_tool.py`

| Field | Details |
|---|---|
| Input | `etl_samples/nonexistent.py` |
| Expected Output | `{"error": "File not found: etl_samples/nonexistent.py"}` |
| Actual Output | ✅ Correct error JSON returned |
| Status | PASS |

---

## Test Case 7 — Ollama LLM Connection

**Component:** `ai/llm_client.py`

| Field | Details |
|---|---|
| Input | Simple test prompt sent to Ollama |
| Expected Output | Non-empty string response from Llama3 |
| Actual Output | ✅ Plain English response received |
| Status | PASS |

---

## Test Case 8 — Documentation Generator

**Component:** `ai/doc_generator.py`
**Test File:** `etl_samples/sample_orders.py`

| Field | Details |
|---|---|
| Input | Parsed metadata from sample_orders.py |
| Expected Output | Markdown documentation explaining what the script does |
| Actual Output | ✅ Plain English Markdown documentation generated |
| Status | PASS |

---

## Test Case 9 — Business Purpose Explainer

**Component:** `ai/business_explainer.py`
**Test File:** `etl_samples/sample_hr.py`

| Field | Details |
|---|---|
| Input | Parsed metadata from sample_hr.py |
| Expected Output | 2-3 sentence business purpose explanation |
| Actual Output | ✅ Business context explanation generated |
| Status | PASS |

---

## Test Case 10 — Graphviz Flow Diagram

**Component:** `diagram/flow_diagram.py`
**Test File:** `etl_samples/sample_orders.py`

| Field | Details |
|---|---|
| Input | Parsed metadata from sample_orders.py |
| Expected Output | PNG diagram saved to output/diagrams/ |
| Actual Output | ✅ PNG diagram generated with green sources, blue transformations, orange targets |
| Status | PASS |

---

## Test Case 11 — Impact Analysis

**Component:** `impact/impact_analysis.py`
**Test Files:** All three sample ETL files

| Field | Details |
|---|---|
| Input | All ETL files in etl_samples/ folder |
| Expected Output | Dependency graph showing downstream impact for each file |
| Actual Output | ✅ NetworkX graph built — impact list returned with severity |
| Status | PASS |

---

## Test Case 12 — Environment Verification

**Component:** `test_env.py`

| Field | Details |
|---|---|
| Input | Run test_env.py |
| Expected Output | All 14 packages verified, Ollama running, Graphviz working |
| Actual Output | ✅ ALL CHECKS PASSED |
| Status | PASS |

---

## Test Case 13 — Unsupported File Type

**Component:** `mcp_tool/ast_reader_tool.py`

| Field | Details |
|---|---|
| Input | A .txt file path |
| Expected Output | `{"error": "Unsupported file type: .txt"}` |
| Actual Output | ✅ Correct error message returned |
| Status | PASS |

---

## Summary

| Total Test Cases | Passed | Failed |
|---|---|---|
| 13 | 13 | 0 |