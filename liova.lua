io.write("\27[0;32mStarting LIOVA Envirement\27[0m\n\27[0;31m[WARNING: LIOVA is build and tested on modern Ubuntu Terminals. If your Terminal does not allow for ASCII Escape Codes, then you will get unpredicted outputs. If your Terminal is not Ubuntu, then Network interfacing and file management will not work.]\27[0m\n")
local debug = true
--Start the loading
--function for if a file exists, e.g. for seting up first times
function FileExists(name)
  local file = io.open(name, "r"); if file ~= nil then io.close(file) return true else return false end
end
--Split a string into a table of words
function Split(input)
  local output = { }
  for word in string.gmatch(input, "%S+") do
    table.insert(output, word)
  end
  return output
end
--Split a string into a table of value from a character
function Splitchar(input, char)
  local output = { }
  for word in string.gmatch(input, "([^".. char .."]+)") do
    table.insert(output, word)
  end
  return output
end
--Function for getting a value from a key
function Getvariablevalue(key)
  local variablesfile = io.open(".liovavariables", "r")
  local allvariables = variablesfile:read("*all")
  local splitvariables = Splitchar(allvariables, "\n")
  for int = 1, #splitvariables do
    if string.find(splitvariables[int], key .. " ") then
      local value = Split(splitvariables[int])
      return value[2]
    end
  end
  return "[n/v]"
end
--Get requirements
io.write("Getting requirements\n")
Requirements = { }
function Getrequirements()
  local functionsfile = io.open(".liovafunctions", "a+")
  local allfunctions = functionsfile:read("*all")
  local splitfunctions = Splitchar(allfunctions, "[^\r\n]+")
  for int = 1, #splitfunctions do
    table.insert(Requirements, require(splitfunctions[int]))
    io.write("   " .. splitfunctions[int] .. "\n")
  end
end
if debug then
  Getrequirements()
else
  if pcall(Getrequirements) then
    io.write("   Successfully got requirements\n")
  else
    io.write("   Failed to get requirements\n")
  end
