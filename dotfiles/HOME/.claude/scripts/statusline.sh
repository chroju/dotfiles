#!/bin/bash
# Claude Code statusLine script
# Displays: directory | context usage % | lines added/removed

jq -r '
  .cwd as $cwd |
  .workspace.project_dir as $proj |
  (if ($cwd | startswith($proj))
    then ($cwd | split("/") | .[-2:] | join("/"))
    else ($cwd | sub("^" + env.HOME; "~"))
  end) as $display_dir |
  (.context_window.total_input_tokens + .context_window.total_output_tokens) as $total |
  (.context_window.context_window_size) as $max |
  (($total * 100 / $max) | floor) as $pct |
  "\u001b[90m" + $display_dir + " | context: " + ($pct | tostring) + "% | +" +
  (.cost.total_lines_added | tostring) + "/-" +
  (.cost.total_lines_removed | tostring) + " | " +
  .model.id + " | v" + .version + "\u001b[0m"
'
