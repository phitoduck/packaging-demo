#!/bin/bash

# fail on error
set -ex

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function release {
    clean
    build
    publish:test
    publish:prod
}

function build {
    python -m build --wheel --sdist "$THIS_DIR"
}

# test.pypi.org
function publish:test {
    load-dotenv
    twine upload dist/* \
        --repository testpypi \
        --username __token__ \
        --password $TEST_PYPI_TOKEN \
        --verbose
}

# pypi.org
function publish:prod {
    load-dotenv
    twine upload dist/* \
        --username __token__ \
        --password $PROD_PYPI_TOKEN \
        --verbose
}

function install {
    pip install --editable "$THIS_DIR"
}

function start {
    echo "start task not implemented"
}

function default {
    start
}

function clean {
    find . \
        -name "node_modules" -prune -false \
        -o -name "venv" -prune -false \
        -o -name ".git" -prune -false \
        -type d -name "*.egg-info" \
        -o -type d -name "dist" \
        -o -type d -name ".projen" \
        -o -type d -name "build_" \
        -o -type d -name "build" \
        -o -type d -name "cdk.out" \
        -o -type d -name ".mypy_cache" \
        -o -type d -name ".pytest_cache" \
        -o -type d -name "test-reports" \
        -o -type d -name "htmlcov" \
        -o -type d -name ".coverage" \
        -o -type d -name ".ipynb_checkpoints" \
        -o -type d -name "__pycache__" \
        -o -type f -name "coverage.xml" \
        -o -type f -name ".DS_Store" \
        -o -type f -name "*.pyc" \
        -o -type f -name "*cdk.context.json" | xargs rm -rf {}
}

function load-dotenv {
    while read -r line; do
        export "$line" || true
    done < "$THIS_DIR/.env"
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-default}