--==================================================
-- NabeUI - Part 1
--==================================================

local NabeUI = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Settings / Theme
NabeUI.Theme = {
	Name = "Default",
	MainColor = Color3.fromRGB(80, 120, 255),
	AccentColor = Color3.fromRGB(120, 200, 255),
	BackgroundColor = Color3.fromRGB(20, 20, 24),
	PanelColor = Color3.fromRGB(28, 28, 34),
	SubPanelColor = Color3.fromRGB(36, 36, 44),
	TextColor = Color3.fromRGB(245, 245, 245),
	MutedTextColor = Color3.fromRGB(180, 180, 190),
	SuccessColor = Color3.fromRGB(70, 200, 120),
	DangerColor = Color3.fromRGB(235, 90, 90),
	StrokeColor = Color3.fromRGB(255, 255, 255),
}

NabeUI.Settings = {
	AnimationSpeed = 1,
	FireCooldown = 0.15,
	DragMoveThreshold = 10,
	WindowMinSize = Vector2.new(540, 360),
	WindowMaxSize = Vector2.new(1200, 900),
	ScrollBarThickness = 4,
}

NabeUI._registry = {}
NabeUI._activeWindow = nil
NabeUI._saveData = {}
NabeUI._logs = {}

-- Utilities
local function clamp(v, a, b)
	return math.max(a, math.min(b, v))
end

local function roundTo(v, decimals)
	decimals = decimals or 0
	local m = 10 ^ decimals
	return math.floor(v * m + 0.5) / m
end

local function safeCall(fn, ...)
	if typeof(fn) == "function" then
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("[NabeUI]", err)
		end
	end
end

local function create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function corner(parent, radius)
	return create("UICorner", {
		CornerRadius = radius or UDim.new(0, 8),
		Parent = parent
	})
end

local function stroke(parent, transparency, thickness)
	return create("UIStroke", {
		Transparency = transparency or 0.5,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent
	})
end

local function padding(parent, l, t, r, b)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
		Parent = parent
	})
end

local function registerThemeUpdater(fn)
	table.insert(NabeUI._registry, fn)
end

function NabeUI:SetTheme(newTheme)
	for k, v in pairs(newTheme or {}) do
		self.Theme[k] = v
	end
	for _, fn in ipairs(self._registry) do
		fn(self.Theme)
	end
end

function NabeUI:SetAnimationSpeed(speed)
	self.Settings.AnimationSpeed = clamp(speed or 1, 0.25, 3)
end

function NabeUI:SetSetting(key, value)
	self.Settings[key] = value
end

function NabeUI:Save(key, value)
	self._saveData[tostring(key)] = value
end

function NabeUI:Load(key, default)
	local v = self._saveData[tostring(key)]
	if v == nil then
		return default
	end
	return v
end

function NabeUI:Log(text)
	table.insert(self._logs, tostring(text))
	if self._activeWindow and self._activeWindow._logList then
		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = self.Theme.MutedTextColor,
			Text = tostring(text),
			Parent = self._activeWindow._logList
		})
	end
end

function NabeUI:Notify(title, message, duration)
	duration = duration or 2
	local window = self._activeWindow
	if not window then return end

	local holder = create("Frame", {
		Size = UDim2.fromOffset(290, 66),
		BackgroundColor3 = self.Theme.PanelColor,
		BorderSizePixel = 0,
		Parent = window.Gui
	})
	corner(holder, UDim.new(0, 10))
	stroke(holder, 0.6, 1)

	holder.Position = UDim2.new(1, -310, 1, -88)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = tostring(title),
		TextSize = 14,
		TextColor3 = self.Theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder
	})

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 28),
		Size = UDim2.new(1, -24, 0, 28),
		Font = Enum.Font.Gotham,
		Text = tostring(message),
		TextSize = 13,
		TextWrapped = true,
		TextColor3 = self.Theme.MutedTextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder
	})

	tween(holder, TweenInfo.new(0.18 * self.Settings.AnimationSpeed), {
		Position = holder.Position - UDim2.fromOffset(0, 6)
	})

	task.delay(duration, function()
		if holder and holder.Parent then
			holder:Destroy()
		end
	end)
