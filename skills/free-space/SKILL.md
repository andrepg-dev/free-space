---
name: free-space
description: Free disk space on macOS. Use when the user says "limpia el espacio", "libera espacio", "libera memoria", "disk full", "no space left", "free up space", or the disk is near full. Clears regenerable caches with free-space.sh, then hunts for more space and asks before touching user data.
---

# Free disk space (macOS)

"Memoria" here means disk storage, not RAM.

## 1. Measure

```sh
df -h /System/Volumes/Data
```

Report free space before starting. If under ~1 GB, act fast: caches first, investigate later.

## 2. Clear regenerable caches (no need to ask)

Run the script from this repo. Dry run first, then apply:

```sh
./free-space.sh          # shows sizes
./free-space.sh --yes    # deletes
```

If the script is not at hand, it is at https://github.com/andrepg-dev/free-space. It covers npm, pnpm, bun, yarn, uv, pip, gradle, NetBeans, Homebrew, Xcode DerivedData, simulator caches, puppeteer/playwright browsers, VS Code caches, `~/Library/Caches` and `~/Library/Logs`.

## 3. Investigate further (take initiative)

Don't stop at the script. Look for the biggest remaining offenders:

```sh
du -sh ~/* ~/.[!.]* 2>/dev/null | sort -rh | head -25
du -sh ~/Library/* 2>/dev/null | sort -rh | head -15
du -sh ~/Library/Application\ Support/* 2>/dev/null | sort -rh | head -15
du -sh ~/Library/Containers/* 2>/dev/null | sort -rh | head -15
```

Known places worth checking:

| Where | How | Ask first? |
| --- | --- | --- |
| Docker | `docker system df`, then `docker system prune -a` / `docker builder prune` | Yes (images/volumes) |
| Old `node_modules`, `.next`, `target`, `build`, `.venv` in projects | `find ~/src -name node_modules -type d -prune -mtime +30` | Yes, list them |
| Trash | `~/.Trash` | Yes |
| Time Machine local snapshots | `tmutil listlocalsnapshots /`, `tmutil thinlocalsnapshots / 999999999999 4` | No (system rebuilds) |
| Xcode | `~/Library/Developer/Xcode/{Archives,iOS DeviceSupport}`, `xcrun simctl delete unavailable` | Archives: yes |
| iOS backups | `~/Library/Application Support/MobileSync/Backup` | Yes |
| ML models | `~/.cache/huggingface`, `~/.ollama/models`, LM Studio | Yes |
| Other tool caches | `~/.cache/*`, `~/.cargo/registry`, `~/go/pkg/mod`, `~/.m2/repository`, `~/.conda/pkgs`, CocoaPods, Flutter/pub, Android SDK system images | Usually no, they are caches |
| Electron app caches | `~/Library/Application Support/*/Cache`, `*/Code Cache`, `*/GPUCache` | No |
| Mail / Messages attachments | `~/Library/Mail`, `~/Library/Messages/Attachments` | Yes |

## Rules

- Caches and logs: delete without asking.
- Anything the user created or downloaded (files, models, images, backups, volumes, projects): show sizes and ask.
- Never touch `~/Downloads`: do not delete, move, or even propose cleaning it. User rule, no exceptions.
- Never delete browser profiles, keychains, `~/Documents`, `~/Desktop`, or source code.
- Docker: never prune volumes (they hold database data). Stopped containers and unused images are fine.
- If you find a new safe cache worth automating, add it to `free-space.sh` in a small commit.
- Finish by reporting free space before -> after.
