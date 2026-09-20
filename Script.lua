local _0xT={};_0xT[1]="Players";_0xT[2]="TweenService";_0xT[3]="CoreGui";_0xT[4]="UserInputService"
local _Gm=game:GetService(_0xT[1]);local _Tw=game:GetService(_0xT[2]);local _Cg=game:GetService(_0xT[3]);local _Ui=game:GetService(_0xT[4])
local _L=_Gm.LocalPlayer
local _T={Background=Color3.fromRGB(18,18,22),Secondary=Color3.fromRGB(25,25,31),Element=Color3.fromRGB(32,32,40),Text=Color3.fromRGB(245,245,245),Muted=Color3.fromRGB(160,160,170),Accent=Color3.fromRGB(120,80,255)}
local _M={};_M.__index=_M

local function _n(c,p,pa)local o=Instance.new(c)for k,v in pairs(p or {})do o[k]=v end;o.Parent=pa;return o end
local function _c(o,r)_n("UICorner",{CornerRadius=UDim.new(0,r or 8)},o)end

function _M:Create(q)
 q=q or {};local s=setmetatable({},_M);s.Title=q.Title or "TrollUI";s.Size=q.Size or UDim2.fromOffset(450,320);s.Tabs={};s.Destroyed=false
 s.Gui=_n("ScreenGui",{Name="TrollUI",ResetOnSpawn=false,IgnoreGuiInset=true},_Cg)
 s.Main=_n("Frame",{Size=s.Size,Position=UDim2.new(.5,-225,.5,-160),BackgroundColor3=_T.Background,BorderSizePixel=0},s.Gui);_c(s.Main,12)
 s.Stroke=_n("UIStroke",{Thickness=1.5,Color=_T.Accent},s.Main)
 s.Header=_n("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1},s.Main)
 s.TitleLabel=_n("TextLabel",{Size=UDim2.new(1,-100,1,0),Position=UDim2.fromOffset(15,0),BackgroundTransparency=1,Text=s.Title,TextColor3=_T.Text,TextSize=17,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},s.Header)
 s.Min=_n("TextButton",{Size=UDim2.fromOffset(32,32),Position=UDim2.new(1,-78,0,9),BackgroundColor3=_T.Element,Text="—",TextColor3=_T.Text,TextSize=18,Font=Enum.Font.GothamBold},s.Header);_c(s.Min,8)
 s.Close=_n("TextButton",{Size=UDim2.fromOffset(32,32),Position=UDim2.new(1,-42,0,9),BackgroundColor3=_T.Element,Text="×",TextColor3=_T.Text,TextSize=20,Font=Enum.Font.GothamBold},s.Header);_c(s.Close,8)
 s.Close.MouseButton1Click:Connect(function()s:Destroy()end)
 s._min=false
 s.Min.MouseButton1Click:Connect(function()
  s._min=not s._min
  s.Sidebar.Visible=not s._min
  s.Content.Visible=not s._min
  s.Main.Size=s._min and UDim2.fromOffset(450,50) or s.Size
  s.Min.Text=s._min and "+" or "—"
 end)
 s.Sidebar=_n("Frame",{Size=UDim2.new(0,125,1,-50),Position=UDim2.fromOffset(0,50),BackgroundColor3=_T.Secondary,BorderSizePixel=0},s.Main)
 s.Content=_n("ScrollingFrame",{Size=UDim2.new(1,-135,1,-60),Position=UDim2.fromOffset(130,55),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new()},s.Main)
 _n("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},s.Content)
 if q.RGB then task.spawn(function()local h=0 while s.Gui.Parent and not s.Destroyed do h=(h+.005)%1;s.Stroke.Color=Color3.fromHSV(h,1,1);task.wait()end end)end
 s:_Drag();return s
end

function _M:_Drag()
 local d=false;local ds;local sp
 s=self
 s.Header.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;ds=i.Position;sp=s.Main.Position end end)
 s.Header.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)
 _Ui.InputChanged:Connect(function(i)if not d then return end;if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end;local x=i.Position-ds;s.Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+x.X,sp.Y.Scale,sp.Y.Offset+x.Y)end)
end

