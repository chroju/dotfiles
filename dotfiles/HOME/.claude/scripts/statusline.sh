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
  (.context_window.current_usage) as $usage |
  (if $usage != null then
    (($usage.input_tokens // 0) + ($usage.output_tokens // 0) + ($usage.cache_creation_input_tokens // 0) + ($usage.cache_read_input_tokens // 0)) as $current |
    (.context_window.context_window_size) as $max |
    (($current * 100 / $max) | floor | tostring) + "%"
  else
    "N/A"
  end) as $context_pct |
  "\u001b[90m" + $display_dir + " | context: " + $context_pct + " | +" +
  (.cost.total_lines_added | tostring) + "/-" +
  (.cost.total_lines_removed | tostring) + " | " +
  .model.id + " | v" + .version + "\u001b[0m"
'
