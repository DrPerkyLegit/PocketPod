-- data[1].assets[1].browser_download_url
local apiURL = "http://api.github.com/repos/LeakedBuffalo7907/PocketPod/releases"
local baseRepoURL = "https://raw.githubusercontent.com/LeakedBuffalo7907/PocketPod/main"
local args = {...}
local skipcheck = false
if args and args[1] == "y" then
  skipcheck = true
end


http.request(apiURL)
print("Made request to " .. apiURL)

  if fs.exists("/musicify.lua") then
    print("Pocket Pod Already Exists, Deleting old install")
    fs.delete("/musicify.lua")
    fs.delete("/lib/semver.lua")
    fs.delete("/lib/youcubeapi.lua")
    fs.delete("/lib/basalt.lua")
  end

    print("Installing now")
    shell.run("wget " .. baseRepoURL .. "/musicify.lua /musicify.lua")

    print("Downloading libraries right now")
    shell.run("wget " .. baseRepoURL .. "/lib/semver.lua /lib/semver.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/youcubeapi.lua /lib/youcubeapi.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/basalt.lua /lib/basalt.lua")
    print("Done!!")
    return
    


