# Robot Framework + Playwright (Docker-Only)

This project runs Robot Framework UI tests with Playwright using Docker only.
No local Python, Robot, Browser, or Playwright setup is required on your host OS.

## What This Project Includes

- UI tests written in Robot Framework
- Shared resources for flows, actions, and locators
- Optional trace capture (`ENABLE_TRACE:True`)
- Parallel test execution with Pabot
- Post-processing script that generates markdown reports for failed tests

## Requirements

- Docker

## Project Structure

The structure below excludes folders ignored by `.gitignore` and excludes `agent_config`.

```text
.
|- Dockerfile
|- README.md
|- requirements.txt
|- resources
|  |- common_resource.robot
|  |- flows
|  |  |- flows.resource
|  |- keywords
|  |  |- actions.resource
|  |- locators
|     |- locators.resource
|- scripts
|  |- pipeline_post_automation_script.py
|- tests
   |- sample_test_suite.robot
   |- test_with_failure.robot
```

## Quick Start

### 1. Build the image

```bash
docker build -t robot-playwright .
```

### 2. Run all tests

```bash
docker run --rm \
  -v $(pwd):/app \
  robot-playwright \
  robot --outputdir output tests/
```

### 3. Run tests with trace enabled

```bash
docker run --rm \
  -v $(pwd):/app \
  robot-playwright \
  robot --outputdir output --variable ENABLE_TRACE:True tests/
```

### 4. Run tests in parallel (Pabot)

```bash
docker run --rm \
  -v $(pwd):/app \
  robot-playwright \
  pabot --processes 5 --outputdir output tests/
```

### 5. Generate failed test markdown reports

```bash
docker run --rm \
  -v $(pwd):/app \
  robot-playwright \
  python3 scripts/pipeline_post_automation_script.py
```

## Recommended End-to-End Flow

```bash
docker build -t robot-playwright .
docker run --rm -v $(pwd):/app robot-playwright pabot --processes 5 --outputdir output --variable ENABLE_TRACE:True tests/
```

## Output Artifacts

- `output/output.xml`: canonical Robot result file
- `output/log.html`: Robot execution log
- `output/report.html`: Robot summary report
- `output/traces`: consolidated trace zip files
- `output/failed_testcases`: markdown reports per failed test