end

function NabeUI:Confirm(title, message, onYes, onNo)
	local window = self._activeWindow
	if not window then return end

	local overlay = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		Parent = window.Gui
	})

	local modal = create("Frame", {
		Size = UDim2.fromOffset(360, 180),
		Position = UDim2.new(0.5, -180, 0.5, -90),
		BackgroundColor3 = self.Theme.BackgroundColor,
		BorderSizePixel = 0,
		Parent = overlay
	})
	corner(modal, UDim.new(0, 12))
	stroke(modal, 0.6, 1)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.new(1, -32, 0, 22),
		Font = Enum.Font.GothamBold,
		Text = tostring(title),
		TextSize = 16,
		TextColor3 = self.Theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = modal
	})

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 44),
		Size = UDim2.new(1, -32, 0, 68),
		Font = Enum.Font.Gotham,
		Text = tostring(message),
		TextWrapped = true,
		TextSize = 13,
		TextColor3 = self.Theme.MutedTextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = modal
	})

	local yes = create("TextButton", {
		Size = UDim2.fromOffset(150, 34),
		Position = UDim2.fromOffset(16, 132),
		BackgroundColor3 = self.Theme.SuccessColor,
		Text = "Yes",
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = modal
	})
	corner(yes, UDim.new(0, 8))

	local no = create("TextButton", {
		Size = UDim2.fromOffset(150, 34),
		Position = UDim2.new(1, -166, 0, 132),
		BackgroundColor3 = self.Theme.DangerColor,
		Text = "No",
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = modal
	})
	corner(no, UDim.new(0, 8))

	yes.Activated:Connect(function()
		overlay:Destroy()
		safeCall(onYes)
	end)

	no.Activated:Connect(function()
		overlay:Destroy()
		safeCall(onNo)
	end)
end

--==================================================
-- NabeUI - Part 2
--==================================================

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

