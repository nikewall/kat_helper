#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <filename.rsp>"
  exit 1
fi

input_file="$1"
test_prefix=$(basename "$input_file" .rsp) # e.g. "gcmDecrypt128"
output_root="${test_prefix}_parsed"

mkdir -p "$output_root"
log_file="$output_root/results.log"
> "$log_file" #truncate?

test_case=-1
declare -A test_data # makes a map (associative array)
declare test_case_line_num=0

# get encrypt/decrypt info from filename
mode="unknown"
if [[ "$test_prefix" =~ [E|e]ncrypt ]]; then
  mode="ENCRYPT"
elif [[ "$test_prefix" =~ [D|d]ecrypt ]]; then
  mode="DECRYPT"
fi


setup_test() {
  if (( test_case >= 0 )); then
    case_dir="$output_root/test_$test_case_line_num"
    mkdir -p "$case_dir"

    for key in "${!test_data[@]}"; do
      hex="${test_data[$key]}"
      bin_file="$case_dir/$key.bin"

      # data, convert hex -> binary
      if [[ -n "$hex" ]]; then
        echo "$hex" | xxd -r -p > "$bin_file"
      else
        # no data; create empty file
        touch "$bin_file"
      fi
    done

    run_test "$case_dir" "$test_case_line_num"
  fi

  test_data=()
}

run_test() {
  local dir="$1"
  local line_number="$2"
  local key="$dir/Key.bin"
  local iv="$dir/IV.bin"
  local aad="$dir/AAD.bin"
  local pt="$dir/PT.bin"
  local ct="$dir/CT.bin"
  local tag="$dir/Tag.bin"

  local res=""

  if [[ "$mode" == "ENCRYPT" ]]; then
    output=$(mktemp)
		# TODO: write output to ${output}

    if cmp -s "$output" "$ct"; then
      res="(line ${line_number}) - ENCRYPT OK"
    else
      res="(line ${line_number}) - ENCRYPT FAIL"
    fi

  elif [[ "$mode" == "DECRYPT" ]]; then
    output=$(mktemp)
		# TODO: write output to ${output}

    if cmp -s "$output" "$pt"; then
      res=" (line ${line_number}) - DECRYPT OK"
    else
      res=" (line ${line_number}) - DECRYPT FAIL"
    fi

  fi

  echo "$res" | tee -a "$log_file"
  rm -f "$output"
}

# main loop
#   parses file test-by-test, running each test it parses
lineno=0
while IFS= read -r line || [ -n "$line" ]; do
  (( ++lineno ))
  line=$(echo "$line" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

  if [[ -z "$line" || "$line" =~ ^\[.*\]$ ]]; then
    continue
  fi

  if [[ "$line" =~ ^Count\ *=\ *([0-9]+) ]]; then
    setup_test
    test_case="${BASH_REMATCH[1]}" # grab TC #
    test_case_line_num="$lineno"
    continue
  fi


  if [[ "$line" =~ ^([A-Za-z0-9_]+)\ *=\ *([0-9A-Fa-f]*) ]]; then
    # regex captures:
    #  1 - field name (e.g. "Key", "PT")
    #  2 - hex string (e.g. "0011223344...")
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"

    # store into our test_data map: test_data["Key"] = "001122..."
    test_data["$key"]="$value"
  fi
done < "$input_file"

# run final test parsed
setup_test
