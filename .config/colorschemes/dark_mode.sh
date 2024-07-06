#!/bin/sh

# set dark mode in alacritty, tmux and opened neovim instances

sed -i 's/light/dark/' ~/.config/colorschemes/shell_bg
sed -i 's/catppuccin-latte/catppuccin-mocha/' ~/.config/alacritty/alacritty.toml
sed -i 's/latte/mocha/' ~/.config/tmux/tmux.conf
tmux source-file ~/.config/tmux/tmux.conf

tmux list-panes -a -F '#{pane_id} #{pane_current_command}' | grep vim | cut -d ' ' -f 1 | xargs -I PANE tmux send-keys -t PANE ESCAPE ":set background=dark" ENTER 
