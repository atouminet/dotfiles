#!/bin/sh
 
# set light mode in alacritty, tmux and opened neovim instances

sed -i 's/dark/light/' ~/.config/colorschemes/shell_bg
sed -i 's/catppuccin-mocha/catppuccin-latte/' ~/.config/alacritty/alacritty.toml
sed -i 's/mocha/latte/' ~/.config/tmux/tmux.conf
tmux source-file ~/.config/tmux/tmux.conf

tmux list-panes -a -F '#{pane_id} #{pane_current_command}' | grep vim | cut -d ' ' -f 1 | xargs -I PANE tmux send-keys -t PANE ESCAPE ":set background=light" ENTER 
