#!/bin/bash
set -e

echo "Starting mainframe_operations.sh"

echo "Checking Java..."
java -version

if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is empty"
  exit 1
fi

echo "Going to local COBOL Check directory..."
cd cobol-check || {
  echo "ERROR: local cobol-check directory not found"
  exit 1
}

echo "Current directory:"
pwd
ls -al

echo "Making test runner executable..."
chmod +x scripts/linux_gnucobol_run_tests || true

echo "Checking COBOL Check jar..."
ls -al bin

COBOLCHECK_JAR=$(ls bin/cobol-check-*.jar | head -1)

if [ -z "$COBOLCHECK_JAR" ]; then
  echo "ERROR: COBOL Check jar not found"
  exit 1
fi

echo "Using COBOL Check jar: $COBOLCHECK_JAR"

run_cobolcheck() {
  program=$1

  echo "======================================"
  echo "Running COBOL Check for $program"
  echo "======================================"

  java -jar "$COBOLCHECK_JAR" -p "$program" || true

  echo "COBOL Check completed for $program"

  if [ -f "CC##99.CBL" ]; then
    echo "Found CC##99.CBL for $program"
  else
    echo "WARNING: CC##99.CBL not found for $program"
  fi
}

for program in NUMBERS EMPPAY DEPTPAY
do
  run_cobolcheck "$program"
done

echo "Mainframe operations completed"
