#!/bin/bash
# Wrapper for compatibility: calls remove_students.sh with the same arguments

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/remove_students.sh" "$@"
