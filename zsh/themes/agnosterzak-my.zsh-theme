# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # SEGMENT_SEPARATOR=$'\ue0b0' # 
  SEGMENT_SEPARATOR=$'\ue0b4' # 
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ -n "$SSH_CLIENT" ]]; then
    prompt_segment magenta white "%{$fg_bold[white]%(!.%{%F{white}%}.)%}$USER@%m%{$fg_no_bold[white]%}"
  else
    prompt_segment yellow magenta "%{$fg_bold[magenta]%(!.%{%F{magenta}%}.)%}@$USER%{$fg_no_bold[magenta]%}"
  fi
}

# Battery Level
prompt_battery() {
  HEART='♥ '

  if [[ $(uname) == "Darwin" ]] ; then

    function battery_is_charging() {
      [ $(ioreg -rc AppleSmartBattery | grep -c '^.*"ExternalConnected"\ =\ No') -eq 1 ]
    }

    function battery_pct() {
      local smart_battery_status="$(ioreg -rc "AppleSmartBattery")"
      typeset -F maxcapacity=$(echo $smart_battery_status | grep '^.*"MaxCapacity"\ =\ ' | sed -e 's/^.*"MaxCapacity"\ =\ //')
      typeset -F currentcapacity=$(echo $smart_battery_status | grep '^.*"CurrentCapacity"\ =\ ' | sed -e 's/^.*CurrentCapacity"\ =\ //')
      integer i=$(((currentcapacity/maxcapacity) * 100))
      echo $i
    }

    function battery_pct_remaining() {
      if battery_is_charging ; then
        battery_pct
      else
        echo "External Power"
      fi
    }

    function battery_time_remaining() {
      local smart_battery_status="$(ioreg -rc "AppleSmartBattery")"
      if [[ $(echo $smart_battery_status | grep -c '^.*"ExternalConnected"\ =\ No') -eq 1 ]] ; then
        timeremaining=$(echo $smart_battery_status | grep '^.*"AvgTimeToEmpty"\ =\ ' | sed -e 's/^.*"AvgTimeToEmpty"\ =\ //')
        if [ $timeremaining -gt 720 ] ; then
          echo "::"
        else
          echo "~$((timeremaining / 60)):$((timeremaining % 60))"
        fi
      fi
    }

    b=$(battery_pct_remaining)
    if [[ $(ioreg -rc AppleSmartBattery | grep -c '^.*"ExternalConnected"\ =\ No') -eq 1 ]] ; then
      if [ $b -gt 50 ] ; then
        prompt_segment green white
      elif [ $b -gt 20 ] ; then
        prompt_segment yellow white
      else
        prompt_segment red white
      fi
      echo -n "%{$fg_bold[white]%}$HEART$(battery_pct_remaining)%%%{$fg_no_bold[white]%}"
    fi
  fi

  if [[ $(uname) == "Linux" && -d /sys/module/battery ]] ; then

    function battery_is_charging() {
      ! [[ $(acpi 2&>/dev/null | grep -c '^Battery.*Discharging') -gt 0 ]]
    }

    function battery_pct() {
      if (( $+commands[acpi] )) ; then
        echo "$(acpi | cut -f2 -d ',' | tr -cd '[:digit:]')"
      fi
    }

    function battery_pct_remaining() {
      if [ ! $(battery_is_charging) ] ; then
        battery_pct
      else
        echo "External Power"
      fi
    }

    function battery_time_remaining() {
      if [[ $(acpi 2&>/dev/null | grep -c '^Battery.*Discharging') -gt 0 ]] ; then
        echo $(acpi | cut -f3 -d ',')
      fi
    }

    b=$(battery_pct_remaining)
    if [[ $(acpi 2&>/dev/null | grep -c '^Battery.*Discharging') -gt 0 ]] ; then
      if [ $b -gt 40 ] ; then
        prompt_segment green white
      elif [ $b -gt 20 ] ; then
        prompt_segment yellow white
      else
        prompt_segment red white
      fi
      echo -n "%{$fg_bold[white]%}$HEART$(battery_pct_remaining)%%%{$fg_no_bold[white]%}"
    fi

  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
#«»±˖˗‑‐‒ ━ ✚‐↔←↑↓→↭⇎⇔⋆━◂▸◄►◆☀★☗☊✔✖❮❯⚑⚙
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path clean has_upstream
  local modified untracked added deleted tagged stashed
  local ready_commit git_status bgclr fgclr
  local commits_diff commits_ahead commits_behind has_diverged to_push to_pull

  ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)" || return

  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    git_status=$(git status --porcelain 2> /dev/null)

    # ✔	clean directory
    if [[ -n $dirty ]]; then
      clean=''
      bgclr='yellow'
      fgclr='magenta'
    else
      clean=' ✔'
      bgclr='green'
      fgclr='white'
    fi

    local current_commit_hash=$(git rev-parse HEAD 2> /dev/null)

    # ☀	new untracked files
    local number_of_untracked_files=$(\grep -c "^??" <<< "${git_status}")
    if [[ $number_of_untracked_files -gt 0 ]]; then untracked=" $number_of_untracked_files☀"; fi

    # ✚	added files from the new untracked ones
    local number_added=$(\grep -c "^A" <<< "${git_status}")
    if [[ $number_added -gt 0 ]]; then added=" $number_added✚"; fi

    # ●	modified files
    local number_modified=$(\grep -c "^.M" <<< "${git_status}")
    if [[ $number_modified -gt 0 ]]; then
      modified=" $number_modified●"
      bgclr='red'
      fgclr='white'
    fi

    local number_added_modified=$(\grep -c "^M" <<< "${git_status}")
    local number_added_renamed=$(\grep -c "^R" <<< "${git_status}")
    if [[ $number_modified -gt 0 && $number_added_modified -gt 0 ]]; then
      modified="$modified$((number_added_modified+number_added_renamed))±"
    elif [[ $number_added_modified -gt 0 ]]; then
      modified=" ●$((number_added_modified+number_added_renamed))±"
    fi

    # ‒	deleted files
    local number_deleted=$(\grep -c "^.D" <<< "${git_status}")
    if [[ $number_deleted -gt 0 ]]; then
      deleted=" $number_deleted‒"
      bgclr='red'
      fgclr='white'
    fi

    # ±	added files from the modifies or delete ones
    local number_added_deleted=$(\grep -c "^D" <<< "${git_status}")
    if [[ $number_deleted -gt 0 && $number_added_deleted -gt 0 ]]; then
      deleted="$deleted$number_added_deleted±"
    elif [[ $number_added_deleted -gt 0 ]]; then
      deleted=" ‒$number_added_deleted±"
    fi

    # ☗	tag name at current commit
    local tag_at_current_commit
    if [[ "$AGNOSTERZAK_GIT_SHOW_TAGS" == true ]]; then
      tag_at_current_commit=$(git describe --exact-match --tags $current_commit_hash 2> /dev/null)
      if [[ -n $tag_at_current_commit ]]; then tagged=" ☗$tag_at_current_commit "; fi
    fi

    # ⚙	sets of stashed files
    local number_of_stashes
    if [[ "$AGNOSTERZAK_GIT_SHOW_STASH" == true ]]; then
      local number_of_stashes="$(git stash list -n1 2> /dev/null | wc -l)"
    else
      number_of_stashes=0
    fi

    if [[ $number_of_stashes -gt 0 ]]; then
      stashed=" ${number_of_stashes##*(  )}⚙"
      bgclr='magenta'
      fgclr='white'
    fi

    # ⚑	ready to commit
    if [[ $number_added -gt 0 || $number_added_modified -gt 0 || $number_added_deleted -gt 0 ]]; then ready_commit=' ⚑'; fi

    # ☊	branch has a stream, preceeded by his remote name
    # ↑	commits ahead on the current branch comparing to remote, preceeded by their number
    # ↓	commits behind on the current branch comparing to remote, preceeded by their number
    local has_upstream=false
    local upstream_prompt=''
    if [[ "$AGNOSTERZAK_GIT_SHOW_UPSTREAM" == true ]]; then
      upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
      if [[ -n "${upstream}" && "${upstream}" != "@{upstream}" ]]; then has_upstream=true; fi
    fi

    if [[ $has_upstream == true ]]; then
      commits_diff="$(git log --pretty=oneline --topo-order --left-right ${current_commit_hash}...${upstream} 2> /dev/null)"
      commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
      commits_behind=$(\grep -c "^>" <<< "$commits_diff")
      upstream_prompt="$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)"
      upstream_prompt=$(sed -e 's/\/.*$/ ☊ /g' <<< "$upstream_prompt")
    fi

    has_diverged=false
    if [[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]]; then has_diverged=true; fi
    if [[ $has_diverged == false && $commits_ahead -gt 0 ]]; then
      if [[ $bgclr == 'red' || $bgclr == 'magenta' ]] then
        to_push=" $fg_bold[white]↑$commits_ahead$fg_bold[$fgclr]"
      else
        to_push=" $fg_bold[black]↑$commits_ahead$fg_bold[$fgclr]"
      fi
    fi
    if [[ $has_diverged == false && $commits_behind -gt 0 ]]; then to_pull=" $fg_bold[magenta]↓$commits_behind$fg_bold[$fgclr]"; fi

    # <B>	bisect state on the current branch
    # >M<	Merge state on the current branch
    # >R>	Rebase state on the current branch
    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    # remote trunk
    local remote=$(git ls-remote --get-url 2> /dev/null)
    if [[ "$remote" =~ "github" ]] then
      vcs_visual_identifier=$'\uF113 ' # 
    elif [[ "$remote" =~ "bitbucket" ]] then
      vcs_visual_identifier=$'\uE703 ' # 
    elif [[ "$remote" =~ "stash" ]] then
      vcs_visual_identifier=$'\uE703 ' # 
    elif [[ "$remote" =~ "gitlab" ]] then
      vcs_visual_identifier=$'\uF296 ' # 
    else
      vcs_visual_identifier=$'\uF1D3 ' # 
    fi

    # revision
    local revision
    if [[ "$AGNOSTERZAK_GIT_SHOW_CHANGESET" == true ]]; then
      # revision=$(git rev-list -n 1 --abbrev-commit --abbrev=${AGNOSTERZAK_GIT_CHANGESET_HASH_LENGTH} HEAD)
      revision=${current_commit_hash:0:${AGNOSTERZAK_GIT_CHANGESET_HASH_LENGTH}}
      if [[ -n "$revision" ]] then
        vcs_commit_identifier=$' \uE729 ' # 
      fi
    fi

    prompt_segment $bgclr $fgclr
    
    echo -n "%{$fg_bold[$fgclr]%}${vcs_visual_identifier}${ref/refs\/heads\//$PL_BRANCH_CHAR $upstream_prompt}${vcs_commit_identifier}${revision}${mode}$to_push$to_pull$clean$tagged$stashed$untracked$modified$deleted$added$ready_commit%{$fg_no_bold[$fgclr]%}"
  fi
}

