local indexURL = "https://raw.githubusercontent.com/RubenHetKonijn/computronics-songs/main/index.json?cb=" .. os.epoch("utc")

local version = 0.3

local args = {...}
local musicify = {}

local tape = peripheral.find("tape_drive")



if not tape then
    print("ERROR: Tapedrive not found")
end

local handle = http.get(indexURL)
local indexJSON = handle.readAll()
handle.close()
local index = textutils.unserialiseJSON(indexJSON)
if not index then
    print("ERROR: The index is malformed.")
    return
end

local function getSongID(songname)
for i in pairs(index.songs) do
        if index.songs[i].name == songname then
          return i
        end
    end
end

local function wipe()
    local k = tape.getSize()
    tape.stop()
    tape.seek(-k)
    tape.stop()
    tape.seek(-90000)
    local s = string.rep("\xAA", 8192)
    for i = 1, k + 8191, 8192 do
        tape.write(s)
    end
    tape.seek(-k)
    tape.seek(-90000)
end

local function play(songID)
    print("Playing " .. getSongID(songID.name) .. " | " .. songID.author .. " - " .. songID.name)
    wipe()
    tape.stop()
    tape.seek(-tape.getSize()) -- go back to the start

    local h = http.get(songID.file, nil, true) -- write in binary mode
    tape.write(h.readAll()) -- that's it
    h.close()

    tape.seek(-tape.getSize()) -- back to start again
    tape.setSpeed(songID.speed)
    while tape.getState() ~= "STOPPED" do
      sleep(1)
    end
    tape.play()
end

local function update()
    local s = shell.getRunningProgram()
    handle = http.get("https://raw.githubusercontent.com/RubenHetKonijn/musicify/main/musicify.lua")
    if not handle then
        print("Could not download new version, Please update manually.")
    else
        data = handle.readAll()
        local f = fs.open(s, "w")
        handle.close()
        f.write(data)
        f.close()
        shell.run(s)
        return
    end
end

if version < index.latestVersion then
    print("Client outdated, Updating Musicify.") -- Update check
    update()
end

musicify.help = function (arguments)
    print([[
Usage: <action> [arguments]
Actions:
musicify
    help       -- Displays this message
    list       -- Displays a list of song you can play
    play <id>  -- Plays the specified song by it's ID
    shuffle [from] [to] -- Starts shuffle mode in the specified range
    stop       -- Stops playback
    Update     -- Updates musicify
]])
end

musicify.update = function (arguments)
    print("Updating musicify, please hold on.")
    update()
end

musicify.stop = function (arguments)
    print("Stopping.")
    tape.stop()
end

musicify.list = function (arguments)
    print("Format: `ID | Author - Name")
    for i in pairs(index.songs) do
        print(i .. " | " .. index.songs[i].author .. " - " .. index.songs[i].name)
    end
    print("(Use Mildly Better Shell if you want to scroll through the list!)")
end

musicify.shuffle = function (arguments)
    local from = arguments[1] or 1
    local to = arguments[2] or #index.songs
    if tostring(arguments[1]) and not tonumber(arguments[1]) and arguments[1] then
        print("Please specify arguments like `musicify shuffle 1 5`")
        return
    end
    while true do
        print("Currently in shuffle mode, press <CTRL>+T to exit. Use <Enter> to skip songs")
        local ranNum = math.random(from, to)
        play(index.songs[ranNum])

        -- Wait till the end of the song

        local function songLengthWait()
            sleep(index.songs[ranNum].time)
        end

        local function keyboardWait()
            while true do
                local event, key = os.pullEvent("key")
                if key == keys.enter then
                    print("Skipping!")
                    break
                end
            end
        end

        parallel.waitForAny(songLengthWait,keyboardWait)
    end
end

musicify.volume = function (arguments)
    if not arguments[1] or not tonumber(arguments[1]) or tonumber(arguments[1])>100 or tonumber(arguments[1]) < 1 then
        print("Please specify a valid volume level between 0-100")
        return
    end
    tape.setVolume(arguments[1] / 100)
end

musicify.play = function (arguments)
    if not arguments then
        print("Resuming playback...")
        return
    end
    if not tonumber(arguments[1]) or not index.songs[tonumber(arguments[1])] then
        print("Please provide a valid track ID. Use `list` to see all valid track numbers.")
        return
    end
    if not tape.isReady() then
        print("ERROR: You need to have a tape in the tape drive")
        return
    end
    play(index.songs[tonumber(arguments[1])])
    tape.play()
end

musicify.info = function (arguments)
    print("Current version: " .. version)
    print("Latest version: " .. index.latestVersion)
end

musicify.loop = function (arguments)
    if tostring(arguments[1]) and not tonumber(arguments[1]) then
        print("ERROR: Please specify a song ID")
        return
    end
    while true do
    play(index.songs[tonumber(arguments[1])])
    sleep(index.songs[tonumber(arguments[1])].time)
    end
end

command = table.remove(args, 1)

musicify.index = index

if command == "musicify" then
    return musicify
elseif not command then
    print("Please provide a valid command. For usage, use `musicify help`.")
else
    musicify[command](args)
end

return musicify
