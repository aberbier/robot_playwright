#!/usr/bin/env python3
"""
Parse Robot Framework output.xml and generate markdown reports for failed test cases.
This script extracts test metadata, execution steps, and error messages to create
bug-friendly documentation.

Cleanup unnecessary files from output/ to clean after report generation.
"""

import re
import html
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path
from datetime import datetime


class FailedTestParser:
    """Parse failed tests from Robot Framework output.xml"""

    def __init__(self):
        self.failed_tests = []

    def parse_xml(self, xml_path):
        """Parse output.xml and extract failed tests."""
        tree = ET.parse(xml_path)
        root = tree.getroot()

        for test_elem in root.iter('test'):
            test_name = test_elem.get('name')
            status_elem = test_elem.find('status')

            if status_elem is not None and status_elem.get('status') == 'FAIL':
                test_data = {
                    'name': test_name,
                    'error': self._extract_error(test_elem),
                    'keywords': []
                }

                # Extract keyword hierarchy
                self._extract_keywords(test_elem, test_data['keywords'], indent_level=0)

                self.failed_tests.append(test_data)

    def _extract_error(self, test_elem):
        """Extract error message from test."""
        # Look for msg elements with error information
        error_msgs = []
        for msg in test_elem.findall('.//msg'):
            msg_text = msg.text
            if msg_text and msg.get('level') == 'ERROR':
                error_msgs.append(msg_text)

        if error_msgs:
            return '\n'.join(error_msgs)

        # Try to find error info in status element
        status_elem = test_elem.find('status')
        if status_elem is not None:
            # Get all text content of status element
            if status_elem.text:
                return status_elem.text

        # Last resort - get all text content from the end of test
        msg_elems = list(test_elem.findall('.//msg'))
        if msg_elems:
            return msg_elems[-1].text or 'Test failed'

        return 'Test failed with unknown error'

    def _extract_keywords(self, parent_elem, keywords_list, indent_level=0):
        """Recursively extract keywords with their status and arguments."""
        # Find all direct kw children
        for kw_elem in parent_elem.findall('kw'):
            kw_name = kw_elem.get('name', 'Unknown')

            # Extract arguments
            args = []
            for arg_elem in kw_elem.findall('arg'):
                if arg_elem.text:
                    args.append(arg_elem.text)

            # Get status
            status_elem = kw_elem.find('status')
            status = status_elem.get('status', 'UNKNOWN') if status_elem is not None else 'UNKNOWN'

            keyword_data = {
                'name': kw_name,
                'args': args,
                'status': status,
                'indent': indent_level
            }
            keywords_list.append(keyword_data)

            # Process nested keywords in this keyword
            self._extract_keywords(kw_elem, keywords_list, indent_level + 1)


def sanitize_name(text):
    """Convert test name to file-friendly format."""
    text = text.lower()
    text = re.sub(r'[^a-z0-9]+', '_', text)
    text = text.strip('_')
    return text if text else 'test_case'


def load_url_base_from_resources():
    """Load ${URL_BASE} from resources/common_resource.robot if available."""
    resource_file = Path('resources') / 'common_resource.robot'
    if not resource_file.exists():
        return None

    pattern = re.compile(r'^\$\{URL_BASE\}\s{2,}(.*?)\s*$')
    for line in resource_file.read_text(encoding='utf-8').splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith('#'):
            continue
        match = pattern.match(stripped)
        if match:
            value = match.group(1).strip()
            return value if value else None

    return None


