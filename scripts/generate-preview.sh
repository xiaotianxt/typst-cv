#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <input-pdf> <output-png>" >&2
  exit 2
fi

input_pdf="$1"
output_png="$2"
output_dir="$(dirname "$output_png")"

mkdir -p "$output_dir"

if command -v gs >/dev/null 2>&1; then
  tmp_prefix="${TMPDIR:-/tmp}/typst-cv-preview-$$"
  trap 'rm -f "${tmp_prefix}.png" "${tmp_prefix}-1.png"' EXIT INT TERM
  gs -dSAFER -dBATCH -dNOPAUSE \
    -sDEVICE=png16m \
    -r300 \
    -dTextAlphaBits=4 \
    -dGraphicsAlphaBits=4 \
    -sOutputFile="${tmp_prefix}.png" \
    "$input_pdf" >/dev/null
  if [ -f "${tmp_prefix}.png" ]; then
    mv "${tmp_prefix}.png" "$output_png"
    exit 0
  fi
  if [ -f "${tmp_prefix}-1.png" ]; then
    mv "${tmp_prefix}-1.png" "$output_png"
    exit 0
  fi
  echo "ghostscript did not produce an output image" >&2
  exit 1
fi

if command -v qlmanage >/dev/null 2>&1; then
  tmp_dir="${TMPDIR:-/tmp}/typst-cv-ql-$$"
  trap 'rm -rf "$tmp_dir"' EXIT INT TERM
  mkdir -p "$tmp_dir"
  qlmanage -t -s 2000 -o "$tmp_dir" "$input_pdf" >/dev/null 2>&1
  candidate="$(find "$tmp_dir" -maxdepth 1 -type f -name '*.png' | head -n 1)"
  if [ -n "$candidate" ]; then
    mv "$candidate" "$output_png"
    exit 0
  fi
fi

if command -v sips >/dev/null 2>&1; then
  sips -s format png "$input_pdf" --out "$output_png" >/dev/null
  exit 0
fi

echo "no supported renderer found (tried gs, qlmanage, sips)" >&2
exit 1
