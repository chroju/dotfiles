-- ~/.hammerspoon/init.lua

local ok, secrets = pcall(require, "secrets")
if not ok then secrets = {} end

local WF_API = "https://workflowy.com/api/v1/nodes"
local WF_KEY = secrets.workflowy_api_key or ""

-- 登録先の固定リスト。key は Workflowy API の parent_id にそのまま渡せる固定値
-- (先頭が既定の登録先)。リストにない登録先はパネルの自由入力欄で指定する
local WF_DESTS = {
  { key = "today",     label = "Today" },
  { key = "tomorrow",  label = "Tomorrow" },
  { key = "next_week", label = "Next week" },
  { key = "inbox",     label = "Inbox" },
}

local FRAME_KEY = "captureFrame"

-- parent は parent_id にそのまま渡す。固定値のほか、ノードのURL・ID・ショートカット名を受け付ける
local function postToWorkflowy(text, mode, parent, done)
  parent = (parent or ""):match("^%s*(.-)%s*$")
  if parent == "" then parent = WF_DESTS[1].key end
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    table.insert(lines, line)
  end
  local name = lines[1] or text
  local note = nil
  if #lines > 1 then
    note = table.concat(lines, "\n", 2)
    if note:match("^%s*$") then note = nil end
  end
  local body = hs.json.encode({
    parent_id = parent,
    name = name,
    note = note,
    layoutMode = mode,
    position = "top",
  })
  hs.http.asyncPost(WF_API, body, {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. WF_KEY,
  }, done)
end

-- ── HTML ──────────────────────────────
local function buildHtml()
  return [=[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: -apple-system, "Hiragino Sans", sans-serif;
    height: 100vh; background: transparent; padding: 2px;
  }
  .panel {
    height: 100%;
    border-radius: 12px;
    border: 1px solid rgba(255,255,255,0.14);
    background:
      radial-gradient(80% 50% at 0% 100%, rgba(140,110,220,0.10), transparent 60%),
      radial-gradient(70% 40% at 100% 100%, rgba(90,110,220,0.07), transparent 60%),
      rgba(20, 20, 29, 0.88);
    display: flex; flex-direction: column;
    overflow: hidden;
    animation: pop 0.16s cubic-bezier(0.2, 0.9, 0.3, 1.15);
  }
  @keyframes pop {
    from { transform: scale(0.97) translateY(6px); opacity: 0; }
    to   { transform: scale(1) translateY(0); opacity: 1; }
  }

  /* 上部バー = ドラッグ領域 */
  .topbar {
    display: flex; justify-content: flex-end; align-items: center;
    padding: 16px 20px 8px;
    cursor: grab;
    -webkit-user-select: none;
  }
  .topbar:active { cursor: grabbing; }
  .modes { display: flex; gap: 22px; }
  .mode {
    background: none; border: none; cursor: pointer;
    display: flex; align-items: center; gap: 7px;
    color: rgba(235,235,245,0.35);
    font-size: 14px; font-family: inherit;
    padding: 2px 2px 7px;
    border-bottom: 2px solid transparent;
    transition: color 0.12s, border-color 0.12s;
  }
  .mode .ico { font-size: 12px; opacity: 0.8; }
  .mode.active {
    color: rgba(240,240,250,0.95);
    border-bottom-color: rgba(150,145,240,0.85);
  }

  /* 登録先 */
  .dests {
    display: flex; align-items: center; gap: 8px;
    padding: 4px 20px 0;
  }
  #dest {
    -webkit-appearance: none;
    background: rgba(140,130,255,0.08)
      url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='8' height='5'><path d='M0 0l4 5 4-5z' fill='%23aaa6e8'/></svg>")
      no-repeat right 10px center;
    border: 1px solid rgba(150,145,240,0.45);
    border-radius: 8px;
    color: rgba(240,240,250,0.95);
    font-size: 12px; font-family: inherit;
    padding: 5px 26px 5px 10px;
    cursor: pointer;
    outline: none;
  }
  .dests .kbd { color: rgba(235,235,245,0.24); font-size: 11px; }
  #custom {
    flex: 1; min-width: 0;
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(235,235,245,0.14);
    border-radius: 8px;
    color: #ececf4;
    caret-color: #8f8af0;
    font-size: 12px; font-family: inherit;
    padding: 5px 10px;
    outline: none;
  }
  #custom:focus { border-color: rgba(150,145,240,0.55); }
  #custom.invalid { border-color: rgba(240,110,110,0.75); }
  #custom::placeholder { color: rgba(235,235,245,0.24); }
  #custom[hidden] { display: none; }

  /* 全面入力欄 */
  textarea {
    flex: 1;
    background: transparent;
    color: #ececf4;
    caret-color: #8f8af0;
    border: none;
    padding: 24px 28px;
    font-size: 16px;
    font-family: inherit;
    line-height: 1.9;
    resize: none;
    outline: none;
  }
  textarea::placeholder { color: rgba(235,235,245,0.24); }

  .bottom {
    display: flex; justify-content: flex-end; gap: 10px;
    padding: 0 20px 20px;
  }
  .cancel {
    background: transparent;
    border: 1px solid rgba(235,235,245,0.18);
    color: rgba(235,235,245,0.55);
    border-radius: 999px;
    padding: 9px 22px;
    font-size: 14px; font-family: inherit;
    cursor: pointer;
    transition: background 0.12s, color 0.12s;
  }
  .cancel:hover {
    background: rgba(255,255,255,0.06);
    color: rgba(235,235,245,0.8);
  }
  .cancel:active { transform: scale(0.98); }
  .cancel .kbd { opacity: 0.5; font-size: 12px; margin-left: 8px; }
  .send {
    background: rgba(140,130,255,0.05);
    border: 1px solid rgba(155,145,255,0.45);
    color: #cfc9ff;
    border-radius: 999px;
    padding: 9px 22px;
    font-size: 14px; font-family: inherit;
    cursor: pointer;
    transition: background 0.12s, box-shadow 0.15s;
  }
  .send:hover {
    background: rgba(140,130,255,0.12);
    box-shadow: 0 2px 14px rgba(130,120,255,0.25);
  }
  .send:active { transform: scale(0.98); }
  .send .kbd { opacity: 0.5; font-size: 12px; margin-left: 8px; }
