os.pullEvent = os.pullEventRaw;
function newLine(peripheral)
	local peripheralSizeX, peripheralSizeY = peripheral.getSize();
	local peripheralCursorPosX, peripheralCursorPosY = peripheral.getCursorPos();
	if peripheralCursorPosY == peripheralSizeY then
		peripheral.scroll(1);
		peripheral.setCursorPos(1, peripheralCursorPosY);
	else
		peripheral.setCursorPos(1, peripheralCursorPosY+1);
	end
end

function parseColours(data, peripheral)
	local i = 1;
	local index = 1;
	local tables = {};
	while true do
		local a, b = data:find("|[a-p]&", i);
		if a == nil then
			tables[index] = string.sub(data, i) .. "";
			break;
		end
		tables[index] = string.sub(data, i, a-1) .. "";
		tables[index+1] = string.sub(data, a, b) .. "";
		index = index + 2;
		i = b+1;
	end
	for key,value in pairs(tables) do
		if value:find("|[a-p]&") then
			if value == "|b&" then
				peripheral.setTextColour(2);
			elseif value == "|c&" then
				peripheral.setTextColour(4);
			elseif value == "|d&" then
				peripheral.setTextColour(8);
			elseif value == "|e&" then
				peripheral.setTextColour(16);
			elseif value == "|f&" then
				peripheral.setTextColour(32);
			elseif value == "|g&" then
				peripheral.setTextColour(64);
			elseif value == "|h&" then
				peripheral.setTextColour(128);
			elseif value == "|i&" then
				peripheral.setTextColour(256);
			elseif value == "|j&" then
				peripheral.setTextColour(512);
			elseif value == "|k&" then
				peripheral.setTextColour(1024);
			elseif value == "|l&" then
				peripheral.setTextColour(2048);
			elseif value == "|m&" then
				peripheral.setTextColour(4096);
			elseif value == "|n&" then
				peripheral.setTextColour(8192);
			elseif value == "|o&" then
				peripheral.setTextColour(16384);
			elseif value == "|p&" then
				peripheral.setTextColour(32768);
			else
				peripheral.setTextColour(1);
			end
		else
			peripheral.write(value);
		end
	end
end

function readConfig(monitorList)
	local file = fs.open("colourTextParser.config", "r");
	local fileNames = {};
	for num, name in ipairs(monitorList) do
		table.insert(fileNames, file.readLine());
	end
	file.close();
	return fileNames;
end

function getMonitor()
	local sides = { "right", "left", "top", "bottom", "front", "back" };
	local peripheralType;
	local monitorList = {};
	for _,aux in pairs(sides) do
		peripheralType = peripheral.getType(aux);
		print((peripheralType or "nothing") .. " detected to the " .. aux);
		if peripheralType == "monitor" then
			if peripheral.call(aux, "isColour") then
				table.insert(monitorList, peripheral.wrap(aux));
			else
				print("The monitor doesn't supports colours", 0);
				os.sleep(1);
				os.reboot();
			end
		end
	end
	if monitorNumbers == 0 then
		error("No monitor detected.", 0);
	end
	return(monitorList)
end

os.sleep(1);
local monitorList = getMonitor();
local rulesFiles = readConfig(monitorList);
for num, monitor in ipairs(monitorList) do
	local rules = fs.open(rulesFiles[num], "r");
	local textSize = tonumber(rules.readLine());
	if textSize == nil then
		error("The first line in the file must be a number between 0.5 and 5, but was blank!");
	elseif not ((textSize >= 0.5) and (textSize <= 5.0)) then
		error("The first line in the file must be the text size, the number must be between 0.5 and 5.0 but is " .. textSize,0);
	end
	monitor.setTextScale(textSize);
	local monitorSizeX, monitorSizeY = monitor.getSize();
	monitor.clear();
	monitor.setCursorPos(1, monitorSizeY);
	while true do
		local line = rules.readLine();
		if line == nil then break end
		parseColours(line, monitor);
		newLine(monitor);
	end
	rules.close();
end

print("Nyuryoku zokko suru ni wa anata no pasuwado");
while true do
	local input = read();
	if input == "Eguzairu - Tek-sha" then
		print("Konpyutasheru wa shokyo.");
		error("Bye!", 0);
	else
		print("Anata wa machigatte himitsu no kotoba o nyuryoku shimashita.");
		sleep(5);
	end
end
