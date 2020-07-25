#!/bin/zsh

if [[ "$ZSH_VERSION" ]]; then
    rm -f ~/.zcompdump*
    autoload -U compinit && compinit
    if [[ -e ~/.zcompdump ]]; then
        [[ -n "$HOST" ]] && cp ~/.zcompdump ~/.zcompdump-$HOST-$ZSH_VERSION
        [[ -n "$HOSTNAME" ]] && cp ~/.zcompdump ~/.zcompdump-$HOSTNAME-$ZSH_VERSION
    fi
fi

# # recreate soft link
# # agnosterzak
# [[ -L "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme" ]] && \
#     rm -f "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme"
# [[ -s "$ZSH_CUSTOM/themes/agnosterzak-ohmyzsh-theme/agnosterzak.zsh-theme" ]] && \
#     ln -s "$ZSH_CUSTOM/themes/agnosterzak-ohmyzsh-theme/agnosterzak.zsh-theme" \
#         "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme"

# # spaceship-prompt
# [[ -L "$ZSH_CUSTOM/themes/spaceship.zsh-theme" ]] && \
#     rm -f "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
# [[ -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" ]] && \
#     ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" \
#         "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# # Powerlevel10k
# [[ -L "$ZSH_CUSTOM/themes/powerlevel10k.zsh-theme" ]] && \
#     rm -f "$ZSH_CUSTOM/themes/powerlevel10k.zsh-theme"
# [[ -s "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme" ]] && \
#     ln -s "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme" \
#         "$ZSH_CUSTOM/themes/powerlevel10k.zsh-theme"

# # agkozak
# [[ -L "$ZSH_CUSTOM/themes/agkozak.zsh-theme" ]] && \
#     rm -f "$ZSH_CUSTOM/themes/agkozak.zsh-theme"
# [[ -s "$ZSH_CUSTOM/themes/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh" ]] && \
#     ln -s "$ZSH_CUSTOM/themes/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh" \
#         "$ZSH_CUSTOM/themes/agkozak.zsh-theme"

# # alien
# [[ -L "$ZSH_CUSTOM/themes/alien.zsh-theme" ]] && \
#     rm -f "$ZSH_CUSTOM/themes/alien.zsh-theme"
# [[ -s "$ZSH_CUSTOM/themes/alien/alien.plugin.zsh" ]] && \
#     ln -s "$ZSH_CUSTOM/themes/alien/alien.plugin.zsh" \
#         "$ZSH_CUSTOM/themes/alien.zsh-theme"
