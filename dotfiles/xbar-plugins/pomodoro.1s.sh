#!/bin/bash
#
# <xbar.title>Pomodoro Timer</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Goran Gajic</xbar.author>
# <xbar.author.github>gorangajic</xbar.author.github>
# <xbar.desc>Pomodoro Timer that uses Pomodoro Technique™</xbar.desc>
# <xbar.image>http://i.imgur.com/T0zFY89.png</xbar.image>
# <xbar.var>string(VAR_PIXELA_WEBHOOK_URL=""): Pixela webhook URL to record pomodoro.</xbar.var>
# <xbar.var>string(VAR_PIXELA_TOKEN=""): Pixela API token.</xbar.var>
# <xbar.var>string(VAR_POMODORO_RECORD_IFTTT_URL=""): IFTTT URL to record pomodoro.</xbar.var>

WORK_TIME=25
BREAK_TIME=5

SAVE_LOCATION=$TMPDIR/xbar-promodo
TOMATO='🍅'

WORK_TIME_IN_SECONDS=$((WORK_TIME * 60))
BREAK_TIME_IN_SECONDS=$((BREAK_TIME * 60))

CURRENT_TIME=$(date +%s)
TODAY=$(date +%Y%m%d)

if [ -f "$SAVE_LOCATION" ];
then
    DATA=$(cat "$SAVE_LOCATION")

else
    DATA="$CURRENT_TIME|0"
fi

TIME=$(echo "$DATA" | cut -d "|" -f1)
STATUS=$(echo "$DATA" | cut -d "|" -f2)
TASK=$(echo "$DATA" | cut -d "|" -f3)

function changeStatus {
    echo "$CURRENT_TIME|$1|$4" > "$SAVE_LOCATION";

    osascript -e "display notification \"$2\" with title \"$TOMATO Pomodoro\" sound name \"$3\"" &> /dev/null
}

function breakMode {
    curl -s -XPOST "${VAR_PIXELA_WEBHOOK_URL}" > /dev/null
    curl -s -XPOST "${VAR_POMODORO_RECORD_IFTTT_URL}" -d "{\"value1\":\"#pomo🍅 $TASK\"}" -H 'Content-Type:application/json' > /dev/null &
    changeStatus "2" "Break Mode" "Glass"
    open -a Workflowy
}

function workMode {
    changeStatus "1" "Work Mode" "Blow" "$1"
}

case "$1" in
"work")
    workMode $2
    exit
  ;;
"break")
    breakMode
    exit
  ;;
"disable")
    changeStatus "0" "Disabled"
    exit
  ;;
"pixela")
    open https://pixe.la/v1/users/chroju/graphs/pomodoro.html
    exit
esac



function timeLeft {
    local FROM=$1
    local TIME_DIFF=$((CURRENT_TIME - TIME))
    local TIME_LEFT=$((FROM - TIME_DIFF))
    echo "$TIME_LEFT";
}

function getSeconds {
    echo $(($1 % 60))
}

function getMinutes {
    echo $(($1 / 60))
}

function printTime {
    SECONDS=$(getSeconds "$1")
    MINUTES=$(getMinutes "$1")
    printf "%s %02d:%02d %s| color=%s\n" "$TOMATO" "$MINUTES" "$SECONDS" "$TASK"  "$2"
}

case "$STATUS" in
# STOP MODE
"0")
    echo "$TOMATO"
  ;;
"1")
    TIME_LEFT=$(timeLeft $WORK_TIME_IN_SECONDS)
    if (( "$TIME_LEFT" < 0 )); then
        breakMode
    fi
    printTime "$TIME_LEFT" "red"
  ;;
"2")
    TIME_LEFT=$(timeLeft $BREAK_TIME_IN_SECONDS)
    if (("$TIME_LEFT" < 0)); then
 	      changeStatus "0" "Break Finished !!"
    fi
    printTime "$TIME_LEFT" "green"
  ;;
esac

echo "---";
echo "👔 Work | bash=\"$0\" param1=work terminal=false"
echo "☕ Break | bash=\"$0\" param1=break terminal=false"
echo "🔌 Disable | bash=\"$0\" param1=disable terminal=false"
echo "---";
echo "show pixela | bash=\"$0\" param1=pixela terminal=false"