def format_keywords_as_steps(keywords):
    """Format keyword hierarchy as readable steps."""
    steps = []
    top_level_index = 1
    for kw in keywords:
        indent = "        " * kw['indent']
        args_str = " | ".join(str(arg) for arg in kw['args']) if kw['args'] else ""
        status_text = "PASS" if kw['status'] == 'PASS' else kw['status']

        prefix = ""
        if kw['indent'] == 0:
            prefix = f"{top_level_index}. "
            top_level_index += 1

        if args_str:
            step_line = f"{indent}{prefix}[{status_text}] {kw['name']} | {args_str}"
        else:
            step_line = f"{indent}{prefix}[{status_text}] {kw['name']}"

        escaped_line = html.escape(step_line)
        if kw['status'] == 'FAIL':
            steps.append(f"<span style=\"color: red;\">{escaped_line}</span>")
        else:
            steps.append(escaped_line)

    return "<br>\n".join(steps)


def generate_markdown(test_data, output_dir, url_base):
    """Generate markdown file for a failed test."""
    sanitized_name = sanitize_name(test_data['name'])
    test_folder = output_dir / 'failed_testcases' / sanitized_name
    test_folder.mkdir(parents=True, exist_ok=True)

    # Use URL_BASE extracted from resources/common_resource.robot
    base_url_text = url_base if url_base else "<not resolved>"

    # Format keywords as steps
    steps = format_keywords_as_steps(test_data['keywords'])

    # Create markdown content
    markdown_content = f"""# Failed Test Case Report

## Test Name
`{test_data['name']}`

## Base URL
```
{base_url_text}
```

## Steps of Execution
<pre>
{steps}
</pre>

## Error Encountered
```
{test_data['error']}
```

## Reproduce This Test

To reproduce this test locally and generate a trace file for debugging, run:

```bash
docker run --rm -v $(pwd):/app robot-playwright robot --outputdir output -v ENABLE_TRACE:True -t "{test_data['name']}" tests/
```

Trace file location:

`output/traces/{sanitized_name}.zip`

---
*Report generated on {datetime.now().strftime('%d-%m-%Y %H:%M:%S')} by Test Automation*
"""

    # Write markdown file
    md_file = test_folder / f"{sanitized_name}.md"
    md_file.write_text(markdown_content, encoding='utf-8')

    print(f"Created: {md_file}")


def collect_pabot_traces(output_dir):
    """Copy trace zips from pabot worker dirs into the shared output/traces folder."""
    pabot_results_dir = output_dir / 'pabot_results'
    if not pabot_results_dir.exists():
        return

    traces_dir = output_dir / 'traces'

    pabot_results_dir_list = list(pabot_results_dir.glob('*/traces/*.zip'))
    if len(pabot_results_dir_list) > 0:
        traces_dir.mkdir(parents=True, exist_ok=True)

    collected = 0
    for worker_traces in pabot_results_dir_list:
        dest = traces_dir / worker_traces.name
        shutil.copy2(worker_traces, dest)
        collected += 1

    if collected:
        print(f"Collected {collected} trace file(s) into {traces_dir}")

def remove_garbage():
    shutil.rmtree("output/pabot_results", ignore_errors=True)
    print(f"Removed output/pabot_results (if present)")

    shutil.rmtree("output/browser", ignore_errors=True)
    print(f"Removed output/browser (if present)")

def main():
    """Parse output.xml and generate markdown reports for failed tests."""
    output_dir = Path('output')
    output_xml = output_dir / 'output.xml'

    if not output_xml.exists():
        print(f"Error: {output_xml} not found. Run tests first.")
        return

    collect_pabot_traces(output_dir)
    url_base = load_url_base_from_resources()

    print(f"Parsing {output_xml}...")

    # Parse the output XML
    parser = FailedTestParser()
    parser.parse_xml(str(output_xml))

    if not parser.failed_tests:
        print("No failed tests found.")
        return

    print(f"Found {len(parser.failed_tests)} failed test(s).\n")

    # Generate markdown files
    for test_data in parser.failed_tests:
        print(f"Processing: {test_data['name']}")
        generate_markdown(test_data, output_dir, url_base)

    print(f"\nDone. Failed test reports saved to: {output_dir / 'failed_testcases'}")

    remove_garbage()

if __name__ == '__main__':
    main()