</style>
</head>
<body>
  <div class="panel">
    <div class="topbar" id="dragzone">
      <div class="modes">
        <button id="m-bullets" class="mode active" onclick="setMode('bullets')">
          <span class="ico">•</span>Bullet
        </button>
        <button id="m-todo" class="mode" onclick="setMode('todo')">
          <span class="ico">▢</span>TODO
        </button>
      </div>
    </div>
    <div class="dests">
      <select id="dest"></select>
      <span class="kbd">⇧⇥</span>
      <input id="custom" type="text" hidden spellcheck="false" autocomplete="off"
             placeholder="URL / ID / ショートカット名">
    </div>
    <textarea id="text" autofocus></textarea>
    <div class="bottom">
      <button class="cancel" onclick="cancel()">Cancel<span class="kbd">esc</span></button>
      <button class="send" onclick="send()">Send<span class="kbd">⌘↩</span></button>
    </div>
  </div>
<script>
  const ta = document.getElementById("text");
  let mode = "bullets";

  function setMode(m) {
    mode = m;
    document.getElementById("m-bullets").classList.toggle("active", m === "bullets");
    document.getElementById("m-todo").classList.toggle("active", m === "todo");
    ta.focus();
  }

  // ── 登録先(固定リスト + 自由入力)。選択は送信後も保持する ──
  const DESTS = ]=] .. hs.json.encode(WF_DESTS) .. [=[;
  const CUSTOM = DESTS.length;  // 固定リストの次の番号が自由入力
  const destEl = document.getElementById("dest");
  const customEl = document.getElementById("custom");
  let dest = 0;

  DESTS.map((d) => d.label).concat(["Other…"]).forEach((label, i) => {
    const o = document.createElement("option");
    o.value = String(i);
    o.textContent = label;
    destEl.appendChild(o);
  });
  destEl.addEventListener("change", () => setDest(Number(destEl.value)));

  function setDest(i) {
    dest = i;
    destEl.value = String(i);
    customEl.hidden = i !== CUSTOM;
    customEl.classList.remove("invalid");
    if (i === CUSTOM) { customEl.focus(); customEl.select(); } else { ta.focus(); }
  }
  setDest(0);

  customEl.addEventListener("input", () => customEl.classList.remove("invalid"));

  function send() {
    if (!ta.value.trim()) return;
    let parent;
    if (dest === CUSTOM) {
      parent = customEl.value.trim();
      if (!parent) {
        customEl.classList.add("invalid");
        customEl.focus();
        return;
      }
    } else {
      parent = DESTS[dest].key;
    }
    webkit.messageHandlers.capture.postMessage({
      action: "send", text: ta.value, mode: mode, parent: parent
    });
    ta.value = "";
  }

  function cancel() {
    webkit.messageHandlers.capture.postMessage({ action: "close" });
  }

  document.addEventListener("keydown", (e) => {
    const inCustom = document.activeElement === customEl;
    if (e.key === "Tab") {
      e.preventDefault();
      if (e.shiftKey) {
        setDest((dest + 1) % (CUSTOM + 1));
      } else if (inCustom) {
        ta.focus();  // 自由入力欄からは本文へ移るだけ(モードは変えない)
      } else {
        setMode(mode === "bullets" ? "todo" : "bullets");
      }
    }
    if (e.key === "Enter" && e.metaKey) { e.preventDefault(); send(); }
    else if (e.key === "Enter" && inCustom && !e.isComposing && e.keyCode !== 229) { e.preventDefault(); ta.focus(); }
    if (e.key === "Escape") {
      webkit.messageHandlers.capture.postMessage({ action: "close" });
    }
  });
  window.addEventListener("focus", () => ta.focus());

  // ── 上部バーのドラッグでウィンドウ移動(開始合図だけLuaに送る)──
  const dz = document.getElementById("dragzone");
  dz.addEventListener("mousedown", (e) => {
    if (e.target.closest("button")) return;
    e.preventDefault();
    webkit.messageHandlers.capture.postMessage({ action: "dragStart" });
  });
</script>
</body>
</html>
]=]
end

