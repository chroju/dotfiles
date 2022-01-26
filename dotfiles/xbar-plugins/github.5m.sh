#!/bin/bash
# Metadata allows your plugin to show up in the app, and website.
#
#  <xbar.title>GitHub Notifications</xbar.title>
#  <xbar.version>v0.1</xbar.version>
#  <xbar.author>chroju</xbar.author>
#  <xbar.author.github>chroju</xbar.author.github>
#  <xbar.desc>Show GitHub review requests and issues assigned to you</xbar.desc>
#  <xbar.image>null</xbar.image>
#  <xbar.dependencies>gh</xbar.dependencies>
#  <xbar.abouturl>null</xbar.abouturl>

pr_icon="iVBORw0KGgoAAAANSUhEUgAAAA4AAAAQCAYAAAAmlE46AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAATJJREFUKJG9krFOAlEQRe/MLpqHnd/ATyBWsLWF+hcLPYXibvwCE/gLC2MNVrD7AbbGnpjYboBlro2QXWATabzVy5x338ydPKBC4awTVTEA8Huz9i1FI5gZBINh6+0lnHUiEXkAUGmWMGm/c7Fues4pLU9IPv+aAABm9i2qT6Pm+BECbuoqpnZWW4lmmRLG3ZdV9VyAOEyD+1JdVO4yqX+ua7UPofRHrUlEMgaA4cVYALkEACF6e/N2k4DdJCh1Ky7nENftyVACo9akcjElox3I9yfjsdoaVfFPHbtpcG2GOUy/wjS42r0QTjs3ZpibYV7kPmkxVuuGOKfIl1MAr0WjqMRcrBqec8oCVwDwnNOFnwugezkJ4+ZnFbkPeANanpwsAQr7+2m8Qab1FKcAeYgfqR/3P4pMOYR15QAAAABJRU5ErkJggg=="
issue_icon="iVBORw0KGgoAAAANSUhEUgAAAA4AAAAQCAYAAAAmlE46AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAAYpJREFUKJGdkj9I23EQxT93SZrJQYNQ6Bo65BtQcHRpSeyUuQqNWx2ti7qJRpqhUxGX0lGhlXQ0uJhfU7cOLm3+QKCzoIjoJpp8z0HT/BpJBd90HO/dvTsePBLS36iM8Uw6vANyQNJ7RJU/wG7nmo1XLY7uCStp8uL5BJwgbJtRU8E8jImR98qoGHPZBjsSFhlsCRQjCQovD2iHhx5OEDu/ZF2E5Y4wLn/tXdMy5WO2zkqXHKQxgEy95+y7Y1KMXwogbeaBk0iCwqBn7DteAJym+NmBnSiAF3IK2/32wiIVqoGjYE1GRMlGARSSZtQGbZtq8CNwFBBWDUxgJjqI3I9Mg7XAgRoXmSYlACqOWuAG39ePimNB7+oyxuzhBLEwIUhj3c92sZckLsaSAvg2m14ZPb98eGs8ThFlqBcAx4wJX8T4cGasvm5yFRaUUjwZUd4bLKow/W/kbsWfgTMxvorxmwhtjHEPbxSGEd5many7F/JqiqdemceT88rzu3ZLoWywma1z/NA5/8UNNkSJCdaYQF4AAAAASUVORK5CYII="

prs=$(/opt/homebrew/bin/gh api -X GET search/issues -f q='is:pr is:open review-requested:@me' --template "{{ range .items }}{{ .title }} | href={{ .html_url }} | color=#dded6a {{\"\\n\"}} {{ .html_url }} {{ .created_at }} ({{ .user.login }}) | size=12 {{\"\\n\"}}{{ end }}")
prs_count=$(($(echo "$prs" | wc -l)/2))

issues=$(/opt/homebrew/bin/gh api issues --template  "{{range .}} {{.title}} | href={{.html_url}} | color=#6ab0ed {{\"\\n\"}}  {{ printf \"%s%s%v\" .repository.full_name \"#\" .number}} | size=12 {{\"\\n\"}}{{end}}")
issues_count=$(($(echo "$issues" | wc -l)/2))

echo "$prs_count | href=https://github.com/pulls/review-requested | templateImage=$pr_icon"
echo "---";
echo "Review Requests | href=https://github.com/pulls/review-requested | templateImage=$pr_icon"
echo "$prs"
echo "---";
echo "Assigned Issues | href=https://github.com/issues/assigned | templateImage=$issue_icon"
echo "$issues"
