"""Unit tests for the splash screen JavaScript (splash.js).

The JS suite runs under Vitest in a jsdom environment (see tests/js/).
This wrapper runs it from pytest so that `uv run pytest` - the documented
"before you push" command - runs both suites. It delegates to
scripts/run_js_tests.sh, the same entry point the pre-commit hook uses,
under the node runtime pinned in package.json.
"""

import shutil
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
JS_SUITE_SCRIPT = REPO_ROOT / "scripts" / "run_js_tests.sh"


def _npm_available() -> bool:
    """npm must be on PATH to bootstrap the pinned node runtime."""
    return shutil.which("npm") is not None


@pytest.mark.skipif(
    not _npm_available(),
    reason="npm is required to run the JS unit tests "
    "(it installs the node runtime pinned in package.json)",
)
def test_js_unit_suite() -> None:
    """Run the Vitest suite for pikaraoke/static/js/splash.js."""
    subprocess.run(
        [str(JS_SUITE_SCRIPT)],
        cwd=REPO_ROOT,
        check=True,
    )