prompt_hg() {
  local rev status
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green black
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment red black
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green black
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment cyan white "%{$fg_bold[white]%}%~%{$fg_no_bold[white]%}"
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment green white "(`basename $virtualenv_path`)"
  fi
}

prompt_time() {
  prompt_segment blue white "%{$fg_bold[white]%}%D{%a %e %b - %H:%M}%{$fg_no_bold[white]%}"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}


get_os_icon() {
    case $(uname) in
        Darwin)
        OS='OSX'
        OS_ICON=$'\uF179'
        ;;
        MSYS_NT-* | MINGW* | CYGWIN_NT-*)
        OS='Windows'
        OS_ICON=$'\uF17A'
        ;;
        FreeBSD)
        OS='BSD'
        OS_ICON=$'\uF30C'
        ;;
        OpenBSD)
        OS='BSD'
        OS_ICON=$'\uF30C'
        ;;
        DragonFly)
        OS='BSD'
        OS_ICON=$'\uF30C'
        ;;
        Linux)
        OS='Linux'
        os_release_id="$(grep -E '^ID=([a-zA-Z]*)' /etc/os-release | cut -d '=' -f 2)"
        case "$os_release_id" in
            *arch*)
            OS_ICON=$'\uF303'
            ;;
            *debian*)
            OS_ICON=$'\uF306'
            ;;
        *ubuntu*)
            OS_ICON=$'\uF31B'
            ;;
        *elementary*)
            OS_ICON=$'\uF309'
            ;;
        *fedora*)
            OS_ICON=$'\uF30A'
            ;;
        *coreos*)
            OS_ICON=$'\uF305'
            ;;
        *gentoo*)
            OS_ICON=$'\uF30D'
            ;;
        *mageia*)
            OS_ICON=$'\uF310'
            ;;
        *centos*)
            OS_ICON=$'\uF304'
            ;;
        *opensuse*|*tumbleweed*)
            OS_ICON=$'\uF314'
            ;;
        *sabayon*)
            OS_ICON=$'\uF317'
            ;;
        *slackware*)
            OS_ICON=$'\uF319'
            ;;
        *linuxmint*)
            OS_ICON=$'\uF30E'
            ;;
        *alpine*)
            OS_ICON=$'\uF300'
            ;;
        *aosc*)
            OS_ICON=$'\uF301'
            ;;
        *nixos*)
            OS_ICON=$'\uF313'
            ;;
        *devuan*)
            OS_ICON=$'\uF307'
            ;;
        *manjaro*)
            OS_ICON=$'\uF312'
            ;;
            *)
            OS='Linux'
            OS_ICON=$'\uF17C'
            ;;
        esac

        # Check if we're running on Android
        case $(uname -o 2>/dev/null) in
            Android)
            OS='Android'
            OS_ICON=$'\uF17B'
            ;;
        esac
        ;;
        SunOS)
        OS='Solaris'
        OS_ICON=$'\uF185'
        ;;
        *)
        OS=''
        OS_ICON=''
        ;;
    esac
}