function NabeUI:CreateWindow(configOrTitle)
	local cfg = {}
	if typeof(configOrTitle) == "table" then
		cfg = configOrTitle
	else
		cfg.Title = configOrTitle
	end

	local self = setmetatable({}, Window)
	self.Config = cfg
	self.Title = cfg.Title or "NabeUI"
	self.Size = cfg.Size or UDim2.fromOffset(680, 450)
	self.Position = cfg.Position or UDim2.new(0.5, -340, 0.5, -225)
	self.MinSize = cfg.MinSize or NabeUI.Settings.WindowMinSize
	self.MaxSize = cfg.MaxSize or NabeUI.Settings.WindowMaxSize
	self.MinimizeText = cfg.MinimizeText or "—"
	self.CloseText = cfg.CloseText or "×"
	self.TabWidth = cfg.TabWidth or 150
	self.ScrollBarThickness = cfg.ScrollBarThickness or NabeUI.Settings.ScrollBarThickness
	self.TabButtons = {}
	self.SelectedTab = nil
	self.Minimized = false
	self._lastFire = 0

	local gui = create("ScreenGui", {
		Name = "NabeUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Parent = PlayerGui
	})
	self.Gui = gui
	NabeUI._activeWindow = self

	local main = create("Frame", {
		Size = self.Size,
		Position = self.Position,
		BackgroundColor3 = NabeUI.Theme.BackgroundColor,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui
	})
	self.Main = main
	corner(main, UDim.new(0, 12))
	stroke(main, 0.65, 1)

	local topbar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = NabeUI.Theme.PanelColor,
		BorderSizePixel = 0,
		Parent = main
	})
	corner(topbar, UDim.new(0, 12))

	local titleLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -140, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = self.Title,
		TextSize = 16,
		TextColor3 = NabeUI.Theme.TextColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar
	})

	local minimize = create("TextButton", {
		Size = UDim2.fromOffset(32, 28),
		Position = UDim2.new(1, -74, 0.5, -14),
		BackgroundColor3 = NabeUI.Theme.SubPanelColor,
		Text = self.MinimizeText,
		TextSize = 18,
		TextColor3 = NabeUI.Theme.TextColor,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = topbar
	})
	corner(minimize, UDim.new(0, 8))

	local close = create("TextButton", {
		Size = UDim2.fromOffset(32, 28),
		Position = UDim2.new(1, -38, 0.5, -14),
		BackgroundColor3 = NabeUI.Theme.DangerColor,
		Text = self.CloseText,
		TextSize = 18,
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Parent = topbar
	})
	corner(close, UDim.new(0, 8))

	local tabBar = create("ScrollingFrame", {
		Position = UDim2.fromOffset(10, 52),
		Size = UDim2.fromOffset(self.TabWidth, self.Size.Y.Offset - 62),
		BackgroundColor3 = NabeUI.Theme.PanelColor,
		BorderSizePixel = 0,
		ScrollBarThickness = self.ScrollBarThickness,
		ScrollBarImageColor3 = NabeUI.Theme.MainColor,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = main
	})
	corner(tabBar, UDim.new(0, 10))
	padding(tabBar, 8, 8, 8, 8)

	create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabBar
	})

	local content = create("Frame", {
		Position = UDim2.fromOffset(170, 52),
		Size = UDim2.new(1, -180, 1, -62),
		BackgroundColor3 = NabeUI.Theme.PanelColor,
		BorderSizePixel = 0,
		Parent = main
	})
	corner(content, UDim.new(0, 10))
	self.Content = content

	local pages = create("Folder", {Parent = content})
	self.Pages = pages

	local logPanel = create("ScrollingFrame", {
		Visible = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = content
	})
	padding(logPanel, 8, 8, 8, 8)
	self._logPanel = logPanel
	self._logList = create("UIListLayout", {Padding = UDim.new(0, 4), Parent = logPanel})

	do
		local dragging, dragStart, startPos, dragInput = false
		topbar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input == dragInput then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input == dragInput then
				dragging = false
			end
		end)
	end

	do
		local resize = create("Frame", {
			Size = UDim2.fromOffset(18, 18),
			Position = UDim2.new(1, -18, 1, -18),
			BackgroundTransparency = 1,
			Parent = main
		})

		local resizing, startMouse, startSize = false
		resize.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startMouse = input.Position
				startSize = main.Size
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - startMouse
				local newX = clamp(startSize.X.Offset + delta.X, self.MinSize.X, self.MaxSize.X)
				local newY = clamp(startSize.Y.Offset + delta.Y, self.MinSize.Y, self.MaxSize.Y)
				main.Size = UDim2.fromOffset(newX, newY)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end)
	end

	minimize.Activated:Connect(function()
		self.Minimized = not self.Minimized
		local target = self.Minimized and UDim2.fromOffset(main.Size.X.Offset, 44) or UDim2.fromOffset(main.Size.X.Offset, main.Size.Y.Offset)
		tween(main, TweenInfo.new(0.22 * NabeUI.Settings.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = target})
		content.Visible = not self.Minimized
		tabBar.Visible = not self.Minimized
	end)

	close.Activated:Connect(function()
		gui:Destroy()
	end)

	registerThemeUpdater(function(theme)
		main.BackgroundColor3 = theme.BackgroundColor
		topbar.BackgroundColor3 = theme.PanelColor
		tabBar.BackgroundColor3 = theme.PanelColor
		content.BackgroundColor3 = theme.PanelColor
		titleLabel.TextColor3 = theme.TextColor
		minimize.BackgroundColor3 = theme.SubPanelColor
		close.BackgroundColor3 = theme.DangerColor
	end)

	function self:CreateTab(name, icon)
		local tab = setmetatable({}, Tab)
		tab.Window = self
		tab.Name = name
		tab.Icon = icon

		tab.Page = create("ScrollingFrame", {
			Visible = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ScrollBarThickness = NabeUI.Settings.ScrollBarThickness,
			ScrollBarImageColor3 = NabeUI.Theme.MainColor,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			Parent = pages
		})
		padding(tab.Page, 8, 8, 8, 8)
		create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab.Page})

		local tabButton = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = NabeUI.Theme.SubPanelColor,
			Text = icon and (icon .. " " .. name) or name,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = NabeUI.Theme.TextColor,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Parent = tabBar
		})
		corner(tabButton, UDim.new(0, 8))

		local function select()
			for _, c in ipairs(pages:GetChildren()) do
				if c:IsA("ScrollingFrame") then c.Visible = false end
			end
			for _, c in ipairs(tabBar:GetChildren()) do
				if c:IsA("TextButton") then c.BackgroundColor3 = NabeUI.Theme.SubPanelColor end
			end
			tab.Page.Visible = true
			tabButton.BackgroundColor3 = NabeUI.Theme.MainColor
			self.SelectedTab = tab
		end

		tabButton.Activated:Connect(function()
			local now = os.clock()
			if now - (self._lastFire or 0) < NabeUI.Settings.FireCooldown then return end
			self._lastFire = now
			select()
		end)

		function tab:AddSection(text)
			local section = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 22),
				Font = Enum.Font.GothamBold,
				Text = tostring(text),
				TextSize = 15,
				TextColor3 = NabeUI.Theme.AccentColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = tab.Page
			})
			return section
		end

		function tab:AddLabel(text)
			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				Font = Enum.Font.Gotham,
				Text = tostring(text),
				TextSize = 13,
				TextColor3 = NabeUI.Theme.MutedTextColor,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = tab.Page
			})
			return label
		end

		function tab:AddButton(text, callback, danger)
			local holder = create("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = NabeUI.Theme.SubPanelColor,
				BorderSizePixel = 0,
				Parent = tab.Page
			})
			corner(holder, UDim.new(0, 8))

			local btn = create("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = tostring(text),
				TextColor3 = danger and NabeUI.Theme.DangerColor or NabeUI.Theme.TextColor,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				AutoButtonColor = false,
				Parent = holder
			})

			btn.MouseEnter:Connect(function()
				tween(holder, TweenInfo.new(0.12 * NabeUI.Settings.AnimationSpeed), {BackgroundColor3 = NabeUI.Theme.MainColor})
			end)
			btn.MouseLeave:Connect(function()
				tween(holder, TweenInfo.new(0.12 * NabeUI.Settings.AnimationSpeed), {BackgroundColor3 = NabeUI.Theme.SubPanelColor})
			end)

			btn.Activated:Connect(function()
				local now = os.clock()
				if now - (self._lastFire or 0) < NabeUI.Settings.FireCooldown then return end
				self._lastFire = now
				safeCall(callback)
			end)

			return {SetText = function(_, v) btn.Text = tostring(v) end}
		end

		function tab:AddToggle(text, default, callback)
			local state = default and true or false
			local holder = create("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = NabeUI.Theme.SubPanelColor, BorderSizePixel = 0, Parent = tab.Page})
			corner(holder, UDim.new(0, 8))

			local btn = create("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = holder})
			create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -80, 1, 0), Text = tostring(text), TextColor3 = NabeUI.Theme.TextColor, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = holder})

			local base = create("Frame", {Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = NabeUI.Theme.BackgroundColor, BorderSizePixel = 0, Parent = holder})
			corner(base, UDim.new(1, 0))
			local knob = create("Frame", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = NabeUI.Theme.MutedTextColor, BorderSizePixel = 0, Parent = base})
			corner(knob, UDim.new(1, 0))

			local function setState(v)
				state = v and true or false
				tween(knob, TweenInfo.new(0.16 * NabeUI.Settings.AnimationSpeed), {
					Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
					BackgroundColor3 = state and NabeUI.Theme.SuccessColor or NabeUI.Theme.MutedTextColor
				})
				base.BackgroundColor3 = state and NabeUI.Theme.MainColor or NabeUI.Theme.BackgroundColor
				safeCall(callback, state)
			end

			btn.Activated:Connect(function()
				local now = os.clock()
				if now - (self._lastFire or 0) < NabeUI.Settings.FireCooldown then return end
				self._lastFire = now
				setState(not state)
			end)

			setState(state)
			return {Set = setState, Get = function() return state end}
		end

		function tab:AddSlider(text, min, max, default, callback, decimals)
			min, max = min or 0, max or 100
			default = default or min
			decimals = decimals or 0
			local value = clamp(default, min, max)

			local holder = create("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = NabeUI.Theme.SubPanelColor, BorderSizePixel = 0, Parent = tab.Page})
			corner(holder, UDim.new(0, 8))

			create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -24, 0, 18), Text = tostring(text), TextColor3 = NabeUI.Theme.TextColor, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = holder})
			local vlabel = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1, -90, 0, 6), Size = UDim2.fromOffset(80, 18), TextColor3 = NabeUI.Theme.MutedTextColor, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = holder})
			local bg = create("Frame", {Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -24, 0, 12), BackgroundColor3 = NabeUI.Theme.BackgroundColor, BorderSizePixel = 0, Parent = holder})
			corner(bg, UDim.new(1, 0))
			local fill = create("Frame", {BackgroundColor3 = NabeUI.Theme.MainColor, BorderSizePixel = 0, Parent = bg})
			corner(fill, UDim.new(1, 0))

			local dragging = false
			local function setValue(v)
				value = clamp(v, min, max)
				local a = (value - min) / (max - min)
				fill.Size = UDim2.new(a, 0, 1, 0)
				vlabel.Text = tostring(roundTo(value, decimals))
				safeCall(callback, roundTo(value, decimals))
			end
			local function fromInput(input)
				local x = clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
				setValue(min + (max - min) * x)
			end
			bg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; fromInput(input) end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then fromInput(input) end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
			end)
			setValue(value)
			return {Set = function(_, v) setValue(v) end, Get = function() return value end}
		end

		function tab:AddTextBox(text, placeholder, callback)
			local holder = create("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = NabeUI.Theme.SubPanelColor, BorderSizePixel = 0, Parent = tab.Page})
			corner(holder, UDim.new(0, 8))
			create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -24, 0, 16), Text = tostring(text), TextColor3 = NabeUI.Theme.TextColor, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = holder})
			local box = create("TextBox", {Position = UDim2.fromOffset(12, 24), Size = UDim2.new(1, -24, 0, 22), BackgroundColor3 = NabeUI.Theme.BackgroundColor, Text = "", PlaceholderText = placeholder or "", TextColor3 = NabeUI.Theme.TextColor, PlaceholderColor3 = NabeUI.Theme.MutedTextColor, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, BorderSizePixel = 0, Parent = holder})
			corner(box, UDim.new(0, 6))
			box.FocusLost:Connect(function(enterPressed) safeCall(callback, box.Text, enterPressed) end)
			return {Set = function(_, v) box.Text = tostring(v) end, Get = function() return box.Text end}
		end

		function tab:AddDropdown(text, items, default, callback)
			items = items or {}
			local current = default or items[1] or ""
			local expanded = false

			local holder = create("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = NabeUI.Theme.SubPanelColor, BorderSizePixel = 0, ClipsDescendants = true, Parent = tab.Page})
			corner(holder, UDim.new(0, 8))
			local btn = create("TextButton", {Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = holder})
			local label = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12,0), Size = UDim2.new(1,-40,1,0), Text = tostring(text) .. ": " .. tostring(current), TextColor3 = NabeUI.Theme.TextColor, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = holder})
			local arrow = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-26,0.5,-10), Size = UDim2.fromOffset(20,20), Text = "▾", TextColor3 = NabeUI.Theme.MutedTextColor, Font = Enum.Font.GothamBold, TextSize = 16, Parent = holder})

			local search = create("TextBox", {Visible = false, Position = UDim2.fromOffset(12,42), Size = UDim2.new(1,-24,0,24), BackgroundColor3 = NabeUI.Theme.BackgroundColor, Text = "", PlaceholderText = "Search...", TextColor3 = NabeUI.Theme.TextColor, PlaceholderColor3 = NabeUI.Theme.MutedTextColor, Font = Enum.Font.Gotham, TextSize = 13, BorderSizePixel = 0, ClearTextOnFocus = false, Parent = holder})
			corner(search, UDim.new(0,6))
			local list = create("ScrollingFrame", {Visible = false, Position = UDim2.fromOffset(12,72), Size = UDim2.new(1,-24,1,-84), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = holder})
			create("UIListLayout", {Padding = UDim.new(0, 6), Parent = list})

			local function rebuild(filter)
				for _, c in ipairs(list:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				filter = string.lower(filter or "")
				for _, item in ipairs(items) do
					local s = tostring(item)
					if filter == "" or string.find(string.lower(s), filter, 1, true) then
						local opt = create("TextButton", {Size = UDim2.new(1,0,0,28), BackgroundColor3 = NabeUI.Theme.BackgroundColor, Text = s, TextColor3 = NabeUI.Theme.TextColor, Font = Enum.Font.Gotham, TextSize = 13, BorderSizePixel = 0, AutoButtonColor = false, Parent = list})
						corner(opt, UDim.new(0,6))
						opt.Activated:Connect(function()
							current = s
							label.Text = tostring(text) .. ": " .. tostring(current)
							safeCall(callback, current)
							expanded = false
							tween(holder, TweenInfo.new(0.18 * NabeUI.Settings.AnimationSpeed), {Size = UDim2.new(1, 0, 0, 42)})
							task.delay(0.18 * NabeUI.Settings.AnimationSpeed, function()
								search.Visible = false
								list.Visible = false
							end)
							arrow.Text = "▾"
						end)
					end
				end
			end

			local function toggle()
				expanded = not expanded
				if expanded then
					search.Visible = true
					list.Visible = true
					tween(holder, TweenInfo.new(0.18 * NabeUI.Settings.AnimationSpeed), {Size = UDim2.new(1, 0, 0, 220)})
					arrow.Text = "▴"
				else
					tween(holder, TweenInfo.new(0.18 * NabeUI.Settings.AnimationSpeed), {Size = UDim2.new(1, 0, 0, 42)})
					task.delay(0.18 * NabeUI.Settings.AnimationSpeed, function()
						search.Visible = false
						list.Visible = false
					end)
					arrow.Text = "▾"
				end
			end

			search:GetPropertyChangedSignal("Text"):Connect(function()
				rebuild(search.Text)
			end)

			btn.Activated:Connect(function()
				local now = os.clock()
				if now - (self._lastFire or 0) < NabeUI.Settings.FireCooldown then return end
				self._lastFire = now
				toggle()
			end)

			rebuild("")
			safeCall(callback, current)
			return {
				Set = function(_, v) current = tostring(v); label.Text = tostring(text) .. ": " .. current end,
				Get = function() return current end,
				Refresh = function(_, newItems) items = newItems or {}; rebuild(search.Text) end
			}
		end

		function tab:AddColorPicker(text, default, callback)
			default = default or Color3.fromRGB(255,255,255)
			local current = default
			local holder = create("Frame", {Size = UDim2.new(1,0,0,76), BackgroundColor3 = NabeUI.Theme.SubPanelColor, BorderSizePixel = 0, Parent = tab.Page})
			corner(holder, UDim.new(0,8))
			create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12,6), Size = UDim2.new(1,-24,0,16), Text = tostring(text), TextColor3 = NabeUI.Theme.TextColor, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = holder})
			local preview = create("Frame", {Position = UDim2.fromOffset(12,28), Size = UDim2.fromOffset(36,36), BackgroundColor3 = current, BorderSizePixel = 0, Parent = holder})
			corner(preview, UDim.new(0,8))
			local r = create("TextBox", {Position = UDim2.fromOffset(56,28), Size = UDim2.fromOffset(50,24), BackgroundColor3 = NabeUI.Theme.BackgroundColor, Text = tostring(math.floor(current.R*255)), TextColor3 = NabeUI.Theme.TextColor, PlaceholderText = "R", BorderSizePixel = 0, Parent = holder})
			local g = create("TextBox", {Position = UDim2.fromOffset(112,28), Size = UDim2.fromOffset(50,24), BackgroundColor3 = NabeUI.Theme.BackgroundColor, Text = tostring(math.floor(current.G*255)), TextColor3 = NabeUI.Theme.TextColor, PlaceholderText = "G", BorderSizePixel = 0, Parent = holder})
			local b = create("TextBox", {Position = UDim2.fromOffset(168,28), Size = UDim2.fromOffset(50,24), BackgroundColor3 = NabeUI.Theme.BackgroundColor, Text = tostring(math.floor(current.B*255)), TextColor3 = NabeUI.Theme.TextColor, PlaceholderText = "B", BorderSizePixel = 0, Parent = holder})
			for _, box in ipairs({r,g,b}) do corner(box, UDim.new(0,6)) end
			local function apply()
				local rr = clamp(tonumber(r.Text) or 255, 0, 255)
				local gg = clamp(tonumber(g.Text) or 255, 0, 255)
				local bb = clamp(tonumber(b.Text) or 255, 0, 255)
				current = Color3.fromRGB(rr, gg, bb)
				preview.BackgroundColor3 = current
				safeCall(callback, current)
			end
			r.FocusLost:Connect(apply)
			g.FocusLost:Connect(apply)
			b.FocusLost:Connect(apply)
			apply()
			return {Set = function(_, c) current = c; preview.BackgroundColor3 = c; safeCall(callback, c) end, Get = function() return current end}
		end

		function tab:AddProgressBar(text, min, max, default)
			min, max = min or 0, max or 100
			default = default or 0
			local value = clamp(default, min, max)
			local holder = create("Frame", {Size = UDim2.new(1,0,0,50), BackgroundColor3 = NabeUI.Theme.SubPanelColor, BorderSizePixel = 0, Parent = tab.Page})
			corner(holder, UDim.new(0,8))
			create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12,6), Size = UDim2.new(1,-24,0,16), Text = tostring(text), TextColor3 = NabeUI.Theme.TextColor, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = holder})
			local bar = create("Frame", {Position = UDim2.fromOffset(12,26), Size = UDim2.new(1,-24,0,12), BackgroundColor3 = NabeUI.Theme.BackgroundColor, BorderSizePixel = 0, Parent = holder})
			corner(bar, UDim.new(1,0))
			local fill = create("Frame", {BackgroundColor3 = NabeUI.Theme.MainColor, BorderSizePixel = 0, Parent = bar})
			corner(fill, UDim.new(1,0))
			local function setValue(v)
				value = clamp(v, min, max)
				fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
			end
			setValue(value)
			return {Set = setValue, Get = function() return value end}
		end

		function tab:AddCheckbox(text, default, callback)
			return tab:AddToggle(text, default, callback)
		end

		function tab:AddNumberBox(text, default, callback, decimals)
			return tab:AddTextBox(text, tostring(default or 0), function(v)
				local n = tonumber(v)
				if n then
					safeCall(callback, decimals and roundTo(n, decimals) or n)
				end
			end)
		end

		if not self.SelectedTab then
			self.SelectedTab = tab
			tab.Page.Visible = true
			tabButton.BackgroundColor3 = NabeUI.Theme.MainColor
		end

		return tab
	end

	return self
end

return NabeUI
