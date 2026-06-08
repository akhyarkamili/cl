# cl

A small wrapper around `claude -p` that I keep on my `PATH`.

It exists so I can fire off a one-shot Claude prompt from the shell without
typing the same flags every time. 

## What it does

`cl` runs `claude -p` with a few defaults:

- `--model sonnet`
- `--effort low`
- `--dangerously-skip-permissions`

Any other flags I pass are forwarded to `claude`, and I can override the
defaults:

- pass `--model` / `--effort` explicitly to override those defaults
- pass `--safe` to keep normal permission checks (it's consumed, not forwarded)
- pass `-j` for `--output-format json`

## Usage

```bash
cl summarize this repo
cl --model opus deep review        # override the sonnet default
cl --effort high tricky question   # override the low default
cl --safe do something sensitive   # keep normal permission checks
```

## Install

```bash
chmod +x cl
mv cl ~/bin/   # or anywhere on your PATH
```
