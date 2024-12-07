set-option -g prefix C-a

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-pain-control'
set -g @plugin 'tmux-plugins/tmux-sessionist'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'jimeh/tmux-themepack'
set -g @plugin 'tmux-plugins/tmux-yank'

set -g @continuum-restore 'on'

set -g @themepack 'powerline/block/cyan'

set-window-option -g mode-keys vi
# unbind [
# bind Escape copy-mode
# unbind p
# bind p paste-buffer
# bind-key -t vi-copy 'v' begin-selection
# bind-key -t vi-copy 'y' copy-selection

set-option -g allow-rename off
set-option -g status-right '[#h###S:#I:#P]'

# Copy on ^M to system clipboard
bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"
###############################################################################

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
# '#S' is session name, '#I' is window index, '#P' is pane index