prompt_time_only() {
  # prompt_segment white black "%{$fg_bold[white]%}%D{%y-%m-%d %H:%M}%{$fg_no_bold[white]%}"
  # DATE_ICON $'\uF073'   TIME_ICON $'\uF017' 
  prompt_segment white black "\uF017 %D{%H:%M}"
}

prompt_user_host() {
  # if [[ -n "$SSH_CLIENT" ]]; then
  #   prompt_segment magenta default "%{$fg_bold[green]%}$USER%{$fg_no_bold[white]%}@%{$fg_bold[yellow]%}%m%{$fg_no_bold[green]%}"
  # else
  #   if [[ $UID -eq 0 ]]; then
  #     prompt_segment red default "%{$fg_bold[green]%}$USER%{$fg_no_bold[white]%}@%{$fg_bold[yellow]%}%m%{$fg_no_bold[green]%}"
  #   else
  #     prompt_segment cyan default "%{$fg_bold[green]%}$USER%{$fg_no_bold[white]%}@%{$fg_bold[yellow]%}%m%{$fg_no_bold[green]%}"
  #   fi
  # fi
  local visual_user_icon

  if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    visual_user_icon="%F{magenta}\uF489%f " # SSH_ICON 
  fi

  if [[ $(print -P "%#") == '#' ]]; then
    visual_user_icon+="%F{red}\u26A1%f " # ROOT_ICON $'\u26A1' ⚡ $'\uE614' 
  elif sudo -n true 2>/dev/null; then
    visual_user_icon+="%F{red}\uF09C%f " # SUDO_ICON 
  else
    visual_user_icon+="%F{yellow}\uF415%f " # USER_ICON 
  fi

  prompt_segment cyan default "${visual_user_icon}%F{yellow}$USER@%m%f"
}

