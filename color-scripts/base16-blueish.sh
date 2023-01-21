#!/usr/bin/env bash
# Base16 Blueish - Gnome Terminal color scheme install script
# Ben Mayoras

[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="Base 16 Blueish"
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="base-16-blueish"
[[ -z "$DCONF" ]] && DCONF=dconf
[[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

dset() {
    local key="$1"; shift
    local val="$1"; shift

    if [[ "$type" == "string" ]]; then
        val="'$val'"
    fi

    "$DCONF" write "$PROFILE_KEY/$key" "$val"
}

# Because dconf still doesn't have "append"
dlist_append() {
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "'$val'"
        } | head -c-1 | tr "\n" ,
    )"

    "$DCONF" write "$key" "[$entries]"
}

# Newest versions of gnome-terminal use dconf
if which "$DCONF" > /dev/null 2>&1; then
    # Check that uuidgen is available
    type $UUIDGEN >/dev/null 2>&1 || { echo >&2 "Requires uuidgen but it's not installed.  Aborting!"; exit 1; }

    [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

    if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then
        if which "$UUIDGEN" > /dev/null 2>&1; then
            PROFILE_SLUG=`uuidgen`
        fi

        if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
            DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
        else
            DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
        fi

        DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
        PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

        # Copy existing settings from default profile
        $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

        # Add new copy to list of profiles
        dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

        # Update profile values with theme options
        dset visible-name "'$PROFILE_NAME'"
        dset palette "['#182430', '#4ce587', '#c3e88d', '#82aaff', '#82aaff', '#ff84dd', '#5fd1ff', '#c8e1f8', '#616d78', '#f6a85c', '#243c54', '#46290a', '#74afe7', '#ddeaf6', '#bbd2e8', '#8f98a0']"
        dset background-color "'#182430'"
        dset foreground-color "'#c8e1f8'"
        dset bold-color "'#c8e1f8'"
        dset bold-color-same-as-fg "true"
        dset cursor-colors-set "true"
        dset cursor-background-color "'#c8e1f8'"
        dset cursor-foreground-color "'#182430'"
        dset use-theme-colors "false"
        dset use-theme-background "false"

        unset PROFILE_NAME
        unset PROFILE_SLUG
        unset DCONF
        unset UUIDGEN
        exit 0
    fi
fi

# Fallback for Gnome 2 and early Gnome 3
[[ -z "$GCONFTOOL" ]] && GCONFTOOL=gconftool
[[ -z "$BASE_KEY" ]] && BASE_KEY=/apps/gnome-terminal/profiles

PROFILE_KEY="$BASE_KEY/$PROFILE_SLUG"

gset() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    "$GCONFTOOL" --set --type "$type" "$PROFILE_KEY/$key" -- "$val"
}

# Because gconftool doesn't have "append"
glist_append() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$GCONFTOOL" --get "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "$val"
        } | head -c-1 | tr "\n" ,
    )"

    "$GCONFTOOL" --set --type list --list-type $type "$key" "[$entries]"
}

# Append the Base16 profile to the profile list
glist_append string /apps/gnome-terminal/global/profile_list "$PROFILE_SLUG"

gset string visible_name "$PROFILE_NAME"
gset string palette "#182430:#4ce587:#c3e88d:#82aaff:#82aaff:#ff84dd:#5fd1ff:#c8e1f8:#616d78:#4ce587:#c3e88d:#82aaff:#82aaff:#ff84dd:#5fd1ff:#8f98a0"
gset string palette "['#182430', '#4ce587', '#c3e88d', '#82aaff', '#82aaff', '#ff84dd', '#5fd1ff', '#c8e1f8', '#616d78', '#f6a85c', '#243c54', '#46290a', '#74afe7', '#ddeaf6', '#bbd2e8', '#8f98a0']"
gset string background_color "#182430"
gset string foreground_color "#c8e1f8"
gset string bold_color "#c8e1f8"
gset bool   bold_color_same_as_fg "true"
gset bool   cursor-colors-set "true"
gset string cursor-background-color "'#c8e1f8'"
gset string cursor-foreground-color "'#182430'"
gset bool   use_theme_colors "false"
gset bool   use_theme_background "false"

unset PROFILE_NAME
unset PROFILE_SLUG
unset DCONF
unset UUIDGEN
