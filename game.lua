local game = { _version = "0.0.1" }
local json = require("json")
--other functions
function has_value (tab, val)
  for index, value in ipairs(tab) do
    if value == val then return true end
  end
  return false
end

function term_write(string)
  io.write(string)
  --os.execute('echo -e "' .. string .. '"')
end
--code
--global varibles
local gameData, eventsData, actionData, locationsData, itemData, mainFile
--global gameplay varibles
local inventory = { }
local level = 0
local money = 0
--functions
function game.run(file)
  mainFile = file
  local gameFile = io.open('./game/' .. mainFile, "r")
  gameData = json.decode(gameFile:read("*all"))
  eventsData = json.decode(io.open('./game/' .. gameData.MapData.Events):read("*all"))
  actionData = json.decode(io.open('./game/' .. gameData.MapData.Interactions):read("*all"))
  locationsData = json.decode(io.open('./game/' .. gameData.MapData.Locations):read("*all"))
  itemData = json.decode(io.open('./game/' .. gameData.MapData.Items):read("*all"))
  --main game loop
  level = 1
  money = gameData.PlayerStartData.Funds
  Event(eventsData.Events[1])
  --end loop
  gameFile:close()
end
--run the game, but do it from a save
function game.runFrom(file)
  local save = json.decode(io.open('./game/' .. file, "r"):read("*all"))
  mainFile = save.Map
  local gameFile = io.open('./game/' .. mainFile, "r")
  gameData = json.decode(gameFile:read("*all"))
  eventsData = json.decode(io.open('./game/' .. gameData.MapData.Events):read("*all"))
  actionData = json.decode(io.open('./game/' .. gameData.MapData.Interactions):read("*all"))
  locationsData = json.decode(io.open('./game/' .. gameData.MapData.Locations):read("*all"))
  itemData = json.decode(io.open('./game/' .. gameData.MapData.Items):read("*all"))
  --main game loop
  level = save.Level
  inventory = save.Inventory
  money = save.Money
  term_write("<Menu>\nRight now, there are no active Dialog. You can check your inventory [inventory], check your maps [map], or exit the game [quit]. You are currenly on level: " .. level .. "\n")
  NextEvent(eventsData.Events[level])
  --end loop
  gameFile:close()
end
--do an event
function Event(e)
  term_write("\27[0;36m" .. e.Person .. ":\27[0m \"" .. e.Display .. "\"\n")
  if #e.Interactions ~= 0 then
    for interaction = 1, #e.Interactions do
      Action(e.Interactions[interaction], e.Person)
    end
  end
  if #e.Options ~= 0 then
    for i = 1, #e.Options do
      if string.find(e.Options[i].IType, "Dialog") then
        term_write("   [" .. i .. "] \"" .. e.Options[i].Text .. "\"\n")
      elseif string.find(e.Options[i].IType, "Action") then
        term_write("   [" .. i .. "] "  .. e.Options[i].Text .. "\n")
      end
    end
    NextEvent(e)
  else
    Menu()
  end
end
--Menu dialog
function Menu()
  term_write("\n<Menu>\nRight now, there are no active Dialogs. You can check your inventory [inventory], check your maps [map], or exit the game [quit]. You are currenly on level: " .. level .. "\n")
  local loop = true
  while loop do
    term_write("\27[1;36mmenu> \27[0m")
    local input = io.read()
    term_write("\27[2F\27[0J")
    --leave the game
    if string.find(input, "quit") then
      --ask for saving or not
    term_write("Do you want to save? [yes|no]\n> ")
    if string.find(io.read(), "yes") then
      term_write("Saving game...\n")
      local saveData = { Map=mainFile, Inventory=inventory, Level=level, Money=money }
      term_write("   Got data... " .. json.encode(saveData) .. "\n   Opening file...\n")
      local saveFile = assert(io.open("save.game", "w"))
      term_write("   Opened file\n   Writing...\n")
      saveFile:write(json.encode(saveData))
      saveFile:close()
      term_write("   Wrote to file\nGame saved!\n")
      end
      term_write("Quitting Game\n")
    elseif string.find(input, "inventory") then
      Inventory()
    elseif string.find(input, "map") then
      loop = false
      Map()
    else
      term_write("Sorry?\n")
    end
  end
