# free-space

Reclaim disk space on macOS by clearing caches that tools rebuild on demand.

```sh
./free-space.sh        # dry run: show what would be freed
./free-space.sh --yes  # delete
```

## What it cleans

| Group            | Targets                                                        |
| ---------------- | -------------------------------------------------------------- |
| JavaScript       | npm cache, `pnpm store prune`, pnpm/bun/yarn caches            |
| Python           | `uv cache clean`, pip cache                                    |
| JVM              | `~/.gradle/caches`, NetBeans cache                             |
| Homebrew         | `brew cleanup --prune=all -s`                                  |
| Xcode            | DerivedData, simulator caches, unavailable simulators          |
| Headless browsers| puppeteer and playwright browser downloads                     |
| Editors          | VS Code caches                                                 |
| Apps             | everything in `~/Library/Caches`, `~/Library/Logs`             |

## What it never touches

Downloads, Documents, Desktop, Docker images/volumes, Hugging Face models,
`node_modules` in your projects, browser profiles, or the Trash.

## Notes

- Next install/build after cleaning is slower while caches refill.
- Quit heavy apps (browsers, IDEs) first for best results.
- Run `ncdu ~` or `du -sh ~/* | sort -rh` to find what else is big.

## License

MIT

## Claude Code skill

`skills/free-space/SKILL.md` teaches Claude Code to run this script and then
hunt for more space (Docker, old `node_modules`, Downloads, snapshots, models),
asking before deleting anything you created. Install it globally:

```sh
ln -s "$PWD/skills/free-space" ~/.claude/skills/free-space
```

Then say "limpia el espacio" or "free up disk space".
