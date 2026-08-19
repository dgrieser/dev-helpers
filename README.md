# dev-helpers

Collection of git helper scripts for everyday workflows across GitHub and GitLab.

## Install

```bash
sudo make install            # copy scripts to /usr/local/bin and bash completions
sudo make install-links      # symlink scripts and completions back to this repo
sudo make uninstall          # remove installed files
make list                    # show targets and available commands
make list-install            # show install destination
```

Bash completions (`completions/dev-helpers`) are installed to
`/usr/local/share/bash-completion/completions`, one entry per command, so
bash-completion lazy-loads them on first tab. Flags, subcommands, and
contextual values (branches, tags, projects, changed files) are completed.
[git-color](#git-color) takes a git command line, so behind its own options it
hands over to git's own completion (loading it if the shell has not yet).

Aliases and wrapper functions don't trigger lazy loading, so to complete them
source the stable-named copy from your shell rc after defining the aliases:

```bash
source /usr/local/share/bash-completion/completions/dev-helpers
__dh_register_aliases                    # auto-map aliases to git-* commands
__dh_complete_alias g git-find-repo      # map wrapper functions explicitly
```

## Tools

### git-activity-to-issue
Resolve GitLab activity feed items to issue references.
```bash
git-activity-to-issue
```

### git-add
Interactive fuzzy stager: stage/unstage/delete/reset/ignore files and resolve conflicts via picker.

Every key but `ctrl-d` and `enter` acts inside the picker, so the screen is not torn
down and rebuilt on every key press: staging, unstaging, deleting, resetting and
ignoring reload the list in place, `ctrl-e` and `alt-v` hand the terminal to the
editor or to vimdiff and come back to the same picker. The search query survives,
so files can be worked through key press by key press, and the cursor returns to
the first entry, which is where the sort puts whatever is next to act on. A refused
action, such as staging a file whose conflict markers are still in it, is reported
above the header until the next key press. `ctrl-d` prints the diff and `enter` the
selected path, so both end the picker.
```bash
git-add [-p] [<path>...] [-s <path>] [-u <path>] [-d <path>] [-r <path>] [-i <path>] [-q <query>]
```

### git-blame
Interactive blame picker. Lines are listed as LVL / AGE / AUTHOR / LINE / CODE
and the preview shows the commit that last touched the selected line with its
stat and patch, limited to that file. Without a file a picker lists the tracked
files first.

`enter` blames the file again as it was before the commit of the selected line,
so a line can be walked change by change; renames are followed and the file is
blamed under the name it had back then. LVL is the depth of that walk, `1` for
the blame of the file itself, and a `^` next to it marks a line whose commit has
nothing before it - `enter` stays where it is on those. A dimmed row is a line
that is not committed yet. `esc` and `backspace` leave a nested level and return
to the previous blame; on the first level `backspace` stays the key that erases
the search query.

`ctrl-s` shows the commit, `ctrl-d` its diff for the file, `ctrl-l` the history
of that single line (`git log -L`), `ctrl-c` copies the hash, `ctrl-o` opens the
commit in the browser, `alt-v` opens the file before and after the commit in
vimdiff, `alt-e` opens the file in the editor at that line, and `alt-p` writes
the commit's diff for the file as a patch.

All of those but the two that return something on stdout - copying the hash and
writing a patch - act inside the picker: the pager, vimdiff and the editor get the
terminal handed over and come back to the same picker, and the browser is opened
without touching the screen. Only the editor reloads the blame afterwards, since
it is the only one that writes the file the blame is of.

No row of the blame names the file it is of, so the footer leads with it, followed
by `@<rev>` once the blame is of a revision instead of the working tree - the LVL
column counts how deep a walk went, the footer says where it arrived. The file
picker names the revision the same way.
```bash
git-blame [--print] [-q <query>] [-r <ref>] [-L <range>] [-w] [-M] [-C] \
          [--ignore-rev <rev>] [--ignore-revs-file <file>] [-o <dir>] \
          [--] [<file>]
```

### git-branch
Create/checkout a branch, or delete/reset/backup it (with confirmation).
```bash
git-branch [--delete] [--reset] [--backup] [-y|--yes] [BRANCH_NAME]
```

### git-branch-from-tag
Create a branch starting from an existing tag.
```bash
git-branch-from-tag [<tag>]
```

### git-browse
Open the current repo (and optionally a branch, file or line range) in the browser.

`--interactive` asks for the ref, picks the file and then offers to mark a line
or a range in it; `--branch`, `<path>` and `--lines` each skip their step. In the
line picker `tab` marks a line, `shift-tab` marks everything between the marks
and the cursor, so a range is a `tab` on its first line and a `shift-tab` on its
last one. Marking nothing links the line under the cursor. Once the query is gone
the picker scrolls back to the line that was marked last.
```bash
git-browse [-p|--print] [--host-only] [--include-branch] [-i|--interactive] \
           [-b|--branch <ref>] [-L|--lines <range>] [--] [<path>]
```

### git-change
Switch to a different branch.
```bash
git-change <branch>
```

### git-checkout
Checkout given branch, default branch if none, or `-` for previous.
```bash
git-checkout [BRANCH]
```

### git-clone
Clone a repo; reads URL from arg, clipboard, or prompt.
```bash
git-clone <git url>
```

### git-color
Run a git command and paint its output.

Every argument is passed to git unchanged, so it is used like git itself. git's
own coloring is turned off (and any escape sequence that still arrives is
stripped), so the whole output is repainted from one palette: refs are purple
and paths blue, commit hashes, URLs, commit messages and file modes each get
their own color, `->` becomes `→`, statistics are green with a darker green unit
while `changed`, `insertions` and `deletions` take the color of the status word
they count, `(+)` and `(-)` are green and red, status words are colored by what
happened to the file, and the punctuation that is not part of a path or a ref
fades back.

A commit subject stays italic throughout, and a conventional one is taken apart:
in `feat(references): add a tool for cross references` the type and the scope get
a color each, the brackets, the `!` of a breaking change and the colon fade back,
and the text behind the colon keeps the subject color. The type has to be one of
the conventional ones (`build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`,
`refactor`, `revert`, `style`, `test`, `wip`), so any other subject is left as
one span.

Which of the two a name is comes from the line it stands in. Where the line does
not say, the shape decides: a ref namespace like `refs/` or a remote prefix like
`origin/` reads as a ref, a file extension or a directory as a path, and a bare
word as a ref. Inside the dimmed advice git appends to its output, e.g. `(use
"git add <file>..." to include in what will be committed)`, both stay grey and
only step a shade out of the advice around them, so the hint stays a hint.

The text itself is only rewritten where it costs no column, so everything git
lined up stays lined up: the arrow glyphs, the `|` of a diffstat, which becomes
`│`, and the subject of a commit summary, which moves below the `[branch hash]`
it would otherwise trail.

Both output streams are painted, because git splits its output between them,
e.g. push reports its progress on stderr. Commands that page their output are
paged the same way git pages them (`less` by default, `$GIT_PAGER`/`$PAGER`
otherwise), an editor a command opens is reconnected to the terminal, and
commands that drive the terminal themselves (`git add -p`, `git mergetool`,
`git rebase -i`, ...) are handed to git untouched.

The palette is resolved per role from `GIT_COLOR_<ROLE>`, then from the shared
`COLOR_*` theme of cli-helpers, then from the built-in default, so a themed
shell stays in charge of the look. `--help` lists the roles.

The other commands here route the git output they show through it, so their
`git` calls stay plain wherever the output is read back and parsed. Each script
wraps it the same way it wraps `git`, i.e. with the color forced on:

```bash
git-color() { command git-color --color=always "$@"; }
```
```bash
git-color [--color auto|always|never] [--pager auto|always|never] [--raw] \
          [--] <git-command> [<args>...]
```

### git-container
List, inspect, filter, delete GitLab container registry tags for current repo.
```bash
git-container <check|list|delete> [ID] [-n <name>] [-t <tag>] [-o txt|json]
```

### git-create
Create a new GitLab repo under `$WORKSPACE` via `glab`.
```bash
git-create
```

### git-default
Print the name of the default remote branch.
```bash
git-default [--fqn]
```

### git-diff
Show diff of HEAD plus untracked files, or against a branch; optional vimdiff.
```bash
git-diff [-p|--path PATH] [-v|--vim] [BRANCH]
```

### git-find-repo
Print the path of a repo under `$WORKSPACE` by name, `name#parent` qualifier, relative path, or git URL; `-` jumps to the previous repo from history. Clones missing repos unless disabled. GitLab MR (`/-/merge_requests/<id>`) and branch (`/-/tree/<branch>`) URLs also check out and pull the referenced branch unless disabled; a bare or `!`-prefixed MR number does the same for the current repo. Keeps a cached repo listing and a jump history.
```bash
git-find-repo [--workspace|-W <path>] [--vc-folder|-F <folder>] [--update-listing|-U] \
              [--list|-L] [--history|-H] [--no-git-clone] [--no-history] [--no-checkout] <project|url|mr-id|->
```

### git-fix-goimports
Run `make imports` and `goimports -w` on a chosen recent branch.
```bash
git-fix-goimports
```

### git-fork
Fork the current repo on github.com.
```bash
git-fork
```

### git-ignore
Append paths/patterns to `.gitignore` (cwd or repo root).
```bash
git-ignore [-r|--root] FILE...
```

### git-last-change
Show diff between the last two tags.
```bash
git-last-change
```

### git-log
Interactive log picker. Commits are listed as COMMIT / AGE / AUTHOR / MESSAGE
(with branch and tag decorations), the preview shows the commit with its stat
and patch. Keys: `ctrl-c` copies the hash, `ctrl-d` shows the diff, `ctrl-o`
opens the commit in the browser, `alt-p` writes it as a patch file, `alt-r`
reverts it in the working tree, `alt-b` reverts it on a new branch and
optionally pushes it and opens a merge/pull request.

`enter` steps into a commit and opens a file picker with the changed files
plus their churn on the left and the diff of the selected file in the preview:
`enter` shows the file diff, `ctrl-c` copies the path, `ctrl-e` opens the file in
the editor, `alt-v` opens the before and after version in vimdiff, `alt-p` writes
the file's diff as a patch, and `alt-r` reverts just that file's change. `esc`
returns to the commit list. Merge commits are shown against their first
parent.

Reading a commit or a file acts inside the picker instead of ending it: the pager,
the editor and vimdiff get the terminal handed over and come back to the same
picker, the browser is opened without touching the screen at all, and reverting a
single file stays in the file picker and reports what it did above the header, so
several files can be reverted in a row. The keys that return something on stdout -
copying a hash or a path, writing a patch - and the ones that leave the working
tree changed still end the picker.

The footer names what the list is narrowed down to, which no row of it says: the
paths the log is filtered by in the commit list, and the hash and subject of the
commit the files belong to in the file picker.
```bash
git-log [--print] [-q <query>] [-n <count>] [--ref <rev>] [--all] \
        [--author <pattern>] [--grep <pattern>] [--merges|--no-merges] \
        [-d <commit>] [-f <commit>] [-p <commit>] [-o <dir>] \
        [-r <commit>] [-b <commit>] [--] [<path>...]
```

### git-move
Move uncommitted changes to a new branch, leaving the current branch clean; optionally take unpushed commits along and reset the current branch to its upstream. Changes travel with the branch switch when the branch starts at the current commit, otherwise through a stash that is only dropped once it applied cleanly.
```bash
git-move [-b|--base <ref>] [-c|--with-commits] [-C|--no-commits] [-y|--yes] [BRANCH]
```

### git-mr
Work with GitLab merge requests and GitHub pull requests; the provider is
detected from the remote, so `git-mr` and `git-pr` are the same command.
Approve, merge, create, close, delete, copy a channel message, create an issue,
or show the review feedback.

Without an action a `prompt-select` menu offers every action plus the branch and
state filter (`branch` opens a branch list, `states` toggles, both return to the
menu). The requests are then listed in an fzf picker with the request and its
diff in the preview: `enter` runs the chosen action (approve + merge by
default), `ctrl-s`
shows the request, `ctrl-d` its diff, `ctrl-o` opens it in the browser,
`ctrl-y` copies a channel message, `ctrl-f` shows the feedback, `alt-a`
approves, `alt-m` merges, `alt-i` creates an issue from it, `alt-c` closes it,
`alt-x` deletes it, and `esc` goes back.

All of those but the chosen action and creating an issue - both of which report
something the picker would draw over - act inside the picker: showing the request,
its diff or its feedback hands the terminal to the pager, opening the browser and
copying the message keep the screen and report above the header, and approving,
merging, closing and deleting reload the list so the new state shows. Only those
four reload, since a reload is an API call.

The context printed before the picker opens is off the screen while it runs, so
the footer leads with the two filters that decide what the list holds: the branch
filter and the state filter.

By default the requests of the current branch are listed; on the default or
production branch (`--prod-branch`) requests are filtered by their target
branch instead. `--feedback` prints the comments and review feedback as
Markdown (`-u` hides resolved discussions, `-r` skips the terminal
rendering). Closing and deleting a request ask whether its source branch should
be deleted locally and on the remote as well; deleting a request is GitLab only,
because the GitHub API can not delete a pull request. `-n` acts on one request
without the picker, `-p` prints the list.
```bash
git-mr [-c|--create] [-a|--approve] [-M|--merge] [-C|--close] [-D|--delete] \
       [-m|--copy-message] [-i|--issue] [--feedback] [-u|--unresolved] [-r|--raw] \
       [-b|--branch <branch>] [-k|--checkout] [--prod-branch <branch>] \
       [-A|--all] [-n|--number <id>] [-q|--query <query>] [-l|--limit <n>] \
       [-p|--print] [-o txt|json] [<project>]
```

### git-package
List, inspect, filter, delete GitLab packages for current repo.
```bash
git-package <check|list|delete> [ID] [-n <name>] [-v <version>] [-o txt|json]
```

### git-pipe
Show GitLab CI or GitHub Actions pipeline status for a ref, or search pipelines by log content, source, or status. Defaults to the current branch; use `--all-refs` to search every ref. Variable search is GitLab-only.

Alongside the pipelines of the selected ref, the pipelines of the 3 most recent tags are shown (`--tags <N>` changes the number of tags, `--no-tags` turns them off). Each tag costs one API request, so a large `N` makes the lookup - and every `--watch` reload - slower.

Results open in an interactive picker with the pipeline's jobs in the preview: `enter` steps into the pipeline and lists its jobs, `tab` narrows the list down to the pipelines that are still running and back, `ctrl-y` copies the URL, `ctrl-o` opens it in the browser, `ctrl-l` shows the job logs. Everything but `enter` happens inside the picker - the log pager gets the terminal handed over and returns to the same picker. The picker reloads once 10 seconds after it opened - a pipeline may have started in the meantime - and then keeps reloading every few seconds (`-w`, `-w 0` disables) as long as pipelines are still running, stopping once everything reached a final state. A manual refresh (`ctrl-r`) refetches even after that, and if it brings up a running pipeline the auto-reloading resumes. Use `-p` or `-o json` for non-interactive output.

The jobs of a pipeline open in a picker of their own (`-j <pipeline>` opens it directly), with the details of the selected job and the tail of its log in the preview: `enter` pages the whole log, `ctrl-y` copies the job URL, `ctrl-o` opens it in the browser, `esc` returns to the pipeline list. The preview keeps up with the log of a job that is still running; on GitHub a job has no log before it finished, so its steps take the place of the log until then.

The ref, the source, the status and the user of a pipeline are columns of the list, so filtering by them is on the screen already. `--grep` and `--var` are not - they drop pipelines with nothing saying why the list is as short as it is - so the footer leads with them when they are used, followed by whether `tab` currently narrows the list down to what is running.
```bash
git-pipe status [-r <project>] [--ref <ref>] [--tags <N>|--no-tags] [-q <query>] [-w <seconds>] \
                [-p] [-o txt|json]
git-pipe -j <pipeline> [-r <project>] [-w <seconds>] [-p] [-o txt|json]
git-pipe search [-r <project>] [--ref <ref>|--all-refs] [--tags <N>|--no-tags] \
                [--var <NAME[=VALUE]>] [--grep <pattern>] \
                [--source <source>] [-s <status>|--failed|--succeeded|--aborted|...] \
                [-n <limit>] [-a] [-q <query>] [-w <seconds>] [-p] [-o txt|json]
```

### git-pr
Symlink to [git-mr](#git-mr), which handles GitHub pull requests and GitLab
merge requests alike.
```bash
git-pr [OPTIONS] [<project>]
```

### git-push
Push current or named branch; optional push-only or force-with-lease.
```bash
git-push [-p|--push-only] [-F|--force-with-lease] [<branch>]
```

### git-reset-all
Reset and clean all tracked and untracked changes (with confirm).
```bash
git-reset-all
```

### git-rm-branches
Delete all local branches except the default branch.
```bash
git-rm-branches [-f|--force]
```

### git-search
Search GitLab and/or GitHub for a query.
```bash
git-search <query> [--gitlab|--github]
```

### git-tag
Create, delete, or recreate a git tag.
```bash
git-tag [<tag>] [-d] [-r] [-y]
```

### git-track-branches
Set up tracking for all remote branches; optionally prune locals.
```bash
git-track-branches [-C|--clear]
```

### git-worktree
Manage mirrored git worktrees under `$WORKSPACE_WORKTREE`.
```bash
git-worktree [add|list|delete|move-to-main] [-b <branch>] [-B <base>] [--fetch|--no-fetch] [-w <dir>]
```
When `add` has to create the branch, the start point is taken from `-B/--base`
(asked interactively when omitted, defaulting to the default remote branch) and
the base can be fetched beforehand (asked interactively when neither `--fetch`
nor `--no-fetch` is given).
