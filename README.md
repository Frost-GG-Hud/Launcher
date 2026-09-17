# ❄️ Frost Hub - Launcher

Modern, ultra-smooth, lightweight Roblox HUD shell built with [WindUI](https://github.com/Footagesus/WindUI).

---

## 🚀 Loading Script

### If Repository is Public:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Frost-GG-Hud/Launcher/main/main.lua"))()
```

### If Repository is Private (Using Token):
```lua
local request = (syn and syn.request) or (http and http.request) or http_request or request
local response = request({
    Url = "https://raw.githubusercontent.com/Frost-GG-Hud/Launcher/main/main.lua",
    Method = "GET",
    Headers = {
        ["Authorization"] = "token YOUR_GITHUB_TOKEN"
    }
})
loadstring(response.Body)()
```

---

## ✨ Features
- 🎨 Modern rounded aesthetic with acrylic blur
- 📱 Floating draggable toggle icon for mobile & desktop
- ⚡ Fluid animations and low CPU/memory footprint
- ⚙️ Dynamic themes, UI scaling, and rebindable keys (`RightShift` default)
- 👤 Built-in user info card and topbar badges