-- ── webview ──────────────────────────────
local webview = nil

-- ドラッグ追跡(eventtapでマウスを直接追う。JSブリッジを通らないので遅延しない)
local dragTap = nil
local function startDrag()
  if dragTap then return end
  local t = hs.eventtap.event.types
  local p = hs.eventtap.event.properties
  dragTap = hs.eventtap.new({ t.leftMouseDragged, t.leftMouseUp }, function(e)
    if e:getType() == t.leftMouseUp then
      dragTap:stop()
      dragTap = nil
      return false
    end
    if webview then
      local dx = e:getProperty(p.mouseEventDeltaX)
      local dy = e:getProperty(p.mouseEventDeltaY)
      local tl = webview:topLeft()
      webview:topLeft({ x = tl.x + dx, y = tl.y + dy })
    end
    return false
  end)
  dragTap:start()
end

local function saveFrame()
  if webview then
    local f = webview:frame()
    hs.settings.set(FRAME_KEY, { x = f.x, y = f.y, w = f.w, h = f.h })
  end
end

local ucc = hs.webview.usercontent.new("capture")
ucc:setCallback(function(msg)
  local body = msg.body

  if body.action == "dragStart" then
    startDrag()
    return
  end

  if body.action == "close" then
    saveFrame()
    if webview then webview:hide() end
    return
  end

  if body.action == "send" then
    saveFrame()
    if webview then webview:hide() end
    postToWorkflowy(body.text, body.mode, body.parent, function(status, respBody, _)
      if status < 200 or status >= 300 then
        hs.pasteboard.setContents(body.text)
        hs.notify.new({
          title = "送信失敗 (" .. tostring(status) .. ") クリップボードに退避",
          informativeText = tostring(respBody),
        }):send()
      end
    end)
  end
end)

local function makeWebview()
  local saved = hs.settings.get(FRAME_KEY)
  local rect
  if saved then
    rect = hs.geometry.rect(saved.x, saved.y, saved.w, saved.h)
  else
    local screen = hs.screen.mainScreen():frame()
    local w, h = 460, 640
    rect = hs.geometry.rect(
      screen.x + (screen.w - w) / 2,
      screen.y + (screen.h - h) / 3,
      w, h
    )
  end
  local wv = hs.webview.new(rect, {}, ucc)
  wv:windowStyle({ "borderless", "resizable" })
  wv:level(hs.drawing.windowLevels.floating)
  wv:allowTextEntry(true)
  wv:transparent(true)
  wv:shadow(true)
  wv:html(buildHtml())
  return wv
end

-- ── マイクインジケータ (inUse × OSミュートの複合状態) ──────────────────────────────
-- ON AIR(赤・点滅) = 使用中 かつ OSミュートしていない → 声が届いている可能性が高い
-- MUTED(黄)        = 使用中 だが OSミュート済み       → マイクは掴まれているが自分はミュート済み
-- STANDBY(灰)      = 未使用 だが OSミュートしていない → すぐ声を拾える待機状態
-- (非表示)         = 未使用 かつ OSミュート済み       → 完全に安全
local micIndicator = nil
local micPollTimer = nil
local micBlinkTimer = nil
local micState = nil -- "rec" | "muted" | "standby" | "safe" ; 直前状態との差分検知用
local micBlinkOn = true

local MIC_STYLES = {
  rec     = { bg = { red = 0.85, green = 0.08, blue = 0.08, alpha = 0.95 }, label = "ON AIR", dotAlpha = 1,   blink = true  },
  muted   = { bg = { red = 0.55, green = 0.45, blue = 0.05, alpha = 0.90 }, label = "MUTED",  dotAlpha = 1,   blink = false },
  standby = { bg = { red = 0.3,  green = 0.3,  blue = 0.3,  alpha = 0.7  }, label = "STANDBY",dotAlpha = 0.6, blink = false },
}

