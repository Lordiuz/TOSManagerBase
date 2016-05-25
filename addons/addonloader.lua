ui.SysMsg("==== addonLoader ====");

addonloader = {};
addonloader.loaded = false;

-- ======================================================
--	settings
-- ======================================================

addonloader.settings = {};
addonloader.settings.devMode = false;
addonloader.settings.closeAfter = true;

-- ======================================================
--	debug
-- ======================================================

function addonloader.debug(msg) 
	if (addonloader.settings.devMode) then
		CHAT_SYSTEM(msg);
	end
end

-- ======================================================
--	files
-- ======================================================

function addonloader.dofile(fullpath) 
	local f, error = io.open(fullpath,"r");
	if (f ~= nil) then
		io.close(f);
		dofile(fullpath);
		return true;
	else 
		return false;
	end
end

function addonloader.load(addonname) 
	return addonloader.dofile('../addons/'..addonname..'/'..addonname..'.lua');
end

-- ======================================================
--	Excrulon compatibility
-- ======================================================

addonloader.dofile('../addons/utility.lua');

-- ======================================================
--	folders
-- ======================================================

_G["ADDON_LOADER"] = {};

addonloader.run = function()
	ui.SysMsg("Addonloader running...");
	addonloader.folders = {};

	local info = debug.getinfo(1,'S');
	local directory = info.source:match[[^@?(.*[\/])[^\/]-$]];

	local i, addons, popen = 0, {}, io.popen;
	for folder in popen('dir "'..directory..'" /b /ad'):lines() do
	   	local loaded = addonloader.load(folder);	   	
	   	if (loaded) then table.insert(addonloader.folders,folder); end	  
	end

	addonloader.debug('Initializing addons...');

	for i,folder in pairs(addonloader.folders) do

		addonloader.debug('- '..folder);
		local fn = _G['ADDON_LOADER'][folder];
		local ok = true;
		if fn then ok = fn(); end
		if (not ok) then CHAT_SYSTEM('['..folder..'] failed.') end
	end

	ui.SysMsg("Addonloader done!");
	addonloader.loaded = true;
end

-- ======================================================
--	calling it when the button is clicked
-- ======================================================

addonloader.run();

-- ======================================================
-- adjusting the addon button frame
-- ======================================================

local addonLoaderFrame = ui.GetFrame("addonloader");
addonLoaderFrame:Move(0, 0);
addonLoaderFrame:SetOffset(500,30);

-- ======================================================
-- adjusting the addon button frame
-- ======================================================

if (addonloader.settings.closeAfter) then
	addonLoaderFrame:ShowWindow(0);
else
	addonLoaderFrame:ShowWindow(1);
end

-- ======================================================
-- hooking it on map-init
-- ======================================================

function addonloader_mapOnInit()
	if (addonloader.loaded) then
		local addonLoaderFrame = ui.GetFrame("addonloader");
		addonLoaderFrame:ShowWindow(0);
	end
end

SETUP_HOOK(addonloader_mapOnInit,'MAP_ON_INIT');