prompt_dir_blue() {
  typeset -AH dir_states
  dir_states=(
    "DEFAULT"         $'\uF115' # 
    "HOME"            $'\uF015' # 
    "HOME_SUBFOLDER"  $'\uF07C' # 
    "NOT_WRITABLE"    $'\UF023' # 
    "ETC"             $'\uF013' # 
  )
  local state_path="$(print -P '%~')"
  local current_state="DEFAULT"
  if [[ $state_path == '/etc'* ]]; then
    current_state='ETC'
  elif [[ ! -w "$PWD" ]]; then
    current_state="NOT_WRITABLE"
  elif [[ $state_path == '~' ]]; then
    current_state="HOME"
  elif [[ $state_path == '~'* ]]; then
    current_state="HOME_SUBFOLDER"
  fi
  prompt_segment blue white "${dir_states[$current_state]} %~"
}

prompt_status_exitcode() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘:$RETVAL"
  # [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  if [[ -n "$symbols" ]]; then
    prompt_segment black default "$symbols"
  # else
  #   prompt_segment black default " "
  fi
}

prompt_indicator() {
  local indicator # ❯ ❮ ➤ ➜ ᐅ $'\u276F' $'\u276E' $'\u27A4' $'\u279C' $'\u1405'
  if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    indicator="%{%F{magenta}%}➤"
  else
    if [[ $UID -eq 0 ]]; then
      indicator="%{%F{red}%}➤"
    else
      indicator="%{%F{yellow}%}➤"
    fi
  fi
  prompt_segment default default "$indicator"
}

