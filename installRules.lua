repositoryURL = "https://raw.github.com/Jabulba/SpawnCC/master/"
os.pullEvent = os.pullEventRaw;
function downloadFile(url, file)
	fileData = http.get(url);
	newFile = fs.open(file, "w");
	newFile.write( fileData.readAll() );
	newFile.close();
	fileData.close();
end

function purgeSystem()
	print("Purging the system, please wait...");
	programs = shell.programs();
	for i = 1,#programs do
		write("Purging " .. programs[i] .. "... ");
		if fs.exists(programs[i]) then
			write(" Erasing...");
			fs.delete(programs[i]);
			write(" Complete. ");
		end
	end
	programs = nil;
	print("Restricting access to shell, please wait...");
	programs = shell.programs();
	for i = 1,#programs do
		write("Parsing " .. programs[i] .. "... ");
		write("Restricting access.");
		tempFile = fs.open(programs[i], "w");
		write(".");
		tempFile.write('print("Kono puroguramu wa, shisutemu kara paji sa reta.")');
		write(".");
		tempFile.close();
		print(" Complete.");
		tempFile = nil;
	end
end
purgeSystem();
print("Downloading latest parser version...");
downloadFile(repositoryURL .. "colourTextParser.lua", "colourTextParser.lua");
print("parser installed.");

print("Downloading latest rules files...")
local i = 0;
local rulesFileList = http.get(repositoryURL .. "rulesFiles.List");
while true do
	local file = rulesFileList.readLine();
	if file == nil then break end
	downloadFile(repositoryURL .. "" .. file, file);
	i = i + 1;
end
print(i .. " files downloaded.");

print("")
print("Avalible files:");
local fileList = fs.list("");
for num, file in ipairs(fileList) do
	if string.find(file, ".ctxt") then
		print(num .. ". " .. file);
	end
end

print("");
local sides = { "right", "left", "top", "bottom", "front", "back" };
local peripheralType;
local numDetected = 0;
print("Detecting monitors... ");
configFile = fs.open("colourTextParser.config", "w");
for _,aux in pairs(sides) do
	peripheralType = peripheral.getType(aux);
	if peripheralType == "monitor" then
		if peripheral.call(aux, "isColour") then
			numDetected = numDetected + 1;
			write(aux .. " monitor file: ");
			while true do
				local input = tonumber( (read() or nil) );
				if input and string.find(fileList[input], ".ctxt") then
					configFile.writeLine( fileList[input] );
					break;
				else
					print("Wrong file number!");
				end
			end
		end
	end
end
configFile.close();
if numDetected == 0 then error("No colour monitor detected.", 0) end

print("Writing startup files.");
local startupFile = fs.open("startup", "w");
startupFile.write( 'shell.run("colourTextParser.lua")' );
startupFile.close();
write(".");
local startupFile = fs.open("autorun", "w");
startupFile.write( 'shell.run("colourTextParser.lua")' );
startupFile.close();
write(".");
print("Done.");
print("Rebooting");
os.reboot();
