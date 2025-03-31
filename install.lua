local baseRepoURL = "http://raw.githubusercontent.com/DrPerkyLegit/PocketPod/main"

local function downloadFile(path, name)
  local status = "Downloaded"
  if fs.exists(path .. name) then
    fs.delete(path .. name)
    status = "Updated"
  end
  local F = fs.open(path .. name, "w")
  F.write(http.get(baseRepoURL .. path .. name).readAll())
  F.close()
  term.setTextColor(colors.lime)
  print(name .. " " .. status)
  term.setTextColor(colors.white)
end

local function checkFile(path, name) 
  if not fs.exists(path .. name) then
    downloadFile(path, name)
  end
end

  local uptodate = false
  local webversion = http.get(baseRepoURL .. "/CurrentVersion.txt")
  local currentVersion = webversion.readAll()
  webversion.close()
  local oldUser = fs.exists("/CurrentVersion.txt")

  if oldUser then
    print("Old install detected, Reinstalling Now")
  else
    print("Installing now")
  end
  downloadFile("/", "CurrentVersion.txt")
  checkFile("/", "Config.txt")
  downloadFile("/", "PodOS.lua")
  downloadFile("/", "startup.lua")
  downloadFile("/lib/", "PrimeUI.lua")
  term.setTextColor(colors.blue)
  print("Pocket Pod Installed " .. currentVersion)
  term.setTextColor(colors.white)
  return;
    