function _M:AddTab(nm)
 local s=self;local t={Name=nm,Elements={}}
 local b=_n("TextButton",{Size=UDim2.new(1,-10,0,38),Position=UDim2.fromOffset(5,5+(#s.Tabs*43)),BackgroundColor3=_T.Element,Text=nm,TextColor3=_T.Text,TextSize=13,Font=Enum.Font.GothamMedium},s.Sidebar);_c(b,7)
 s.Tabs[#s.Tabs+1]=t
 b.MouseButton1Click:Connect(function()s.CurrentTab=t;for _,e in ipairs(s.Content:GetChildren())do if e:IsA("GuiObject")then e.Visible=false end end;for _,e in ipairs(t.Elements)do e.Visible=true end end)
 function t:AddTextButton(q)
  return t:AddButton(q)
 end

 function t:AddButton(q)
  local x=_n("TextButton",{Size=UDim2.new(1,-10,0,42),BackgroundColor3=_T.Element,Text=q.Name or "Button",TextColor3=_T.Text,TextSize=13,Font=Enum.Font.GothamMedium},s.Content);_c(x,8);t.Elements[#t.Elements+1]=x
  x.MouseButton1Click:Connect(function()if q.Callback then q.Callback()end end);return x
 end
 function t:AddToggle(q)
  local en=q.Default or false
  local x=_n("TextButton",{Size=UDim2.new(1,-10,0,42),BackgroundColor3=_T.Element,Text=(q.Name or "Toggle")..": OFF",TextColor3=_T.Text,TextSize=13,Font=Enum.Font.GothamMedium},s.Content);_c(x,8);t.Elements[#t.Elements+1]=x
  local function u()x.Text=(q.Name or "Toggle")..": "..(en and "ON" or "OFF");if q.Callback then q.Callback(en)end end
  x.MouseButton1Click:Connect(function()en=not en;u()end);return x
 end
 function t:AddSlider(q)
  q=q or {};local mn=q.Min or 0;local mx=q.Max or 100;local val=q.Default or mn
  local x=_n("Frame",{Size=UDim2.new(1,-10,0,58),BackgroundColor3=_T.Element,BorderSizePixel=0},s.Content);_c(x,8);t.Elements[#t.Elements+1]=x
  local lab=_n("TextLabel",{Size=UDim2.new(1,-20,0,24),Position=UDim2.fromOffset(10,4),BackgroundTransparency=1,Text=(q.Name or "Slider")..": "..tostring(val),TextColor3=_T.Text,TextSize=13,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left},x)
  local bar=_n("Frame",{Size=UDim2.new(1,-20,0,8),Position=UDim2.fromOffset(10,37),BackgroundColor3=Color3.fromRGB(48,48,58),BorderSizePixel=0},x);_c(bar,4)
  local fill=_n("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BackgroundColor3=_T.Accent,BorderSizePixel=0},bar);_c(fill,4)
  local hit=_n("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""},bar)
  local function set(v)
   val=math.clamp(v,mn,mx);local pct=(val-mn)/math.max(mx-mn,1);fill.Size=UDim2.new(pct,0,1,0);lab.Text=(q.Name or "Slider")..": "..tostring(val)
   if q.Callback then q.Callback(val)end
  end
  local drag=false
  hit.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true;set(mn+(mx-mn)*math.clamp((i.Position.X-hit.AbsolutePosition.X)/hit.AbsoluteSize.X,0,1))end end)
  hit.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
  _Ui.InputChanged:Connect(function(i)if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then set(mn+(mx-mn)*math.clamp((i.Position.X-hit.AbsolutePosition.X)/hit.AbsoluteSize.X,0,1))end end)
  return x
 end

 function t:AddDropdown(q)
  q=q or {};local vals=q.Values or q.Options or {};local cur=q.Default or vals[1] or "Select"
  local x=_n("TextButton",{Size=UDim2.new(1,-10,0,42),BackgroundColor3=_T.Element,Text=(q.Name or "Dropdown")..": "..tostring(cur).." ▾",TextColor3=_T.Text,TextSize=13,Font=Enum.Font.GothamMedium},s.Content);_c(x,8);t.Elements[#t.Elements+1]=x
  local open=false;local holder
  local function close()if holder then holder:Destroy();holder=nil end;open=false end
  local function show()
   close();open=true;holder=_n("Frame",{Size=UDim2.new(1,0,0,#vals*34),Position=UDim2.new(0,0,1,4),BackgroundColor3=_T.Secondary,BorderSizePixel=0,ZIndex=20},x);_c(holder,8)
   for i,v in ipairs(vals)do
    local b=_n("TextButton",{Size=UDim2.new(1,-6,0,30),Position=UDim2.fromOffset(3,(i-1)*34+2),BackgroundColor3=_T.Element,Text=tostring(v),TextColor3=_T.Text,TextSize=12,Font=Enum.Font.Gotham,ZIndex=21},holder);_c(b,6)
    b.MouseButton1Click:Connect(function()cur=v;x.Text=(q.Name or "Dropdown")..": "..tostring(cur).." ▾";close();if q.Callback then q.Callback(v)end end)
   end
  end
  x.MouseButton1Click:Connect(function()if open then close()else show()end end)
  return x
 end

 function t:AddInput(q)
  local x=_n("TextBox",{Size=UDim2.new(1,-10,0,42),BackgroundColor3=_T.Element,PlaceholderText=q.Placeholder or "",Text="",TextColor3=_T.Text,PlaceholderColor3=_T.Muted,TextSize=13,Font=Enum.Font.Gotham,ClearTextOnFocus=false},s.Content);_c(x,8);t.Elements[#t.Elements+1]=x
  x.FocusLost:Connect(function()if q.Callback then q.Callback(x.Text)end end);return x
 end
 if #s.Tabs==1 then task.defer(function()for _,e in ipairs(s.Content:GetChildren())do if e:IsA("GuiObject")then e.Visible=false end end;for _,e in ipairs(t.Elements)do e.Visible=true end end)else for _,e in ipairs(t.Elements)do e.Visible=false end end
 return t
end

function _M:Notify(q)
 local x=_n("Frame",{Size=UDim2.fromOffset(280,70),Position=UDim2.new(1,-300,1,-90),BackgroundColor3=_T.Secondary,BorderSizePixel=0},self.Gui);_c(x,10)
 _n("TextLabel",{Size=UDim2.new(1,-20,0,25),Position=UDim2.fromOffset(10,8),BackgroundTransparency=1,Text=q.Title or "Notification",TextColor3=_T.Text,TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},x)
 _n("TextLabel",{Size=UDim2.new(1,-20,0,28),Position=UDim2.fromOffset(10,33),BackgroundTransparency=1,Text=q.Text or "",TextColor3=_T.Muted,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},x)
 task.delay(q.Duration or 3,function()if x then x:Destroy()end end)
end

function _M:Destroy()if self.Destroyed then return end;self.Destroyed=true;if self.Gui then self.Gui:Destroy()end end
return _M
