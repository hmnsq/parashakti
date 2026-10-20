# Parashakti

Parashakti puts software into your language and proves it still works. Point it at any Git repository: it ingests the
whole tree into any of Hindawi's languages (keywords, numerals, and names through a dictionary), checks that the result
converts back to the original byte for byte, lowers it through the original Hindawi pipeline, builds it, runs it, and
compares what it prints with the English build. What it cannot translate yet is reported, with a ready-made issue to file.

© 1993–2026 Abhishek Choudhary. All rights reserved. AyeAI. Parashakti™ and Hindawi™ are his trademarks.

## Install

On Linux with git and python3, download `parashakti.sh` and install it as a command:

```
bash parashakti.sh --self-install          puts `parashakti` in ~/.local/bin
parashakti --check                         what this machine has, each probe limited in time; nothing installed
parashakti --install                       installs what is missing, one package at a time
```

Or, with Docker, `bash parashakti_docker.sh` runs it in a container that already has every tool (your GitHub login is
handed in). `parashakti --help` lists every option.

## Use

```
parashakti https://gitlab.com/OWNER/REPO --langs urdu,tamil
        any Git repository (GitHub, GitLab, Bitbucket, your own server): ingested into each language, checked byte for
        byte, lowered, built with its own build system (found by itself), and reported
parashakti ./my-project --run ./my-program --expect "ok"
        a local folder, Git or plain, built, run and compared with its English build
parashakti URL --steps ingest,check,report
        only ingestion and the report: what is in the language, what is pending, and an issue to file
parashakti --list | --stage shakti-sdk,xv6 --langs hindi,telugu
        the built-in stack, layer by layer, or some of its projects
parashakti --fork-all --publish
        every upstream forked into hmnsq, then each verified language published there as a branch
parashakti --stop | --status | --reset
        stop, see progress, or start again; a rerun resumes where it stopped
```

The stack, layer by layer: the SHAKTI SDK, OpenSBI and U-Boot (firmware), QEMU (the machine), xv6, MINIX and Linux
(operating systems), BusyBox, newlib and wasm3 (runtime), binutils, TinyCC, GCC and LLVM (toolchains), and llama.cpp,
llm.c, darknet, PyTorch, Caffe and TensorFlow (AI). In a terminal with tmux, a run shows itself, htop and its status.

## What is shown, and what is not yet

| Claim | State |
|---|---|
| SHAKTI bare metal and xv6, built from Urdu, Tamil and Hindi, booted on QEMU | verified |
| xv6 in Urdu converts back to upstream in all 65 C files and prints what the English build prints | verified |
| darknet, built from Urdu: 118 of 118 C files convert back, same output as English | verified |
| Any repository or local folder: ingestion, reversal check, pending-word report and issue link | verified on xv6 (Urdu, Telugu) |
| A local project built by its own Makefile, found by itself, run and compared with English | verified (Urdu, Tamil) |
| Publishing a language as a branch of a fork | rehearsed into a local repository |
| The SHAKTI SDK, OpenSBI, U-Boot, QEMU, binutils, MINIX, Linux, GCC, LLVM, llama.cpp inference, llm.c training | defined, not yet run |

The process: [docs/PROCESS.md](docs/PROCESS.md). Hindawi itself: https://github.com/hindawiai/hindawi2026.10
