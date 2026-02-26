# Zsh Startup Performance Changes (2026-02-06)

Startup time: 2.68s → ~0.72s → target ~0.3s

## Backups

- `~/.zshrc.backup-2026-02-06`
- `~/bashrc_dir/.zshrc.backup-2026-02-06`

To fully revert:
```bash
cp ~/.zshrc.backup-2026-02-06 ~/.zshrc
cp ~/bashrc_dir/.zshrc.backup-2026-02-06 ~/bashrc_dir/.zshrc
```

---

## Change 1: nvm → fnm (saved ~1.04s)

**What changed:** Replaced nvm.sh + load-nvmrc chpwd hook with `eval "$(fnm env --use-on-cd --shell zsh)"`.

**Why:** nvm.sh is a massive bash script (~5000 lines). fnm is a compiled Rust binary that starts in ~5ms.

**If something breaks:**
- `fnm install <version>` to install a missing node version
- fnm reads `.nvmrc` files natively via `--use-on-cd`
- Old nvm versions still exist at `~/.nvm/versions/node/` if needed
- To revert: replace the `eval "$(fnm env ...)"` line with:
  ```zsh
  export NVM_DIR=~/.nvm
  source "$(brew --prefix nvm)/nvm.sh"
  ```
  and restore the load-nvmrc function from the backup

**fnm default:** v24.12.0 (matches old nvm default). Also installed: v25.5.0.

---

## Change 2: Lazy-load pyenv (saves ~240ms)

**What changed:** Replaced eager `eval "$(pyenv init -)"` + `eval "$(pyenv virtualenv-init -)"` with wrapper functions that defer initialization until first use of `pyenv`, `python`, `python3`, `pip`, or `pip3`.

**How it works:** The shims directory (`$PYENV_ROOT/shims`) is added to PATH immediately so version-managed binaries resolve. The full pyenv shell integration (rehash, completions, virtualenv hooks) only loads when you explicitly call one of the wrapped commands.

**If something breaks:**
- If a python script doesn't trigger lazy load (e.g. called via shebang), the shims PATH handles it
- If pyenv completions are missing, run `pyenv` once to trigger the lazy load
- To revert: replace the lazy-load block with:
  ```zsh
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  ```

---

## Change 3: Cache thefuck aliases (saves ~210ms)

**What changed:** Replaced two `eval "$(thefuck --alias ...)"` calls (each spawns Python) with `source ~/.cache/thefuck-aliases.zsh`.

**Cache file:** `~/.cache/thefuck-aliases.zsh`

**If something breaks:**
- Regenerate the cache: `thefuck --alias FUCK > ~/.cache/thefuck-aliases.zsh && thefuck --alias fuck >> ~/.cache/thefuck-aliases.zsh`
- After upgrading thefuck: regenerate the cache
- To revert: replace the `source` line with:
  ```zsh
  eval "$(thefuck --alias FUCK)"
  eval "$(thefuck --alias fuck)"
  ```

---

## Change 4: Cache compinit with zcompdump (saves ~200ms+)

**What changed:** In `~/.zshrc`, replaced `autoload -U compinit && compinit` with a version that only does a full rebuild if `~/.zcompdump` is older than 24 hours. Otherwise uses `compinit -C` (skip security check, use cached dump).

**How it works:** `compinit -C` skips scanning all fpath directories and checking file permissions. The `(#qN.mh+24)` glob qualifier checks if the file was modified more than 24 hours ago.

**If completions seem stale:**
- `rm ~/.zcompdump && exec zsh` forces a full rebuild
- Or just wait 24 hours for the automatic refresh

**If something breaks:**
- To revert: replace the if/else block with:
  ```zsh
  autoload -U compinit && compinit
  ```

---

## Change 5: Hardcode brew --prefix (saves ~24ms)

**What changed:** Replaced `$(command brew --prefix)` with `/opt/homebrew` for the HELPDIR variable.

**If something breaks:**
- Only matters if Homebrew moves from `/opt/homebrew` (unlikely on Apple Silicon)
- To revert: `HELPDIR=$(command brew --prefix)/share/zsh/help`

---

## Measuring startup time

```bash
# Quick measurement
/usr/bin/time zsh -i -c exit

# Detailed profile
zsh -c 'zmodload zsh/zprof; source ~/.zshrc; zprof'
```
