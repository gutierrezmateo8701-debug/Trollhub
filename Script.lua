-- TrollUI.lua | compact mobile UI library
-- Public API: Create, AddTab, AddButton, AddTextButton, AddToggle,
-- AddSlider, AddDropdown, AddInput, Notify, Destroy

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local TrollUI = {}
TrollUI.__index = TrollUI

local Theme = {
    Background = Color3.fromRGB(17,17,21),
    Surface = Color3.fromRGB(24,24,30),
    Element = Color3.fromRGB(31,31,39),
    Hover = Color3.fromRGB(40,40,50),
    Text = Color3.fromRGB(245,245,248),
    Muted = Color3.fromRGB(155,155,165),
    Accent = Color3.fromRGB(120,85,255),
    Track = Color3.fromRGB(48,48,58)
}

local function New(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end

local function Corner(o, radius)
    New("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, o)
end

local function Stroke(o, color, thickness)
    return New("UIStroke", {
        Color = color or Theme.Accent,
        Thickness = thickness or 1
    }, o)
end

local function Tween(o, props, time)
    local TweenService = game:GetService("TweenService")
    TweenService:Create(o, TweenInfo.new(time or .12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Sound(parent, id, volume)
    local x=Instance.new("Sound")
    x.SoundId="rbxassetid://"..tostring(id)
    x.Volume=volume or .35
    x.Parent=parent
    return x
end

function TrollUI:Create(config)
    config = config or {}

    local self = setmetatable({}, TrollUI)
    self.Title = config.Title or "TrollUI"
    self.Size = config.Size or UDim2.fromOffset(330, 245)
    self.Minimized = false
    self.Destroyed = false
    self.Tabs = {}
    self.SoundIds = {
        Click = config.ClickSound or 12222216,
        Open = config.OpenSound or 12222242,
        Close = config.CloseSound or 12222242
    }

    local old = CoreGui:FindFirstChild("TrollUI")
    if old then old:Destroy() end

    self.Gui = New("ScreenGui", {
        Name = "TrollUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    if config.Sounds ~= false then
        self._OpenSound = Sound(self.Gui, self.SoundIds.Open, .25)
        self._ClickSound = Sound(self.Gui, self.SoundIds.Click, .22)
        self._CloseSound = Sound(self.Gui, self.SoundIds.Close, .22)
        self._OpenSound:Play()
    end

    self.Main = New("Frame", {
        Size = self.Size,
        Position = UDim2.new(.5, -165, .5, -122),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false
    }, self.Gui)
    Corner(self.Main, 11)
    self.Main.BackgroundTransparency = 1
    self.Border = Stroke(self.Main, Theme.Accent, 1.5)
    self.Border.Transparency = 1

    self.Header = New("Frame", {
        Size = UDim2.new(1,0,0,43),
        BackgroundTransparency = 1
    }, self.Main)

    self.TitleLabel = New("TextLabel", {
        Size = UDim2.new(1,-86,1,0),
        Position = UDim2.fromOffset(12,0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, self.Header)

    self.MinButton = New("TextButton", {
        Size = UDim2.fromOffset(30,28),
        Position = UDim2.new(1,-68,0,7),
        BackgroundColor3 = Theme.Element,
        Text = "—",
        TextColor3 = Theme.Text,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, self.Header)
    Corner(self.MinButton, 7)

    self.CloseButton = New("TextButton", {
        Size = UDim2.fromOffset(30,28),
        Position = UDim2.new(1,-34,0,7),
        BackgroundColor3 = Theme.Element,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, self.Header)
    Corner(self.CloseButton, 7)

    self.Sidebar = New("ScrollingFrame", {
        Size = UDim2.new(0,92,1,-50),
        Position = UDim2.fromOffset(6,46),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new()
    }, self.Main)
    Corner(self.Sidebar, 8)

    self.TabLayout = New("UIListLayout", {
        Padding = UDim.new(0,5),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, self.Sidebar)
    New("UIPadding", {
        PaddingTop = UDim.new(0,5),
        PaddingLeft = UDim.new(0,5),
        PaddingRight = UDim.new(0,5),
        PaddingBottom = UDim.new(0,5)
    }, self.Sidebar)

    self.Content = New("ScrollingFrame", {
        Size = UDim2.new(1,-108,1,-50),
        Position = UDim2.fromOffset(102,46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new()
    }, self.Main)

    self.ContentLayout = New("UIListLayout", {
        Padding = UDim.new(0,7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, self.Content)

    Tween(self.Main,{BackgroundTransparency=0},.22)
    Tween(self.Border,{Transparency=0},.22)
    New("UIPadding", {
        PaddingTop = UDim.new(0,2),
        PaddingLeft = UDim.new(0,2),
        PaddingRight = UDim.new(5,0),
        PaddingBottom = UDim.new(8,0)
    }, self.Content)

    self.CloseButton.MouseButton1Click:Connect(function()
        if self._CloseSound then self._CloseSound:Play() end
        self:Destroy()
    end)

    self.MinButton.MouseButton1Click:Connect(function()
        if self._ClickSound then self._ClickSound:Play() end
        self:SetMinimized(not self.Minimized)
    end)

    self:_MakeDraggable()

    if config.RGB then
        task.spawn(function()
            local hue = 0
            while self.Gui.Parent and not self.Destroyed do
                hue = (hue + .006) % 1
                self.Border.Color = Color3.fromHSV(hue, .9, 1)
                task.wait(.03)
            end
        end)
    end

    return self
end

function TrollUI:SetMinimized(value)
    self.Minimized = value
    self.MinButton.Text = value and "+" or "—"
    if value then
        self.Sidebar.Visible = false
        self.Content.Visible = false
        Tween(self.Main,{Size=UDim2.new(self.Size.X.Scale,self.Size.X.Offset,0,43)},.18)
    else
        Tween(self.Main,{Size=self.Size},.18)
        task.delay(.12,function()
            if not self.Destroyed then
                self.Sidebar.Visible = true
                self.Content.Visible = true
            end
        end)
    end
end

function TrollUI:_MakeDraggable()
    local dragging = false
    local startPos, startFrame

    self.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            startFrame = self.Main.Position
        end
    end)

    self.Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta = input.Position - startPos
        self.Main.Position = UDim2.new(
            startFrame.X.Scale, startFrame.X.Offset + delta.X,
            startFrame.Y.Scale, startFrame.Y.Offset + delta.Y
        )
    end)
end

function TrollUI:_ClearContent(tab)
    for _,child in ipairs(self.Content:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout"
        and child.Name ~= "UIPadding" then
            child.Visible = false
        end
    end
    for _,element in ipairs(tab.Elements) do
        element.Visible = true
    end
    self.Content.CanvasPosition = Vector2.zero
end

function TrollUI:AddTab(name)
    local tab = {
        Name = tostring(name or "Tab"),
        Elements = {},
        Window = self
    }

    self.Tabs[#self.Tabs + 1] = tab

    local button = New("TextButton", {
        Size = UDim2.new(1,0,0,34),
        BackgroundColor3 = Theme.Element,
        Text = tab.Name,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        LayoutOrder = #self.Tabs
    }, self.Sidebar)
    Corner(button, 7)
    tab.Button = button

    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then Tween(button,{BackgroundColor3=Theme.Hover}) end
    end)
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then Tween(button,{BackgroundColor3=Theme.Element}) end
    end)

    button.MouseButton1Click:Connect(function()
        if self._ClickSound then self._ClickSound:Play() end
        self.CurrentTab = tab
        for _,t in ipairs(self.Tabs) do
            Tween(t.Button,{BackgroundColor3 = t == tab and Theme.Accent or Theme.Element})
        end
        self:_ClearContent(tab)
    end)

    function tab:_Add(element)
        self.Elements[#self.Elements+1] = element
        return element
    end

    function tab:AddButton(data)
        data = data or {}
        local b = New("TextButton", {
            Size = UDim2.new(1,0,0,38),
            BackgroundColor3 = Theme.Element,
            Text = data.Name or "Button",
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false
        }, self.Window.Content)
        Corner(b,8)
        b.MouseButton1Click:Connect(function()
            Tween(b,{BackgroundColor3=Theme.Hover},.08)
            task.delay(.1,function() if b.Parent then Tween(b,{BackgroundColor3=Theme.Element}) end end)
            if data.Callback then data.Callback() end
        end)
        return self:_Add(b)
    end

    function tab:AddTextButton(data)
        return self:AddButton(data)
    end

    function tab:AddToggle(data)
        data = data or {}
        local state = data.Default == true

        local holder = New("Frame", {
            Size = UDim2.new(1,0,0,38),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0
        }, self.Window.Content)
        Corner(holder,8)

        New("TextLabel", {
            Size = UDim2.new(1,-55,1,0),
            Position = UDim2.fromOffset(11,0),
            BackgroundTransparency = 1,
            Text = data.Name or "Toggle",
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }, holder)

        local switch = New("TextButton", {
            Size = UDim2.fromOffset(38,20),
            Position = UDim2.new(1,-48,.5,-10),
            BackgroundColor3 = state and Theme.Accent or Theme.Track,
            Text = "",
            AutoButtonColor = false
        }, holder)
        Corner(switch,10)

        local knob = New("Frame", {
            Size = UDim2.fromOffset(16,16),
            Position = state and UDim2.new(1,-18,.5,-8) or UDim2.fromOffset(2,2),
            BackgroundColor3 = Color3.fromRGB(245,245,245),
            BorderSizePixel = 0
        }, switch)
        Corner(knob,8)

        local function update(call)
            Tween(switch,{BackgroundColor3=state and Theme.Accent or Theme.Track})
            Tween(knob,{Position=state and UDim2.new(1,-18,.5,-8) or UDim2.fromOffset(2,2)})
            if call and data.Callback then data.Callback(state) end
        end

        switch.MouseButton1Click:Connect(function()
            state = not state
            update(true)
        end)

        holder.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                state = not state
                update(true)
            end
        end)

        if data.Callback then task.defer(function() data.Callback(state) end) end
        return self:_Add(holder)
    end

    function tab:AddSlider(data)
        data = data or {}
        local min = tonumber(data.Min) or 0
        local max = tonumber(data.Max) or 100
        if max <= min then max = min + 1 end
        local value = math.clamp(tonumber(data.Default) or min,min,max)

        local holder = New("Frame", {
            Size = UDim2.new(1,0,0,56),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0
        }, self.Window.Content)
        Corner(holder,8)

        local label = New("TextLabel", {
            Size = UDim2.new(1,-18,0,22),
            Position = UDim2.fromOffset(9,3),
            BackgroundTransparency = 1,
            Text = (data.Name or "Slider")..": "..tostring(value),
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }, holder)

        local bar = New("Frame", {
            Size = UDim2.new(1,-18,0,7),
            Position = UDim2.fromOffset(9,35),
            BackgroundColor3 = Theme.Track,
            BorderSizePixel = 0
        }, holder)
        Corner(bar,5)

        local fill = New("Frame", {
            Size = UDim2.new((value-min)/(max-min),0,1,0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0
        }, bar)
        Corner(fill,5)

        local hit = New("TextButton", {
            Size = UDim2.new(1,14,1,22),
            Position = UDim2.fromOffset(-7,-11),
            BackgroundTransparency = 1,
            Text = ""
        }, bar)

        local dragging = false

        local function setValue(v, callback)
            value = math.clamp(v,min,max)
            local pct = (value-min)/(max-min)
            fill.Size = UDim2.new(pct,0,1,0)
            label.Text = (data.Name or "Slider")..": "..tostring(math.floor(value*100)/100)
            if callback and data.Callback then data.Callback(value) end
        end

        local function fromInput(input)
            local pct = math.clamp(
                (input.Position.X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),
                0,1
            )
            setValue(min+(max-min)*pct,true)
        end

        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                fromInput(input)
            end
        end)

        hit.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                fromInput(input)
            end
        end)

        return self:_Add(holder)
    end

    function tab:AddDropdown(data)
        data = data or {}
        local values = data.Values or data.Options or {}
        local selected = data.Default or values[1] or "Select"
        local opened = false
        local menu

        local button = New("TextButton", {
            Size = UDim2.new(1,0,0,38),
            BackgroundColor3 = Theme.Element,
            Text = (data.Name or "Dropdown").."  •  "..tostring(selected).."  ▼",
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false
        }, self.Window.Content)
        Corner(button,8)

        local function close()
            opened = false
            if menu then menu:Destroy();menu=nil end
        end

        local function open()
            close()
            opened = true
            menu = New("Frame", {
                Size = UDim2.new(1,0,0,math.min(#values*31,155)),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                ZIndex = 50,
                ClipsDescendants = true
            }, button)
            Corner(menu,8)

            local scroll = New("ScrollingFrame", {
                Size = UDim2.fromScale(1,1),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                CanvasSize = UDim2.new(0,0,0,#values*31),
                ZIndex = 51
            }, menu)

            for i,v in ipairs(values) do
                local opt = New("TextButton", {
                    Size = UDim2.new(1,-8,0,28),
                    Position = UDim2.fromOffset(4,(i-1)*31+2),
                    BackgroundColor3 = Theme.Element,
                    Text = tostring(v),
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    AutoButtonColor = false,
                    ZIndex = 52
                }, scroll)
                Corner(opt,6)
                opt.MouseButton1Click:Connect(function()
                    selected = v
                    button.Text = (data.Name or "Dropdown").."  •  "..tostring(selected).."  ▼"
                    close()
                    if data.Callback then data.Callback(v) end
                end)
            end
        end

        button.MouseButton1Click:Connect(function()
            if opened then close() else open() end
        end)

        return self:_Add(button)
    end

    function tab:AddColorPicker(data)
        data=data or {}
        local selected=data.Default or Color3.fromRGB(120,85,255)
        local opened=false
        local popup

        local holder=New("TextButton",{
            Size=UDim2.new(1,0,0,38),
            BackgroundColor3=Theme.Element,
            Text="",
            AutoButtonColor=false
        },self.Window.Content)
        Corner(holder,8)

        New("TextLabel",{
            Size=UDim2.new(1,-55,1,0),
            Position=UDim2.fromOffset(10,0),
            BackgroundTransparency=1,
            Text=data.Name or "Color",
            TextColor3=Theme.Text,
            TextSize=12,
            Font=Enum.Font.GothamMedium,
            TextXAlignment=Enum.TextXAlignment.Left
        },holder)

        local preview=New("Frame",{
            Size=UDim2.fromOffset(28,22),
            Position=UDim2.new(1,-38,.5,-11),
            BackgroundColor3=selected,
            BorderSizePixel=0
        },holder)
        Corner(preview,7)

        local function close()
            opened=false
            if popup then popup:Destroy();popup=nil end
        end

        local function open()
            close()
            opened=true
            popup=New("Frame",{
                Size=UDim2.fromOffset(245,205),
                Position=UDim2.new(1,-245,1,6),
                BackgroundColor3=Theme.Surface,
                BorderSizePixel=0,
                ZIndex=100
            },holder)
            Corner(popup,11)
            Stroke(popup,Theme.Accent,1)

            New("TextLabel",{
                Size=UDim2.new(1,-20,0,25),
                Position=UDim2.fromOffset(10,7),
                BackgroundTransparency=1,
                Text="Color Picker",
                TextColor3=Theme.Text,
                TextSize=13,
                Font=Enum.Font.GothamBold,
                TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=101
            },popup)

            local r=selected.R
            local g=selected.G
            local b=selected.B
            local function rgb()
                return Color3.new(r,g,b)
            end

            local preview2=New("Frame",{
                Size=UDim2.fromOffset(52,52),
                Position=UDim2.fromOffset(96,37),
                BackgroundColor3=rgb(),
                BorderSizePixel=0,
                ZIndex=101
            },popup)
            Corner(preview2,9)

            local function makeSlider(name,y,get,set)
                New("TextLabel",{
                    Size=UDim2.fromOffset(30,20),
                    Position=UDim2.fromOffset(10,y-5),
                    BackgroundTransparency=1,
                    Text=name,
                    TextColor3=Theme.Text,
                    TextSize=11,
                    Font=Enum.Font.GothamMedium,
                    ZIndex=101
                },popup)
                local bar=New("Frame",{
                    Size=UDim2.fromOffset(185,7),
                    Position=UDim2.fromOffset(43,y),
                    BackgroundColor3=Theme.Track,
                    BorderSizePixel=0,
                    ZIndex=101
                },popup);Corner(bar,5)
                local fill=New("Frame",{
                    Size=UDim2.new(get(),0,1,0),
                    BackgroundColor3=Theme.Accent,
                    BorderSizePixel=0,
                    ZIndex=102
                },bar);Corner(fill,5)
                local hit=New("TextButton",{
                    Size=UDim2.new(1,14,1,20),
                    Position=UDim2.fromOffset(-7,-10),
                    BackgroundTransparency=1,
                    Text="",
                    ZIndex=103
                },bar)
                local drag=false
                local function setByInput(input)
                    local pct=math.clamp((input.Position.X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
                    set(pct);fill.Size=UDim2.new(pct,0,1,0);preview2.BackgroundColor3=rgb()
                end
                hit.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        drag=true;setByInput(i)
                    end
                end)
                hit.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setByInput(i) end
                end)
            end

            makeSlider("R",98,function()return r end,function(v)r=v end)
            makeSlider("G",122,function()return g end,function(v)g=v end)
            makeSlider("B",146,function()return b end,function(v)b=v end)

            local cancel=New("TextButton",{
                Size=UDim2.fromOffset(100,30),
                Position=UDim2.fromOffset(10,170),
                BackgroundColor3=Theme.Element,
                Text="Cancelar",
                TextColor3=Theme.Text,
                TextSize=11,
                Font=Enum.Font.GothamMedium,
                AutoButtonColor=false,
                ZIndex=101
            },popup);Corner(cancel,7)

            local accept=New("TextButton",{
                Size=UDim2.fromOffset(100,30),
                Position=UDim2.fromOffset(135,170),
                BackgroundColor3=Theme.Accent,
                Text="Aceptar",
                TextColor3=Theme.Text,
                TextSize=11,
                Font=Enum.Font.GothamBold,
                AutoButtonColor=false,
                ZIndex=101
            },popup);Corner(accept,7)

            cancel.MouseButton1Click:Connect(function()
                close()
                if self.Window._ClickSound then self.Window._ClickSound:Play() end
            end)

            accept.MouseButton1Click:Connect(function()
                selected=rgb()
                preview.BackgroundColor3=selected
                close()
                if self.Window._ClickSound then self.Window._ClickSound:Play() end
                if data.Callback then data.Callback(selected) end
            end)
        end

        holder.MouseButton1Click:Connect(function()
            if self.Window._ClickSound then self.Window._ClickSound:Play() end
            if opened then close() else open() end
        end)

        return self:_Add(holder)
    end

    function tab:AddInput(data)
        data = data or {}

        local holder = New("Frame", {
            Size = UDim2.new(1,0,0,40),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0
        }, self.Window.Content)
        Corner(holder,8)

        local box = New("TextBox", {
            Size = UDim2.new(1,-70,1,-8),
            Position = UDim2.fromOffset(8,4),
            BackgroundTransparency = 1,
            Text = data.Default or "",
            PlaceholderText = data.Placeholder or "Escribe aquí...",
            PlaceholderColor3 = Theme.Muted,
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            MultiLine = false
        }, holder)

        local send = New("TextButton", {
            Size = UDim2.fromOffset(54,28),
            Position = UDim2.new(1,-60,.5,-14),
            BackgroundColor3 = Theme.Accent,
            Text = "OK",
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false
        }, holder)
        Corner(send,7)

        local function submit()
            if data.Callback then data.Callback(box.Text) end
        end

        send.MouseButton1Click:Connect(submit)
        box.FocusLost:Connect(function(enterPressed)
            if enterPressed then submit() end
        end)

        return self:_Add(holder)
    end

    if #self.Tabs == 1 then
        self.CurrentTab = tab
        self:_ClearContent(tab)
        button.BackgroundColor3 = Theme.Accent
    else
        for _,e in ipairs(tab.Elements) do e.Visible = false end
    end

    return tab
end

function TrollUI:Notify(data)
    data = data or {}
    local duration = tonumber(data.Duration) or 3

    local holder = New("Frame", {
        Size = UDim2.fromOffset(245,64),
        Position = UDim2.new(1,15,1,-82),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 100
    }, self.Gui)
    Corner(holder,10)
    Stroke(holder,Theme.Accent,1)

    New("TextLabel", {
        Size = UDim2.new(1,-18,0,21),
        Position = UDim2.fromOffset(9,7),
        BackgroundTransparency = 1,
        Text = data.Title or "TrollUI",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101
    }, holder)

    New("TextLabel", {
        Size = UDim2.new(1,-18,0,27),
        Position = UDim2.fromOffset(9,29),
        BackgroundTransparency = 1,
        Text = data.Text or "",
        TextColor3 = Theme.Muted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101
    }, holder)

    Tween(holder,{Position=UDim2.new(1,-260,1,-82)},.2)

    task.delay(duration,function()
        if holder.Parent then
            Tween(holder,{Position=UDim2.new(1,15,1,-82)},.2)
            task.wait(.22)
            if holder.Parent then holder:Destroy() end
        end
    end)
end

function TrollUI:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    if self.Main and self.Main.Parent then
        Tween(self.Main,{BackgroundTransparency=1},.16)
        task.delay(.17,function()
            if self.Gui then self.Gui:Destroy() end
        end)
    elseif self.Gui then
        self.Gui:Destroy()
    end
end

return TrollUI