prompt_prompt_timer_preexec() {
  command_preexec_timer=${command_preexec_timer:-$SECONDS}
  prompt_preexec_timer=$SECONDS
  export ZSH_PROMPT_TIME_PREEXEC="$prompt_preexec_timer"
  export ZSH_COMMAND_EXECUTION_TIME=""
  export ZSH_PROMPT_TIME=""
}

prompt_prompt_timer_precmd() {
  if [[ $command_preexec_timer ]]; then
    export ZSH_COMMAND_EXECUTION_TIME="$(($SECONDS - $command_preexec_timer))"
    unset command_preexec_timer
  fi
}

prompt_prompt_timer() {
  local time_duration prompt_command_msg prompt_prompt_msg prompt_msg

  if [[ -n "$ZSH_COMMAND_EXECUTION_TIME" ]]; then
    if [[ -n "$TTY" ]] && [[ $ZSH_COMMAND_EXECUTION_TIME -ge ${AGNOSTERZAK_COMMAND_EXECUTION_TIME_THRESHOLD:-3} ]]; then
      ZSH_COMMAND_TIME="$ZSH_COMMAND_EXECUTION_TIME"
    fi
  fi

  if [[ -n "$ZSH_PROMPT_TIME_PREEXEC" ]]; then
    if [[ -n "$ZSH_COMMAND_EXECUTION_TIME" ]]; then
      time_duration=$(($SECONDS - $ZSH_PROMPT_TIME_PREEXEC - $ZSH_COMMAND_EXECUTION_TIME))
    else
      time_duration=$(($SECONDS - $ZSH_PROMPT_TIME_PREEXEC))
    fi

    if [[ -n "$TTY" ]] && [[ $time_duration -ge ${AGNOSTERZAK_PROMPT_TIME_THRESHOLD:-5} ]]; then
      ZSH_PROMPT_TIME="$time_duration"
    fi
  fi

  if [[ $prompt_preexec_timer ]]; then
    unset prompt_preexec_timer
  fi

  if [[ "$AGNOSTERZAK_PROMPT_TIME" == true ]] && [[ -n "$ZSH_PROMPT_TIME" ]]; then
    # prompt_prompt_msg=$(printf '%dh:%02dm:%02ds\n' $(($ZSH_PROMPT_TIME/3600)) $(($ZSH_PROMPT_TIME%3600/60)) $(($ZSH_PROMPT_TIME%60)))
    prompt_prompt_msg="${ZSH_PROMPT_TIME}s"
  fi

  if [[ "$AGNOSTERZAK_COMMAND_EXECUTION_TIME" == true ]] && [[ -n "$ZSH_COMMAND_TIME" ]]; then
    prompt_command_msg=$(printf '%dh:%02dm:%02ds\n' $(($ZSH_COMMAND_TIME/3600)) $(($ZSH_COMMAND_TIME%3600/60)) $(($ZSH_COMMAND_TIME%60)))
  fi

  if [[ -n "$prompt_prompt_msg" ]]; then
    if [[ -n "$prompt_command_msg" ]]; then
      prompt_msg="\uF252${prompt_command_msg} \uF120${prompt_prompt_msg}"
    else
      prompt_msg="\uF120${prompt_prompt_msg}"
    fi
  elif [[ -n "$prompt_command_msg" ]]; then
    prompt_msg="\uF252${prompt_command_msg}"
  fi

  # $'\uF252'   $'\uF120' 
  if [[ -n "$prompt_msg" ]]; then
    prompt_segment black yellow "${prompt_msg}"
  fi
}

