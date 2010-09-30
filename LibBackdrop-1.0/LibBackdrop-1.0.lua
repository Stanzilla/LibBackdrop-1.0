--[[
	Replacement library for SetBackDrop
	Blizzard decided they want to deprecate SetBackDrop, so this library is intended as a replacement for simple table drop
	and decorate a given frame with a backdrop.
	Credits to Lilsparky for doing the math for cutting up the quadrants
--]]
local MAJOR, MINOR = "LibBackdrop-1.0", 1
local Backdrop, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not Backdrop then return end -- No upgrade needed

local edgePoints = {
	TOPLEFTCORNER = "TOPLEFT",
	TOP = "TOP",
	TOPRIGHTCORNER = "TOPRIGHT",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	BOTLEFTCORNER = "BOTTOMLEFT",
	BOT = "BOTTOM",
	BOTRIGHTCORNER = "BOTTOMRIGHT"
}

--- API
-- This method will embed the new backdrop functionality onto your frame
-- This will replace the standard SetBackdropxxx functions and will add
-- the following functions to your frame.
-- SetBackdropGradient(orientation,minR,minG,minB,maxR,maxG,maxB) setup a gradient on the bg texture
-- SetBackdropGradientAlpha(orientation,minR,minG,minB,minA,maxR,maxG,maxB,maxA) setup a gradient on the bg texture
-- SetBackdropBorderGradient(orientation,minR,minG,minB,maxR,maxG,maxB) setup a gradient on the border texture
-- SetBackdropBorderGradientAlpha(orientation,minR,minG,minB,minA,maxR,maxG,maxB,maxA) setup a gradient on the border texture
-- @param frame to enhance

function Backdrop:Embed(frame)
	if frame._backdrop then return end
	-- Create our enhancement frame we will use to create the backdrop
	frame._backdrop = CreateFrame("Frame",nil,frame)
	for k,v in pairs(edgePoints) do
		local texture = frame:CreateTexture(nil,"BORDER")
		frame._backdrop["Edge"..k] = texture
	end
	frame._backdrop["bgTexture"] = frame:CreateTexture(nil,"BACKGROUND",nil,-1)	
	frame.SetBackdrop = Backdrop.SetBackdrop -- Set the backdrop of the frame according to the specification provided. 
    frame.SetBackdropBorderColor = Backdrop.SetBackdropBorderColor --(r, g, b[, a]) - Set the frame's backdrop's border's color. 
    frame.SetBackdropColor = Backdrop.SetBackdropColor --(r, g, b[, a]) - Set the frame's backdrop color.
	frame.SetBackdropGradient = Backdrop.SetBackdropGradient -- New API
	frame.SetBackdropGradientAlpha = Backdrop.SetBackdropGradientAlpha -- New API
	frame.SetBackdropBorderGradient = Backdrop.SetBackdropBorderGradient -- New API
	frame.SetBackdropBorderGradientAlpha = Backdrop.SetBackdropBorderGradientAlpha -- New API
end

--[[
	FUTURE, once blizz removes SetBackdrop, we should hook CreateFrame and automatically embed ourselves
	to allow for backwards compat
--]]