end
io.write("   Found " .. #Requirements .. " Requirement(s)\nRequirements done\n")
--check to see if the .liovahelp file exists
if not FileExists(".liovahelp") then
  io.write("Missing Help file! Fetching...\n[executing]\n\n")
  os.execute("wget -O .liovahelp https://raw.githubusercontent.com/Anthony-Minecraft/LIOVA/main/liovahelp.txt")
  io.write("[done]\n")
else
  io.write("Found help file\n")
end
--check for json file, found at
if not FileExists("json.lua") then
  io.write("Missing JSON file! Fetching...\n[executing]\n\n")
  os.execute("wget -O json.lua https://raw.githubusercontent.com/rxi/json.lua/master/json.lua")
  io.write("[done]\n")
else
  io.write("Found JSON file\n")
end
--[[
ANSII Color Values 
\27[<colorcode>m
Black        0;30     Dark Gray     1;30
Red          0;31     Light Red     1;31
Green        0;32     Light Green   1;32
Brown/Orange 0;33     Yellow        1;33
Blue         0;34     Light Blue    1;34
Purple       0;35     Light Purple  1;35
Cyan         0;36     Light Cyan    1;36
Light Gray   0;37     White         1;37
Clear        0
]]--

--The main function that will do the command line interface
function Commandline(commandInput, should)
  local command = { }
  if not should then
    io.write("!> ")
    local input = io.read()
    command = Split(input)
  else
    command = Split(commandInput)
  end
  --process the command for varibles
  for wordcount = 1, #command do
    --variable
    if string.find(command[wordcount], "&#") then
      command[wordcount] = Getvariablevalue(command[wordcount]:gsub("&#", "")):gsub("#s#", " ")
    end
  end
  --run thorugh all commands
  --help command
  if string.find(command[1], "help") then
    local helpfile = io.open(".liovahelp", "r")
    io.write(helpfile:read("*all") .. "\n")
    helpfile:close()
  --exit command
  elseif string.find(command[1], "bye") then
    io.write("   Goodbye!\n")
    error({code=0})
  --varible commands
  elseif string.find(command[1], "variable") then
    if #command >= 4 then
      if string.find(command[2], "make") then
        if string.find(command[4], "->list") then
          local words = { }
          for wordcount = 5, #command do
            table.insert(words, command[wordcount])
          end
          local variablesfile = io.open(".liovavariables", "a")
          variablesfile:write(command[3] .. " list->[" .. table.concat(words, ",") .. "]\n")
          variablesfile:close()
          io.write("   Made a variable {" .. command[3] .. ":[" .. table.concat(words, ",") .. "]}\n")
        else
          local words = { }
          for wordcount = 4, #command do
            table.insert(words, command[wordcount])
          end
          local variablesfile = io.open(".liovavariables", "a")
          variablesfile:write(command[3] .. " " .. table.concat(words, "#s#") .. "\n")
          variablesfile:close()
          io.write("   Made a variable {" .. command[3] .. ":" .. table.concat(words, " ") .. "}\n")
        end
      else
        error({code=3,name="variable"})
      end
    elseif #command == 3 then
      if string.find(command[2], "read") then
        local variablesfile = io.open(".liovavariables", "r")
        local allvariables = variablesfile:read("*all")
        local splitvariables = Splitchar(allvariables, "[^\r\n]+")
        local found = false
        for int = 1, #splitvariables do
          if string.find(splitvariables[int], command[3] .. " ") then
            local value = Split(splitvariables[int])
            io.write("   " .. value[2]:gsub("#s#", " ") .. "\n")
            found = true
          end
        end
        if not found then
          io.write("   No varible '" .. command[3] .. "' stored\n")
        end
      else
        error({code=3,name="variable"})
      end
    elseif #command == 2 then
      if string.find(command[2], "list") then
        local variablesfile = io.open(".liovavariables", "r")
        local allvariables = variablesfile:read("*all")
        local splitvariables = Splitchar(allvariables, "\n")
        for int = 1, #splitvariables do
          local set = Split(splitvariables[int])
          io.write("   " .. set[1] .. " : " .. set[2]:gsub("#s#", " ") .. "\n")
        end
      else
        error({code=3,name="variable"})
      end
    elseif #command >= 5 then
      if string.find(command[2], "concat") then
        local words = { }
        for wordcount = 4, #command do
          table.insert(words, command[wordcount])
        end
        local variablesfile = io.open(".liovavariables", "a")
        variablesfile:write(command[3] .. " " .. table.concat(words, "#s#") .. "\n")
        variablesfile:close()
      else
        error({code=3,name="variable"})
      end
    else
      error({code=3,name="variable"})
    end
  --function commands for custom lua setups
  elseif string.find(command[1], "function") then
    if #command == 2 then
      if string.find(command[2], "list") then
        local functionsfile = io.open(".liovafunctions", "r")
        local allfunctions = functionsfile:read("*all")
        local splitfunctions = Splitchar(allfunctions, "[^\r\n]+")
        for int = 1, #splitfunctions do
          io.write("   " .. splitfunctions[int] .. "\n")
        end
      end
    elseif #command == 3 then
      if string.find(command[2], "require") then
        local functionsfile = io.open(".liovafunctions", "a")
        functionsfile:write(command[3] .. "\n")
        functionsfile:close()
        io.write("   Added the requirement '" .. command[3] .. "'\n")
      elseif string.find(command[2], "do") then
        local luastring = command[3]
        io.write("   Attempting to run '" .. luastring .. "'\n[" .. luastring ..":start]\n")
        local luascript = loadstring(luastring)
        luascript()
        io.write("\n[" .. luastring ..":end]\n")
      else
        error({code=3,name="function"})
      end
    else
      error({code=3,name="function"})
    end
  --the say command
  elseif string.find(command[1], "say") then
    local text = table.concat(command, " ", 2)
    io.write(text .. "\n")
  --math
  elseif string.find(command[1], "math") then
    if #command == 1 then
      local mathing = true
      local ans = ""
      io.write("   LIOVA Lua Math Terminal\n")
      while mathing do
        io.write("   #> ")
        local equation = io.read():gsub("ans", ans)
        local result = loadstring("return " .. equation)
        io.write("    = " .. result() .. "\n")
        ans = result
      end
    else
      local equation = table.concat(command, " ", 2)
      local result = loadstring("return " .. equation)
      io.write("   " .. result() .. "\n")
    end
  else if string.find(command[1], "for") then
      if string.find(command[6], "--c") then
        local list = Splitchar(command[2]:gsub("%]", ""):gsub("%[", ""), ",")
        local variableName = command[4]
        for index = 1, #list do
          local scriptString = table.concat(command, " ", 7):gsub(variableName, list[index])
          local script = loadstring("Commandline(\"" .. scriptString .. "\", true)")
          script()
        end
      else
        --should be like "for <list> as <varible> do <command>"
        local list = Splitchar(command[2]:gsub("%]", ""):gsub("%[", ""), ",")
        local variableName = command[4]
        for index = 1, #list do
          local scriptString = table.concat(command, " ", 6):gsub(variableName, list[index])
          local script = loadstring(scriptString)
          script()
        end
      end
    elseif string.find(command[1], "update") then
      if string.find(command[2], "-yes") then
        io.write("Updating...\n[executing]\n\n")
        os.execute("wget -O .liovahelp https://pastebin.com/raw/fcR9m6BT")
        io.write("[done]\nRunning liovaupdate.sh\n\n")
      else
        io.write("   Not updating. Try 'update -yes' to update")
      end
    elseif string.find(command[1], "game") then
      local game = require("./game")
      if command[2] ~= nil and string.find(command[2], "save") then
        game.runFrom(command[3])
      else
        game.run(command[2])
      end
  --not a recognized command
    else
      error({code=2,name=command[1]})
    end
  end
end
--While loop to keep the function going
--while loop varibles
local running = true
local goodcommands = 0
local badcommands = 0
--run the loop
io.write("LIOVA (Lua Input/Ouput Virtual Assistant) 2022 October\n")
while running do
  if debug then
    Commandline()
  else
    local status, error = pcall(Commandline)
    if status then
      --ran with no errors
      goodcommands = goodcommands + 1
    else
      --error happened or the program was stopped
      --if errorcode is 0, stop with no error
      if error.code == 0 then
        running = false
        goodcommands = goodcommands + 1
      else
        --an error happened, report which one
        if error.code == 1 then
          --unknown error
          io.write("   An error in the programming has occured\n")
        elseif error.code == 2 then
          --unknown command
          io.write("   Invailed command '" .. error.name .. "'. Try 'help' to see all commands\n")
        elseif error.code == 3 then
          --syntax error
          io.write("   Syntax error. Try 'help' for more information\n")
        end
        badcommands = badcommands + 1
        io.write("   Stopping bad command\n")
      end
    end
  end
end
--end the program
local totalcommands = goodcommands + badcommands
io.write("   Commands: " .. totalcommands .. "; Good: " .. goodcommands .. "; Bad: " .. badcommands .."\n   Ending LIOVA\n")