--[[

NEEDS:
JSON: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
      in the same directory as this file or change the json varaible

OVERVEIW: This lua program will take a json file and convert it into a file structure, and populating the files as needed.

COMMAND:
lua dir_struct.lua <file path> <creation start directory>
file path: path to file
creation: where the program will make the files

JSON:
A json file should look like this:
[ //must have a list as the top level object
  {
    //many different objects structured like this
    "name": <name>
    "type": <file|directory>
    "content": <string|array for directories>
  }
]

]]--
print("<---------->\nStarting Lua Script\nFile and directory creation program. 2022 August\n\n")
local json = require "json" -- change if you move the JSON file location from this directory
function Generate(data, start)
  for index = 1, #data do
    if string.find(data[index]["type"], "file") then
      print("creating file     : " .. start .. data[index]["name"] .. "\n")
      local makeFile = io.open(start .. data[index]["name"], "w")
      makeFile:write(data[index]["content"])
      makeFile:close()
    elseif string.find(data[index]["type"], "directory") then
      print("creating directory: " .. start .. data[index]["name"] .. "\n")
      os.execute("mkdir " .. start .. data[index]["name"])
      Generate(data[index]["content"], start .. data[index]["name"] .. "/")
    end
  end
end
local params = {...}
local data = json.parse(assert(io.open(params[1], "rb"):read("*all")))
Generate(data, params[2])
print("\n\nEnding Lua Script\n<---------->\n")