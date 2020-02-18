#! /usr/bin/env bash
. /etc/static/zshenv

#--- Funcs  ---#

# Smart gap/border assesment
evalWorkspace() {
    spaceData=$(yabai -m query --spaces --space)
    spaceWindows=( $(echo $spaceData | jq '.windows | .[]') )
    spaceIndex=$(echo $spaceData | jq '.index')
    windowCount=$(yabai -m query --windows | jq "[.[]|select(.role==\"AXWindow\" and .space==$spaceIndex)]|length")
    if [[ $windowCount -eq 1 ]]; then
        if [ $(yabai -m query --windows --window | jq '.border') -eq 1 ]; then
            yabai -m window ${spaceWindows[0]} --toggle border
        fi
        yabai -m space --padding abs:0:0:0:0
        yabai -m space --gap abs:0
    elif [[ $windowCount -gt 1 ]]; then
        if [[ $(yabai -m query --windows --window ${spaceWindows[0]} | jq '.border') -eq 0 ]]; then
            yabai -m window ${spaceWindows[0]} --toggle border
        fi
        yabai -m space --padding abs:10:10:10:10
        yabai -m space --gap abs:10
    fi
}

#--- Config ---#
main(){
    # bar settings
    yabai -m config status_bar                   on
    yabai -m config status_bar_text_font         "Helvetica Neue:Bold:12.0"
    yabai -m config status_bar_icon_font         "FontAwesome:Regular:12.0"
    yabai -m config status_bar_background_color  0xff202020
    yabai -m config status_bar_foreground_color  0xffa8a8a8
    yabai -m config status_bar_space_icon_strip           
    yabai -m config status_bar_power_icon_strip   
    yabai -m config status_bar_space_icon        
    yabai -m config status_bar_clock_icon        

    # global settings
    yabai -m config focus_follows_mouse          autoraise
    yabai -m config mouse_follows_focus          off
    yabai -m config window_placement             second_child
    yabai -m config window_topmost               on
    yabai -m config window_opacity               off
    yabai -m config window_opacity_duration      0.0
    yabai -m config window_shadow                off
    yabai -m config window_border                on
    yabai -m config window_border_placement      inset
    yabai -m config window_border_width          2
    yabai -m config window_border_radius         3
    yabai -m config active_window_border_topmost off
    yabai -m config active_window_border_color   0xff5c7e81
    yabai -m config normal_window_border_color   0xff505050
    yabai -m config insert_window_border_color   0xffd75f5f
    yabai -m config active_window_opacity        1.0
    yabai -m config normal_window_opacity        1.0
    yabai -m config split_ratio                  0.50
    yabai -m config auto_balance                 on
    yabai -m config mouse_modifier               alt
    yabai -m config mouse_action1                move
    yabai -m config mouse_action2                resize

    # general space settings
    yabai -m config layout                       bsp
    yabai -m config top_padding                  10
    yabai -m config bottom_padding               10
    yabai -m config left_padding                 10
    yabai -m config right_padding                10
    yabai -m config window_gap                   10

    # Evaluate gaps/borders for various events
    for e in application_launched application_terminated window_created window_destroyed
    do
	yabai -m signal --add event=$e action="bash ${BASH_SOURCE[0]} evalWorkspace"
    done

    echo "yabai configuration loaded..."
}

#--- Invoke ---#
if [ $# -eq 0 ]; then
    main
else
    echo "Running $@..."
    $@
fi