prompt_os_icon() {
  get_os_icon
  prompt_segment black yellow "$OS_ICON"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  echo -n "\n"
  prompt_os_icon
  prompt_battery
  prompt_time_only
  prompt_user_host
  prompt_virtualenv
  prompt_dir_blue
  prompt_git
  prompt_hg
  prompt_status_exitcode
  prompt_prompt_timer
  prompt_end
  CURRENT_BG='NONE'
  echo -n "\n"
  prompt_indicator
  CURRENT_BG=''
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '

# PROMPT2
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
  PROMPT2='%{$fg[magenta]%}❯%{$reset_color%} '
else
  if [[ $UID -eq 0 ]]; then
    PROMPT2='%{$fg[red]%}❯%{$reset_color%} '
  else
    PROMPT2='%{$fg[yellow]%}❯%{$reset_color%} '
  fi
fi

precmd_functions+=(prompt_prompt_timer_precmd)
preexec_functions+=(prompt_prompt_timer_preexec)


## What does it show?
# If the previous command failed (✘)
# User @ Hostname (if user is not DEFAULT_USER, which can then be set in your profile)
# Git status
# Branch () or detached head (➦)
# Current branch / SHA1 in detached head state
# Dirty working directory (±, color change)
# Working directory
# Elevated (root) privileges (⚡)

## Battery status			Color
# more than 39%			green
# less than 40% and more than 19%	yellow
# less than 20%				red

### Git
## Color States
# Background Color & Foreground Color		Meaning
# green & white					git-clean	Absolutely clean state
# magenta & white 				git-stash	There are stashed files
# yellow & magenta				git-untracked	There are new untracked files
# red & white					git-modified	There are modified or deleted files but unstaged

## Icon	Meaning
# ✔	clean directory
# ☗	tag name at current commit
# ☀	new untracked files preceeded by their number
# ✚	added files from the new untracked ones preceeded by their number
# ‒	deleted files preceeded by their number
# ●	modified files preceeded by their number
# ±	added files from the modifies or delete ones preceeded by their number
# ⚑	ready to commit
# ⚙	sets of stashed files preceeded by their number
# ☊	branch has a stream, preceeded by his remote name
# ↑	commits ahead on the current branch comparing to remote, preceeded by their number
# ↓	commits behind on the current branch comparing to remote, preceeded by their number
# <B>	bisect state on the current branch
# >M<	Merge state on the current branch
# >R>	Rebase state on the current branch
