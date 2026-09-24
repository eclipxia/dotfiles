_fz_activate_venv() {
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi

    if [ -f "./venv/bin/activate" ]; then
        source "./venv/bin/activate"
    elif [ -f "./.venv/bin/activate" ]; then
        source "./.venv/bin/activate"
    fi
}

_fz_cd_subdir_activate() {
    local subdir
    subdir=$(find . -maxdepth 1 -type d | fzf) || return 1
    cd "$subdir" || return 1
    _fz_activate_venv
}

fzsp() {
    local dir
    dir=$(find ~/Documents/school/* -maxdepth 1 -type d 2>/dev/null | fzf) || return
    cd "$dir" || return
    _fz_cd_subdir_activate
}

fzp() {
    local dir
    dir=$(find ~/git/ -maxdepth 1 -type d 2>/dev/null | fzf) || return
    cd "$dir" || return
    _fz_cd_subdir_activate
}

# Find a git repo under known roots, then pick a local branch. If the branch
# already has a worktree, cd into it; otherwise create one as a sibling of
# the current worktree (matching the <repo>/<branch>/ layout) and cd there.
fzg() {
    local repo
    repo=$(find ~/git ~/Documents \
        \( -name node_modules -o -name .venv -o -name venv \) -prune -o \
        -type d -name ".git" -print 2>/dev/null \
        | sed 's|/\.git$||' | fzf) || return
    cd "$repo" || return

    # If this dir is a <repo>/<branch> worktree layout, the dir is named after
    # its own checked-out branch -- use the parent as the repo name. Otherwise
    # (plain, non-worktree clone) the dir itself is the repo name.
    local reponame
    if [ "$(basename "$repo")" = "$(git branch --show-current)" ]; then
        reponame="$(basename "$(dirname "$repo")")"
    else
        reponame="$(basename "$repo")"
    fi

    local branch
    branch=$(git branch --format='%(refname:short)' | fzf) || return

    local wt_path
    wt_path=$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
        /^worktree / { path = $2 }
        $0 == "branch " b { print path }
    ')

    if [ -z "$wt_path" ]; then
        wt_path="$(dirname "$repo")/$branch"
        git worktree add "$wt_path" "$branch" || return
    fi

    cd "$wt_path" || return
    _fz_activate_venv
    tmux-dev "$wt_path" "$reponame/$branch"
}