--[[
	{ 
	  bgFile = "bgFile", 
	  edgeFile = "edgeFile", tile = false, tileSize = 0, edgeSize = 32, 
	  insets = { left = 0, right = 0, top = 0, bottom = 0 
	}
	Alternatily you can use the new blizz style of borders
	where you have a corner file and 1 file for each side. To build those style of borders
	be sure each quadrant is 32x32 blocks. See Interface\DialogFrame\DialogFrame-Corners and Interface\DialogFrame\DialogFrame-Top
	for examples. To pass those style borders in, setup the edge file as follows
	edgeFile = {
		["TOPLEFTCORNER"] = "Interface/DialogFrame/DialogFrame-Corners",
		["TOPRIGHTCORNER"] = "Interface/DialogFrame/DialogFrame-Corners",
		["BOTLEFTCORNER"] = "Interface/DialogFrame/DialogFrame-Corners",
		["BOTRIGHTCORNER"] = "Interface/DialogFrame/DialogFrame-Corners",
		["LEFT"] = "Interface/DialogFrame/DialogFrame-Left",
		["TOP"] = "Interface/DialogFrame/DialogFrame-Top",
		["BOT"] = "Interface/DialogFrame/DialogFrame-Bot",
		["RIGHT"] = "Interface/DialogFrame/DialogFrame-Right",	
	}
--]]

local tilingOptions = {
	["LEFT"] = true,
	["RIGHT"] = true,
	["TOP"] = true,
	["BOTTOM"] = true,
	["TOPLEFTCORNER"] = false,
	["TOPRIGHTCORNER"] = false,
	["BOTLEFTCORNER"] = false,
	["BOTRIGHTCORNER"] = false,
}

-- Corners and their quadrant positions
local corners = {
	TOPLEFTCORNER = 4,
	TOPRIGHTCORNER = 5,
	BOTLEFTCORNER = 6,
	BOTRIGHTCORNER = 7,
}
-- Sides and their quadrant positions
local vSides = {
	LEFT = 0,
	RIGHT = 1,
}
local hSides = {
	TOP = 2,
	BOT = 3,	
}

-- Resizing hook to keep them aligned
local function Resize(frame)
	if not frame then
		return
	end
	local w,h = frame:GetWidth()-frame.edgeSize*2, frame:GetHeight()-frame.edgeSize*2
	for k,v in pairs(vSides) do
		local t = frame["Edge"..k]
		local y = h/frame.edgeSize
		t:SetTexCoord(v*.125, v*.125+.125, 0, y)
	end
	for k,v in pairs(hSides) do
		local t = frame["Edge"..k]
		local y = w/frame.edgeSize
		local x1 = v*.125
		local x2 = v*.125+.125
		t:SetTexCoord(x1,0, x2,0, x1,y, x2, y)
	end
	if frame.tile then
		frame.bgTexture:SetTexCoord(0,w/frame.tileSize, 0,h/frame.tileSize)
	end
end

-- Attach the corner textures
local function AttachCorners(frame)
	for k,v in pairs(corners) do
		local texture = frame["Edge"..k]
		texture:SetPoint(edgePoints[k], frame)
		texture:SetWidth(frame.edgeSize)
		texture:SetHeight(frame.edgeSize)
		texture:SetTexCoord(v*.125,v*.125+.125, 0,1)
	end
end
local nk = {
	["TOPLEFTCORNER"] = { l = 0, r = 0.5, t= 0, b=0.5},
	["TOPRIGHTCORNER"] = { l = 0.5, r = 1, t= 0, b=0.5},
	["BOTLEFTCORNER"] = { l = 0, r = 0.5, t= 0.5, b=1},
	["BOTRIGHTCORNER"] = { l = 0.5, r = 1, t= 0.5, b=1},
}
local function AttachNewCorners(frame)
	for k,v in pairs(corners) do
		local texture = frame["Edge"..k]
		texture:SetPoint(edgePoints[k], frame)
		texture:SetWidth(frame.edgeSize)
		texture:SetHeight(frame.edgeSize)
		texture:SetTexCoord(nk[k].l,nk[k].r,nk[k].t,nk[k].b)
	end	
end
local function AttachNewSides(frame,w,h)
	local offset = 1
	offset = frame.edgeSize /32
	-- Left and Right
	frame["EdgeLEFT"]:SetPoint("TOPLEFT",frame["EdgeTOPLEFTCORNER"],"BOTTOMLEFT",offset,0)
	frame["EdgeLEFT"]:SetPoint("BOTTOMLEFT",frame["EdgeBOTLEFTCORNER"],"TOPLEFT",offset,0)
	frame["EdgeLEFT"]:SetWidth(frame.edgeSize/2)
	frame["EdgeLEFT"]:SetVertTile(true)
	frame["EdgeLEFT"]:SetHorizTile(false)
	frame["EdgeRIGHT"]:SetPoint("TOPRIGHT",frame["EdgeTOPRIGHTCORNER"],"BOTTOMRIGHT")
	frame["EdgeRIGHT"]:SetPoint("BOTTOMRIGHT",frame["EdgeBOTRIGHTCORNER"],"TOPRIGHT")
	frame["EdgeRIGHT"]:SetWidth(frame.edgeSize/2)
	frame["EdgeRIGHT"]:SetVertTile(true)
	frame["EdgeRIGHT"]:SetHorizTile(false)
	-- Top and Bottom
	frame["EdgeTOP"]:SetPoint("TOPLEFT",frame["EdgeTOPLEFTCORNER"],"TOPRIGHT",0,-offset)
	frame["EdgeTOP"]:SetPoint("TOPRIGHT",frame["EdgeTOPRIGHTCORNER"],"TOPLEFT",0,-offset)
	frame["EdgeTOP"]:SetHeight(frame.edgeSize/2)
	frame["EdgeTOP"]:SetVertTile(false)
	frame["EdgeTOP"]:SetHorizTile(true)
	frame["EdgeBOT"]:SetPoint("BOTTOMLEFT",frame["EdgeBOTLEFTCORNER"],"BOTTOMRIGHT")
	frame["EdgeBOT"]:SetPoint("BOTTOMRIGHT",frame["EdgeBOTRIGHTCORNER"],"BOTTOMLEFT")
	frame["EdgeBOT"]:SetHeight(frame.edgeSize/2)
	frame["EdgeBOT"]:SetVertTile(false)
	frame["EdgeBOT"]:SetHorizTile(true)
end
-- Attach the side textures
local function AttachSides(frame,w,h)
	-- Left and Right
	for k,v in pairs(vSides) do
		local texture = frame["Edge"..k]
		texture:SetPoint(edgePoints[k], frame)
		texture:SetPoint("BOTTOM", frame, "BOTTOM", 0, frame.edgeSize)
		texture:SetPoint("TOP", frame, "TOP", 0, -frame.edgeSize)
		texture:SetWidth(frame.edgeSize)
		local y = h/frame.edgeSize
		texture:SetTexCoord(v*.125, v*.125+.125, 0, y)
	end
	-- Top and Bottom
	for k,v in pairs(hSides) do
		local texture = frame["Edge"..k]
		texture:SetPoint(edgePoints[k], frame)
		texture:SetPoint("LEFT", frame, "LEFT", frame.edgeSize, 0)
		texture:SetPoint("RIGHT", frame, "RIGHT", -frame.edgeSize, 0)
		texture:SetHeight(frame.edgeSize)
		local y = w/frame.edgeSize
		local x1 = v*.125
		local x2 = v*.125+.125
		if k == "TOP" then -- Flip
			x1,x2 = x2, x1
		end
		texture:SetTexCoord(x1,0, x2,0, x1,y, x2, y)		
	end
end

--- API
-- Setup the backdrop see normal wow api for table options
function Backdrop:SetBackdrop(options)
	-- Set textures
	local vTile = false
	local hTile = false
	if options.tile then
		hTile = true
	end
	if type(options.edgeFile) == "table" then
		Backdrop.SetNewBackdrop(self,options)
	else
		self._backdrop["bgTexture"]:SetTexture(options.bgFile,hTile,vTile)
		for k,v in pairs(edgePoints) do
			self._backdrop["Edge"..k]:SetTexture(options.edgeFile,tilingOptions[k])
		end
		-- Copy options
		self._backdrop.tileSize = options.tileSize
		self._backdrop.tile = options.tile
		self._backdrop.edgeSize = options.edgeSize
		-- Setup insets
		self._backdrop:SetPoint("TOPLEFT",self,"TOPLEFT",-options.insets.left, options.insets.top)
		self._backdrop:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT", options.insets.right, -options.insets.bottom)
		local w,h = self:GetWidth()-options.edgeSize*2, self:GetHeight()-options.edgeSize*2
		if options.edgeSize > 0 then
			-- Attach croners
			AttachCorners(self._backdrop)
			-- Attach sides
			AttachSides(self._backdrop,w,h)	
		end
		-- Attach Background
		self._backdrop.bgTexture:SetPoint("TOPLEFT", self._backdrop, "TOPLEFT", options.insets.left, -options.insets.top)
		self._backdrop.bgTexture:SetPoint("BOTTOMRIGHT", self._backdrop, "BOTTOMRIGHT", -options.insets.right, options.insets.bottom)
		if options.tile then
			self._backdrop.bgTexture:SetTexCoord(0,w/options.tileSize, 0,h/options.tileSize)		
		end
		self._backdrop:SetScript("OnSizeChanged", Resize)
	end
end
--- API
-- change the backdrop border color
-- @params r,g,b[,a]
function Backdrop:SetBackdropBorderColor(...)
	for k,v in pairs(edgePoints) do
		self._backdrop["Edge"..k]:SetVertexColor(...)
	end
end
--- API
-- set the backdrop color
-- @params r,g,b[,a]
function Backdrop:SetBackdropColor(...)
	self._backdrop["bgTexture"]:SetVertexColor(...)
end

--- API
-- set the backdrop gradient color
-- @params "orientation", minR, minG, minB, maxR, maxG, maxB
function Backdrop:SetBackdropGradient(...)
	self._backdrop["bgTexture"]:SetGradient(...)
end

--- API
-- set the backdrop gradient with alpha
-- @params "orientation", minR, minG, minB, minA, maxR, maxG, maxB, maxA
function Backdrop:SetBackdropGradientAlpha(...)
	self._backdrop["bgTexture"]:SetGradientAlpha(...)
end

--- API
-- set the border gradient color
-- @params "orientation", minR, minG, minB, maxR, maxG, maxB
function Backdrop:SetBackdropBorderGradient(orientation,minR,minG,minB,maxR,maxG,maxB)
	orientation = strupper(orientation)
	if orientation == "HORIZONTAL" then
		self._backdrop["EdgeTOPLEFTCORNER"]:SetGradient(orientation,minR,minG,minB,minR,minG,minB)
		self._backdrop["EdgeBOTLEFTCORNER"]:SetGradient(orientation,minR,minG,minB,minR,minG,minB)
		self._backdrop["EdgeLEFT"]:SetGradient(orientation,minR,minG,minB,minR,minG,minB)
		self._backdrop["EdgeBOT"]:SetGradient(orientation,minR,minG,minB,maxR,maxG,maxB)
		self._backdrop["EdgeTOP"]:SetGradient(orientation,minR,minG,minB,maxR,maxG,maxB)
		self._backdrop["EdgeTOPRIGHTCORNER"]:SetGradient(orientation,maxR,maxG,maxB,maxR,maxG,maxB)
		self._backdrop["EdgeBOTRIGHTCORNER"]:SetGradient(orientation,maxR,maxG,maxB,maxR,maxG,maxB)
		self._backdrop["EdgeRIGHT"]:SetGradient(orientation,maxR,maxG,maxB,maxR,maxG,maxB)		
	else
		self._backdrop["EdgeTOPLEFTCORNER"]:SetGradient(orientation,maxR,maxG,maxB,maxR,maxG,maxB)
		self._backdrop["EdgeBOTLEFTCORNER"]:SetGradient(orientation,minR,minG,minB,minR,minG,minB)
		self._backdrop["EdgeLEFT"]:SetGradient(orientation,minR,minG,minB,maxR,maxG,maxB)
		self._backdrop["EdgeBOT"]:SetGradient(orientation,minR,minG,minB,minR,minG,minB)
		self._backdrop["EdgeTOP"]:SetGradient(orientation,maxR,maxG,maxB,maxR,maxG,maxB)
		self._backdrop["EdgeTOPRIGHTCORNER"]:SetGradient(orientation,maxR,maxG,maxB,maxR,maxG,maxB)
		self._backdrop["EdgeBOTRIGHTCORNER"]:SetGradient(orientation,minR,minG,minB,minR,minG,minB)
		self._backdrop["EdgeRIGHT"]:SetGradient(orientation,minR,minG,minB,maxR,maxG,maxB)		
	end
end

--- API
-- set the border gradient alpha color
-- @params "orientation", minR, minG, minB, minA, maxR, maxG, maxB, maxA
function Backdrop:SetBackdropBorderGradientAlpha(orientation,minR,minG,minB,minA,maxR,maxG,maxB,maxA)
	orientation = strupper(orientation)
	if orientation == "HORIZONTAL" then
		self._backdrop["EdgeTOPLEFTCORNER"]:SetGradientAlpa(orientation,minR,minG,minB,minA,minR,minG,minB,minA)
		self._backdrop["EdgeBOTLEFTCORNER"]:SetGradientAlpha(orientation,minR,minG,minB,minA,minR,minG,minB,minA)
		self._backdrop["EdgeLEFT"]:SetGradientAlpha(orientation,minR,minG,minB,minA,minR,minG,minB,minA)
		self._backdrop["EdgeBOT"]:SetGradientAlpha(orientation,minR,minG,minB,minA,maxR,maxG,maxB,maxA)
		self._backdrop["EdgeTOP"]:SetGradientAlpha(orientation,minR,minG,minB,minA,maxR,maxG,maxB,maxA)
		self._backdrop["EdgeTOPRIGHTCORNER"]:SetGradientAlpha(orientation,maxR,maxG,maxB,maxA,maxR,maxG,maxB,maxA)
		self._backdrop["EdgeBOTRIGHTCORNER"]:SetGradientAlpha(orientation,maxR,maxG,maxB,maxA,maxR,maxG,maxB,maxA)
		self._backdrop["EdgeRIGHT"]:SetGradientAlpha(orientation,maxR,maxG,maxB,maxA,maxR,maxG,maxB,maxA)		
	else
		self._backdrop["EdgeTOPLEFTCORNER"]:SetGradientAlpha(orientation,maxR,maxG,maxB,maxA,maxR,maxG,maxB,maxA)
		self._backdrop["EdgeBOTLEFTCORNER"]:SetGradientAlpha(orientation,minR,minG,minB,minA,minR,minG,minB,minA)
		self._backdrop["EdgeLEFT"]:SetGradientAlpha(orientation,minR,minG,minB,minA,maxR,maxG,maxB,maxA)
		self._backdrop["EdgeBOT"]:SetGradientAlpha(orientation,minR,minG,minB,minA,minR,minG,minB,minA)
		self._backdrop["EdgeTOP"]:SetGradientAlpha(orientation,maxR,maxG,maxB,maxA,maxR,maxG,maxB,maxA)
		self._backdrop["EdgeTOPRIGHTCORNER"]:SetGradientAlpha(orientation,maxR,maxG,maxB,maxA,maxR,maxG,maxB,maxA)
		self._backdrop["EdgeBOTRIGHTCORNER"]:SetGradientAlpha(orientation,minR,minG,minB,minA,minR,minG,minB,minA)
		self._backdrop["EdgeRIGHT"]:SetGradientAlpha(orientation,minR,minG,minB,minA,maxR,maxG,maxB,maxA)		
	end
end

--- API
-- New Backdrop function, for use with the new table layout defined above.
-- called when you pass a new table layout to SetBackdrop
function Backdrop:SetNewBackdrop(options)
	self._backdrop["bgTexture"]:SetTexture(options.bgFile,hTile,vTile)
	for k,v in pairs(edgePoints) do
		self._backdrop["Edge"..k]:SetTexture(options.edgeFile[k],tilingOptions[k])
	end
	-- Copy options
	self._backdrop.tileSize = options.tileSize
	self._backdrop.tile = options.tile
	self._backdrop.edgeSize = options.edgeSize
	-- Setup insets
	self._backdrop:SetPoint("TOPLEFT",self,"TOPLEFT",-options.insets.left, options.insets.top)
	self._backdrop:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT", options.insets.right, -options.insets.bottom)
	local w,h = self:GetWidth()-options.edgeSize*2, self:GetHeight()-options.edgeSize*2
	if options.edgeSize > 0 then
		-- Attach croners
		AttachNewCorners(self._backdrop)
		-- Attach sides
		AttachNewSides(self._backdrop,w,h)	
	end
	-- Attach Background
	self._backdrop.bgTexture:SetPoint("TOPLEFT", self._backdrop, "TOPLEFT", options.insets.left, -options.insets.top)
	self._backdrop.bgTexture:SetPoint("BOTTOMRIGHT", self._backdrop, "BOTTOMRIGHT", -options.insets.right, options.insets.bottom)
	if options.tile then
		self._backdrop.bgTexture:SetTexCoord(0,w/options.tileSize, 0,h/options.tileSize)		
	end
end