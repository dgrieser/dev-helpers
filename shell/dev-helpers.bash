# Shell integration of dev-helpers. Source it from ~/.bashrc after the prompt is
# set up, so that its hook runs before the prompt's:
#
#   source /usr/local/share/dev-helpers/dev-helpers.bash
#
# git-mr and git-worktree remove worktrees that a shell may still be in, and a
# command cannot change the directory of the shell that started it. Before each
# prompt __dh_fix_cwd moves a shell whose directory is gone to the main tree the
# worktree was recorded with when it was removed, else to the main tree a
# mirrored worktree under WORKSPACE_WORKTREE belongs to, under WORKSPACE or
# HOME, else to the nearest directory that still exists.

__dh_removed_worktrees_file="${HOME}/.cache/dev-helpers/removed-worktrees"

# prints where in the main tree recorded for the removed worktree holding ${1}
# the shell belongs: the same subdirectory, or the nearest one that exists
__dh_recorded_main_tree() {
    local worktree main_tree found_worktree found_main_tree dir

    [ -f "${__dh_removed_worktrees_file}" ] || return 1
    # newer lines come later, so the last match wins
    while IFS=$'\t' read -r worktree main_tree; do
        [ -n "${worktree}" ] && [ -n "${main_tree}" ] || continue
        case "${1}" in
            "${worktree}"|"${worktree}"/*)
                found_worktree="${worktree}"
                found_main_tree="${main_tree}"
                ;;
        esac
    done < "${__dh_removed_worktrees_file}"
    [ -n "${found_main_tree}" ] || return 1

    dir="${found_main_tree}${1#"${found_worktree}"}"
    while [ ! -d "${dir}" ] && [ "${dir}" != "${found_main_tree}" ]; do
        dir="${dir%/*}"
    done
    [ -d "${dir}" ] || return 1
    printf '%s\n' "${dir}"
}

# prints the main tree of the mirrored worktree holding ${1}:
# WORKSPACE_WORKTREE/<path under WORKSPACE>/<branch> belongs to
# WORKSPACE/<path under WORKSPACE>, and, for a repository outside WORKSPACE,
# WORKSPACE_WORKTREE/home.dir/<path under HOME>/<branch> to HOME/<path under
# HOME>, see HOME_MIRROR_DIR of git-worktree. A branch may hold slashes, so the
# deepest path with a repository wins, down to the root itself, as a repository
# of dotfiles at HOME has its worktrees right below home.dir
__dh_mirrored_main_tree() {
    local worktree_root source_root rel

    worktree_root="${WORKSPACE_WORKTREE%/}"
    [ -n "${worktree_root}" ] || return 1
    case "${1}" in
        "${worktree_root}"/home.dir/*)
            source_root="${HOME%/}"
            rel="${1#"${worktree_root}"/home.dir/}"
            ;;
        "${worktree_root}"/*)
            source_root="${WORKSPACE%/}"
            rel="${1#"${worktree_root}"/}"
            ;;
        *)
            return 1
            ;;
    esac
    [ -n "${source_root}" ] || return 1

    while :; do
        if [ -d "${source_root}/${rel}/.git" ]; then
            printf '%s\n' "${source_root}/${rel}"
            return 0
        fi
        [[ "${rel}" == */* ]] || break
        rel="${rel%/*}"
    done
    [ -d "${source_root}/.git" ] || return 1
    printf '%s\n' "${source_root}"
}

__dh_fix_cwd() {
    local status=$?
    local dir

    # . is the directory the shell is in, ${PWD} the path it got there by; they
    # only part when the directory was removed, or removed and made again
    [ . -ef "${PWD}" ] && return "${status}"

    if [ -d "${PWD}" ]; then
        builtin cd -- "${PWD}"
        return "${status}"
    fi

    dir="$(__dh_recorded_main_tree "${PWD}")" ||
        dir="$(__dh_mirrored_main_tree "${PWD}")" || {
            dir="${PWD}"
            while [ -n "${dir}" ] && [ ! -d "${dir}" ]; do
                dir="${dir%/*}"
            done
            dir="${dir:-/}"
        }
    builtin cd -- "${dir}" &&
        printf '%s is gone, changed to %s\n' "${OLDPWD}" "${dir}" 1>&2
    return "${status}"
}

# first, so that the prompt looks at the directory the shell ends up in
if [[ "${PROMPT_COMMAND@a}" == *a* ]]; then
    [[ " ${PROMPT_COMMAND[*]} " == *" __dh_fix_cwd "* ]] ||
        PROMPT_COMMAND=(__dh_fix_cwd "${PROMPT_COMMAND[@]}")
elif [[ "${PROMPT_COMMAND}" != *__dh_fix_cwd* ]]; then
    PROMPT_COMMAND="__dh_fix_cwd${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
fi
