#!/usr/bin/env bash

grep -B 1 '<failure ' build/test-report.xml |
  grep testcase |
  cut -d'"' -f2,4 |
  tr '"' '#'