local function buildMicIndicator()
  local screen = hs.screen.mainScreen():frame()
  local w, h = 140, 34
  local rect = hs.geometry.rect(screen.x + screen.w - w - 14, screen.y + 8, w, h)
  local c = hs.canvas.new(rect)
  c:level(hs.canvas.windowLevels.overlay)
  c:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
  c[1] = {
    type = "rectangle",
    action = "fill",
    fillColor = { red = 0, green = 0, blue = 0, alpha = 0 },
    roundedRectRadii = { xRadius = 4, yRadius = 4 },
  }
  c[2] = {
    type = "circle",
    action = "fill",
    fillColor = { red = 1, green = 1, blue = 1, alpha = 1 },
    center = { x = "20%", y = "50%" },
    radius = "6%",
  }
  c[3] = {
    type = "text",
    text = "",
    textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
    textFont = ".AppleSystemUIFontBold",
    textSize = 15,
    textAlignment = "center",
    frame = { x = "32%", y = "16%", w = "62%", h = "68%" },
  }
  return c
end

local function currentMicState()
  local dev = hs.audiodevice.defaultInputDevice()
  if not dev then return "safe" end
  local inUse = dev:inUse()
  local muted = dev:inputMuted()
  if inUse then
    if muted then return "muted" end
    return "rec"
  end
  if muted then return "safe" end
  return "standby"
end

local function paintMicIndicator()
  local style = MIC_STYLES[micState]
  local bgAlpha = style.bg.alpha
  if style.blink and not micBlinkOn then
    bgAlpha = bgAlpha * 0.35
  end
  micIndicator[1].fillColor = { red = style.bg.red, green = style.bg.green, blue = style.bg.blue, alpha = bgAlpha }
  micIndicator[2].fillColor = { red = 1, green = 1, blue = 1, alpha = style.dotAlpha }
  micIndicator[3].text = style.label
end

local function renderMicIndicator(state)
  if state == "safe" then
    if micIndicator then micIndicator:hide() end
    return
  end
  if micIndicator == nil then micIndicator = buildMicIndicator() end
  paintMicIndicator()
  micIndicator:show()
end

local function updateMicIndicator()
  local state = currentMicState()
  if state ~= micState then
    micState = state
    renderMicIndicator(state)
  end
end

hs.hotkey.bind({ "cmd", "ctrl" }, "m", function()
  local dev = hs.audiodevice.defaultInputDevice()
  if not dev then return end
  dev:setInputMuted(not dev:inputMuted())
  updateMicIndicator()

  -- Zoomはグローバルショートカット (Settings > Keyboard Shortcuts > Enable Global Shortcut) が
  -- 有効な前提で、フォーカスに関係なく届く
  if hs.application.find("zoom.us") then
    hs.eventtap.keyStroke({ "cmd", "shift" }, "a", 0)
  end

  -- SlackハドルもPreferences > Audio and video > Allow keyboard shortcut to mute が
  -- 有効な前提で、フォーカスに関係なく届く
  if hs.application.find("Slack") then
    hs.eventtap.keyStroke({ "cmd", "shift" }, "space", 0)
  end
end)

-- ディスプレイの接続/切断で座標がずれるため、構成変化時にインジケータを作り直す
local micScreenWatcher = hs.screen.watcher.new(function()
  local hadIndicator = micIndicator ~= nil
  if micIndicator then
    micIndicator:delete()
    micIndicator = nil
  end
  if hadIndicator or (micState and micState ~= "safe") then
    renderMicIndicator(micState)
  end
end)
micScreenWatcher:start()

updateMicIndicator()
micPollTimer = hs.timer.doEvery(1, updateMicIndicator)
micBlinkTimer = hs.timer.doEvery(0.5, function()
  if micState ~= "rec" or micIndicator == nil then return end
  micBlinkOn = not micBlinkOn
  paintMicIndicator()
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "r", function()
  hs.reload()
end)

hs.hotkey.bind({ "alt" }, "f", function()
  if webview == nil then webview = makeWebview() end
  local win = webview:hswindow()
  if win and win:isVisible() then
    saveFrame()
    webview:hide()
  else
    webview:show()
    webview:bringToFront()
    local w2 = webview:hswindow()
    if w2 then w2:focus() end
  end
end)

-- 起動時に生成しておく(初回表示を即時にする)
webview = makeWebview()

hs.alert.show("Config loaded ✔")