end
--dialog to handle input
function NextEvent(e)
  term_write("\27[1;36mlevel> \27[0m")
  local input = io.read()
  term_write("\27[" .. (#e.Options + 1) .. "F\27[0J")
  if tonumber(input) then
    level = e.Options[tonumber(input)].Go
    if e.Options[tonumber(input)].IType == "Dialog" then
      term_write("\27[1;36mYou: \27[0m\"" .. e.Options[tonumber(input)].Text .. "\"\n")
    elseif e.Options[tonumber(input)].IType == "Action" then
      term_write("\27[1;36mYou " .. e.Options[tonumber(input)].Text .. "\27[0m\n")
    end
    Event(eventsData.Events[e.Options[tonumber(input)].Go])
  else
    term_write("Sorry?\n")
    NextEvent(e)
  end
end
--do an embedded action to the player
function Action(action, person)
  local info = actionData.Interactions[action]
  if string.find(info.IType, "Give") then
    for i = 1, #info.Data.Items do
      for x=1, info.Data.Items[i].Amount do
        table.insert(inventory, info.Data.Items[i].Name)
      end
      term_write("   \27[1;32m" .. person .. " gave " .. info.Data.Items[i].Amount .. " " .. info.Data.Items[i].Name .. " to player\27[0m\n")
    end
  elseif info.IType == "Money" then
    money = money + info.Data.Amount
    term_write("   \27[1;32m" .. person .. " gave $" .. info.Data.Amount .. " to player. You now have $" .. money .. ".\27[0m\n")
  end
end
--open the map for travel
function Map()
  --opening dialog
  term_write("<Map>\nExit [exit]\n   Village\n   [b] : Blacksmith   (CLOSED)\n   [t] : Trading Post (OPEN)\n   Locations\n")
  --loop thorugh availible places
  local seen = 1
  local go = { }
  for index = 1, #locationsData.Locations do
    if has_value(inventory, locationsData.Locations[index].Required) then
      term_write("     [" .. seen .. "] : " .. locationsData.Locations[index].Name .. "\n")
      table.insert(go, locationsData.Locations[index].Name)
      seen = seen + 1
    end
  end
  --take input
  term_write("\27[1;36mmap> \27[0m")
  local input = io.read()
  term_write("\27[" .. (#locationsData.Locations + 5) .. "F\27[0J")
  --process input
  if string.find(input, "exit") then
    term_write("\n<Menu>\n")
Event({ Person="Mahphius the Wise", Display="It's a far road. Luckily Maps make things smaller, don't they?", Options={}, Interactions={}})
  elseif string.find(input, "t") then
    Trade()
    return
  elseif tonumber(input) then
    local startPoint
    for i = 1, #locationsData.Locations do
      if locationsData.Locations[i].Name == go[tonumber(input)] then
        startPoint = locationsData.Locations[i].Start
      end
    end
    Event(eventsData.Events[startPoint])
    return
  end
end
--open up the trade dialog
function Trade()
  --start displaying items to buy
  term_write("<Trading Post>\nExit [exit] | You have: $" .. money .. "\n")
  local itemIndex = 1
  local buys = { }
  for index = 1, #itemData.Items do
    local Item = itemData.Items[index]
    if Item.Trade.Buyable then
      term_write("   [" .. itemIndex .. "] ($" .. Item.Trade.Cost .. ") : " .. Item.Name .. "\n")
      itemIndex = itemIndex + 1
      table.insert(buys, { key=Item.Key, cost=Item.Trade.Cost, name=Item.Name })
    end
  end
  local loop = true
  while loop do
    --the interaction to buy items
    term_write("\27[1;36mbuy> \27[0m")
    local input = io.read()
    if string.find(input, "exit") then
      loop = false
    elseif tonumber(input) then
      local Item = buys[tonumber(input)]
      if Item.cost <= money then
        table.insert(inventory, Item.key)
        money = money - Item.cost
        term_write("   You recieved: " .. Item.name ..  ".\nYou have: $" .. money .. " remainning\n")
      else
        term_write("   You do not have the Funds to do this.\n")
      end
    end
  end
  term_write("\n<Menu>\n")
  Event({ Person="Man'hern the Rich", Display="So they say money can't buy happieness... Well, have you ever seen the face of a satisfied customer?", Options={}, Interactions={}})
end
--open the inventory
function Inventory()
  term_write("<Inventory>\n")
  for index = 1, #inventory do
    term_write("   " .. inventory[index] .. "\n")
  end
  Event({ Person="Peasent the Pleasent", Display="Now how can one bag carry that much stuff? Magic, I tell ya.", Options={}, Interactions={}})
end
--end code
return game