#!/usr/bin/env bats

# Tests using the Bats testing framework
# https://github.com/bats-core/bats-core

# Add some test debug from https://github.com/bats-core/bats-core/issues/199
#load teardown

ROOT_MISSPELLING_COUNT=5
FILENAME_MISSPELLING_COUNT=1
HIDDEN_MISSPELLING_COUNT=1
EXCLUDED_MISSPELLING_COUNT=1
BUILTIN_NAMES_MISSPELLING_COUNT=1
IGNORE_WORDS_MISSPELLING_COUNT=6
SUBFOLDER_MISSPELLING_COUNT=1
# From all files called example.txt
EXAMPLE_MISSPELLING_COUNT=5

export RUNNER_TEMP="/foo/runner_temp"

# This function runs before every test
function setup() {
    # Simulate the Dockerfile COPY command
    [ -d "${RUNNER_TEMP}/code/" ] || sudo mkdir -p ${RUNNER_TEMP}/code/
    [ -f "${RUNNER_TEMP}/code/codespell-matcher.json" ] || sudo cp codespell-problem-matcher/codespell-matcher.json ${RUNNER_TEMP}/code/
    #ls -alR ${RUNNER_TEMP}/code/
    [ -d "/code/" ] || sudo mkdir -p /code/
    [ -f "/code/codespell-matcher.json" ] || sudo cp codespell-problem-matcher/codespell-matcher.json /code/
    #ls -alR /code/
    [ -d "/github/workflow/" ] || sudo mkdir -p /github/workflow/ && sudo chmod 777 /github/workflow/
    # Add a random place BATS tries to put it
    #ls -alR /github/workflow/

    # Set default input values
    export INPUT_CHECK_FILENAMES=""
    export INPUT_CHECK_HIDDEN=""
    export INPUT_EXCLUDE_FILE=""
    export INPUT_SKIP=""
    export INPUT_BUILTIN=""
    export INPUT_IGNORE_WORDS_FILE=""
    export INPUT_IGNORE_WORDS_LIST=""
    export INPUT_PATH="./test/testdata"
    export INPUT_ONLY_WARN=""
}

@test "Run with defaults" {
    errorCount=$((ROOT_MISSPELLING_COUNT + SUBFOLDER_MISSPELLING_COUNT))
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]

    # Check output
    echo "Line 1"
    echo ${lines[1]}
    echo "Output:"
    echo "$output"
    [ "${lines[2]}" == "::add-matcher::${RUNNER_TEMP}/_github_workflow/codespell-matcher.json" ]
    outputRegex="^Running codespell on '${INPUT_PATH}'"
    [[ "${lines[3]}" =~ $outputRegex ]]
    [ "${lines[-3]}" == "Codespell found one or more problems" ]
    [ "${lines[-2]}" == "::remove-matcher owner=codespell-matcher-default::" ]
    [ "${lines[-1]}" == "::remove-matcher owner=codespell-matcher-specified::" ]
    [ "${lines[1]}" == "$errorCount" ]
}

@test "Check file names" {
    errorCount=$((ROOT_MISSPELLING_COUNT + SUBFOLDER_MISSPELLING_COUNT + FILENAME_MISSPELLING_COUNT))
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_CHECK_FILENAMES=true
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Check a hidden file" {
    errorCount=$HIDDEN_MISSPELLING_COUNT
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_CHECK_HIDDEN=true
    INPUT_PATH="./test/testdata/.hidden"
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Check a hidden file without INPUT_CHECK_HIDDEN set" {
    errorCount=0
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_PATH="./test/testdata/.hidden"
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Use an exclude file" {
    errorCount=$((ROOT_MISSPELLING_COUNT + SUBFOLDER_MISSPELLING_COUNT - EXCLUDED_MISSPELLING_COUNT))
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_EXCLUDE_FILE="./test/exclude-file.txt"
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Check the skip option" {
    errorCount=$((ROOT_MISSPELLING_COUNT + SUBFOLDER_MISSPELLING_COUNT - EXAMPLE_MISSPELLING_COUNT))
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_SKIP="example.txt"
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Use an additional builtin dictionary" {
    errorCount=$((ROOT_MISSPELLING_COUNT + HIDDEN_MISSPELLING_COUNT + SUBFOLDER_MISSPELLING_COUNT + BUILTIN_NAMES_MISSPELLING_COUNT))
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_BUILTIN="clear,rare,names"
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Use an ignore words file" {
    errorCount=$((ROOT_MISSPELLING_COUNT + HIDDEN_MISSPELLING_COUNT + SUBFOLDER_MISSPELLING_COUNT - IGNORE_WORDS_MISSPELLING_COUNT))
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_IGNORE_WORDS_FILE="./test/ignore-words-file.txt"
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Use an ignore words list" {
    errorCount=$((ROOT_MISSPELLING_COUNT + HIDDEN_MISSPELLING_COUNT + SUBFOLDER_MISSPELLING_COUNT - IGNORE_WORDS_MISSPELLING_COUNT))
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_IGNORE_WORDS_LIST="abandonned"
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Custom path" {
    errorCount=$((SUBFOLDER_MISSPELLING_COUNT))
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_PATH="./test/testdata/subfolder"
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}

@test "Only warn" {
    errorCount=0
    # codespell's exit status is 0, or 65 if there are errors found
    if [ $errorCount -eq 0 ]; then expectedExitStatus=0; else expectedExitStatus=65; fi
    INPUT_ONLY_WARN=true
    run "./entrypoint.sh"
    [ $status -eq $expectedExitStatus ]
}
