-- vision.wtf UI Library (Modified from testui.lua)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local ViewportSize = workspace.CurrentCamera.ViewportSize

local CFG = {
    MainColor = Color3.fromRGB(14, 14, 14),
    SecondaryColor = Color3.fromRGB(26, 26, 26),
    AccentColor = Color3.fromRGB(166, 147, 243), -- vision.wtf accent color
    TextColor = Color3.fromRGB(200, 200, 200),
    TextDark = Color3.fromRGB(120, 120, 120),
    StrokeColor = Color3.fromRGB(40, 40, 40),
    Font = Enum.Font.Code,
    BaseSize = Vector2.new(600, 450)
}

local Library = {
    Flags = {},
    Connections = {},
    Unloaded = false,
    Font = Enum.Font.Code
}

local function Create(class, props, children)
    local inst = Instance.new(class)
    for i, v in pairs(props or {}) do
        inst[i] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function Tween(obj, props, time, style, dir)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function GetTextSize(text, size, font)
    return game:GetService("TextService"):GetTextSize(text, size, font, Vector2.new(10000, 10000))
end

local ScreenGui = Create("ScreenGui", {
    Name = "VisionUI",
    Parent = game:GetService("CoreGui"),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    IgnoreGuiInset = true
})

local UIScale = Create("UIScale", {Parent = ScreenGui})

local function UpdateScale()
    local vp = workspace.CurrentCamera.ViewportSize
    local widthRatio = (vp.X - 40) / CFG.BaseSize.X
    local heightRatio = (vp.Y - 40) / CFG.BaseSize.Y
    local scale = math.min(widthRatio, heightRatio, 1)
    UIScale.Scale = math.max(scale, 0.6)
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
UpdateScale()

local NotificationContainer = Create("Frame", {
    Parent = ScreenGui,
    Position = UDim2.new(1, -20, 0, 20),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 300, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 100
})
local UIListNotif = Create("UIListLayout", {
    Parent = NotificationContainer,
    Padding = UDim.new(0, 5),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Top
})

function Library:Notification(msg, duration, color)
    local notifColor = color or CFG.AccentColor

    local Frame = Create("Frame", {
        Parent = NotificationContainer,
        Size = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = CFG.MainColor,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        Create("UIStroke", {Color = CFG.AccentColor, Thickness = 1, Transparency = 0.5}),
        Create("Frame", {
            Size = UDim2.new(0, 2, 1, 0),
            BackgroundColor3 = notifColor
        }),
        Create("TextLabel", {
            Text = msg,
            TextColor3 = CFG.TextColor,
            Font = CFG.Font,
            TextSize = 12,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    Tween(Frame, {Size = UDim2.new(0, 250, 0, 35)}, 0.5, Enum.EasingStyle.Back)
    
    task.delay(duration or 3, function()
        Tween(Frame, {Size = UDim2.new(0, 250, 0, 0), BackgroundTransparency = 1}, 0.5)
        task.wait(0.5)
        Frame:Destroy()
    end)
end

local TooltipLabel = Create("TextLabel", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 0, 0, 20),
    BackgroundColor3 = CFG.SecondaryColor,
    TextColor3 = CFG.TextColor,
    TextSize = 11,
    Font = CFG.Font,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 200
}, {
    Create("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)}),
    Create("UIStroke", {Color = CFG.StrokeColor})
})

local function AddTooltip(obj, text)
    obj.MouseEnter:Connect(function()
        TooltipLabel.Text = text
        TooltipLabel.Size = UDim2.fromOffset(GetTextSize(text, 11, CFG.Font).X + 12, 20)
        TooltipLabel.Visible = true
    end)
    obj.MouseLeave:Connect(function()
        TooltipLabel.Visible = false
    end)
end

RunService.RenderStepped:Connect(function()
    if TooltipLabel.Visible then
        local m = UserInputService:GetMouseLocation()
        TooltipLabel.Position = UDim2.fromOffset(m.X + 15, m.Y + 15)
    end
end)

local MainFrame
local Dragging, DragInput, DragStart, StartPos = false, nil, nil, nil

function Library:Window(cfg)
    MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = UDim2.fromOffset(CFG.BaseSize.X, CFG.BaseSize.Y),
        Position = UDim2.new(0.5, -300, 0.5, -225),
        BackgroundColor3 = CFG.MainColor,
        BorderSizePixel = 0
    }, {
        Create("UIStroke", {Color = CFG.StrokeColor}),
        Create("UICorner", {CornerRadius = UDim.new(0, 3)})
    })

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            Tween(MainFrame, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)

    local TopBar = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = CFG.MainColor,
        BorderSizePixel = 0
    }, {
        Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = CFG.StrokeColor
        })
    })

    local TitleLabel = Create("TextLabel", {
        Parent = TopBar,
        Text = cfg.Name or "vision.wtf",
        TextColor3 = CFG.TextDark,
        TextSize = 13,
        Font = CFG.Font,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true
    })

    local ContentContainer = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1
    })

    local Sidebar = Create("Frame", {
        Parent = ContentContainer,
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundColor3 = Color3.fromRGB(17, 17, 17),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0)
    }, {
        Create("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = CFG.StrokeColor}),
        Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top}),
        Create("UIPadding", {PaddingTop = UDim.new(0, 15)})
    })

    local PagesContainer = Create("Frame", {
        Parent = ContentContainer,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 60, 0, 0),
        BackgroundTransparency = 1
    })

    local WindowFunctions = {
        Tabs = {},
        CurrentTab = nil,
        Sidebar = Sidebar,
        PagesContainer = PagesContainer
    }

    function WindowFunctions:Page(cfg)
        local TabButton = Create("TextButton", {
            Parent = Sidebar,
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundColor3 = CFG.MainColor,
            Text = cfg.Name:sub(1,1):upper(),
            TextSize = 16,
            TextColor3 = CFG.TextDark,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 6)})
        })

        local PageFrame = Create("ScrollingFrame", {
            Parent = PagesContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CFG.AccentColor,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        PageFrame:ClearAllChildren()
        local Padding = Create("UIPadding", {Parent = PageFrame, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)})
        
        local LeftCol = Create("Frame", {Parent = PageFrame, Size = UDim2.new(0.48, 0, 1, 0), BackgroundTransparency = 1}, {
            Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
        })
        local RightCol = Create("Frame", {Parent = PageFrame, Size = UDim2.new(0.48, 0, 1, 0), Position = UDim2.new(0.52, 0, 0, 0), BackgroundTransparency = 1}, {
            Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
        })

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowFunctions.Tabs) do
                Tween(t.Btn, {TextColor3 = CFG.TextDark, BackgroundColor3 = CFG.MainColor}, 0.2)
                t.Page.Visible = false
            end
            Tween(TabButton, {TextColor3 = CFG.AccentColor, BackgroundColor3 = CFG.SecondaryColor}, 0.2)
            PageFrame.Visible = true
            WindowFunctions.CurrentTab = PageFrame
        end)

        table.insert(WindowFunctions.Tabs, {Btn = TabButton, Page = PageFrame})

        if #WindowFunctions.Tabs == 1 then
            Tween(TabButton, {TextColor3 = CFG.AccentColor, BackgroundColor3 = CFG.SecondaryColor}, 0.2)
            PageFrame.Visible = true
        end

        local PageFunctions = {
            LeftSide = true,
            LeftCol = LeftCol,
            RightCol = RightCol
        }

        function PageFunctions:Section(cfg)
            local ParentCol = PageFunctions.LeftSide and LeftCol or RightCol
            PageFunctions.LeftSide = not PageFunctions.LeftSide

            local GroupFrame = Create("Frame", {
                Parent = ParentCol,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(17, 17, 17),
                BorderSizePixel = 0
            }, {
                Create("UIStroke", {Color = CFG.StrokeColor}),
                Create("UICorner", {CornerRadius = UDim.new(0, 2)})
            })

            Create("Frame", {
                Parent = GroupFrame,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundColor3 = CFG.SecondaryColor,
                BorderSizePixel = 0
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
                Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 5),
                    Position = UDim2.new(0, 0, 1, -5),
                    BackgroundColor3 = CFG.SecondaryColor,
                    BorderSizePixel = 0
                }),
                Create("TextLabel", {
                    Text = cfg.Name,
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = CFG.TextColor,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                Create("Frame", {
                    Size = UDim2.new(0, 4, 0, 4),
                    Position = UDim2.new(1, -10, 0.5, -2),
                    BackgroundColor3 = CFG.AccentColor,
                    BorderSizePixel = 0
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            })

            local Content = Create("Frame", {
                Parent = GroupFrame,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 25),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            }, {
                Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}),
                Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
            })

            local SectionFunctions = {Content = Content}

            function SectionFunctions:Toggle(cfg)
                local Enabled = cfg.Default or false
                local Frame = Create("TextButton", {
                    Parent = Content,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = ""
                })

                local Box = Create("Frame", {
                    Parent = Frame,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 0, 0.5, -6),
                    BackgroundColor3 = CFG.SecondaryColor,
                    BorderSizePixel = 0
                }, {Create("UIStroke", {Color = CFG.StrokeColor})})

                local Check = Create("Frame", {
                    Parent = Box,
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = CFG.AccentColor,
                    BackgroundTransparency = Enabled and 0 or 1
                })

                local Label = Create("TextLabel", {
                    Parent = Frame,
                    Text = cfg.Name,
                    TextColor3 = Enabled and CFG.TextColor or CFG.TextDark,
                    TextSize = 11,
                    Font = CFG.Font,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 18, 0, 0),
                    Size = UDim2.new(1, -18, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local function Update()
                    Enabled = not Enabled
                    Library.Flags[cfg.Flag] = Enabled
                    Tween(Check, {BackgroundTransparency = Enabled and 0 or 1}, 0.1)
                    Tween(Label, {TextColor3 = Enabled and CFG.TextColor or CFG.TextDark}, 0.1)
                    if cfg.Callback then cfg.Callback(Enabled) end
                end

                Frame.MouseButton1Click:Connect(Update)
                Library.Flags[cfg.Flag] = Enabled
                
                local ToggleFunctions = {
                    Set = function(v) if v ~= Enabled then Update() end end,
                    SetVisibility = function(self, visible)
                        Frame.Visible = visible
                    end
                }
                
                function ToggleFunctions:Colorpicker(subcfg)
                    local Color = subcfg.Default or Color3.fromRGB(255, 255, 255)
                    local Opened = false
                    
                    local Preview = Create("TextButton", {
                        Parent = Frame,
                        Size = UDim2.new(0, 30, 0, 14),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        BackgroundColor3 = Color,
                        Text = "",
                        AutoButtonColor = false
                    }, {
                        Create("UIStroke", {Color = CFG.StrokeColor}),
                        Create("UICorner", {CornerRadius = UDim.new(0, 3)})
                    })

                    local PickerFrame = Create("Frame", {
                        Parent = Preview,
                        Size = UDim2.new(0, 180, 0, 0),
                        Position = UDim2.new(1, 0, 1, 5),
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundColor3 = CFG.MainColor,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        ZIndex = 60
                    }, {
                        Create("UIStroke", {Color = CFG.StrokeColor}),
                        Create("UICorner", {CornerRadius = UDim.new(0, 3)})
                    })

                    local SatValPanel = Create("TextButton", {
                        Parent = PickerFrame,
                        Size = UDim2.new(1, -20, 0, 100),
                        Position = UDim2.new(0, 10, 0, 10),
                        BackgroundColor3 = Color3.fromHSV(0, 1, 1),
                        Text = "",
                        AutoButtonColor = false
                    }, {
                        Create("ImageLabel", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://4801885019"
                        }),
                        Create("ImageLabel", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://4801885019",
                            ImageColor3 = Color3.new(0,0,0),
                            Rotation = 90
                        })
                    })

                    local Cursor = Create("Frame", {
                        Parent = SatValPanel,
                        Size = UDim2.new(0, 4, 0, 4),
                        BackgroundColor3 = Color3.new(1,1,1),
                        AnchorPoint = Vector2.new(0.5, 0.5)
                    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

                    local HueSlider = Create("TextButton", {
                        Parent = PickerFrame,
                        Size = UDim2.new(1, -20, 0, 10),
                        Position = UDim2.new(0, 10, 0, 120),
                        Text = "",
                        AutoButtonColor = false
                    }, {
                        Create("UIGradient", {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
                                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                                ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
                            })
                        }),
                        Create("UICorner", {CornerRadius = UDim.new(0, 2)})
                    })

                    local H, S, V = Color3.toHSV(Color)
                    local DraggingHSV, DraggingHue = false, false

                    local function UpdateColor()
                        Color = Color3.fromHSV(H, S, V)
                        Preview.BackgroundColor3 = Color
                        SatValPanel.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                        Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        Library.Flags[subcfg.Flag] = {Color = Color, Transparency = subcfg.Alpha or 1}
                        if subcfg.Callback then subcfg.Callback(Color) end
                    end

                    SatValPanel.InputBegan:Connect(function(inp) 
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                            DraggingHSV = true 
                        end 
                    end)
                    HueSlider.InputBegan:Connect(function(inp) 
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                            DraggingHue = true 
                        end 
                    end)
                    
                    UserInputService.InputEnded:Connect(function(inp) 
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                            DraggingHSV = false
                            DraggingHue = false 
                        end 
                    end)

                    UserInputService.InputChanged:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                            if DraggingHSV then
                                local size = SatValPanel.AbsoluteSize
                                local pos = SatValPanel.AbsolutePosition
                                local x = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
                                local y = math.clamp((inp.Position.Y - pos.Y) / size.Y, 0, 1)
                                S = x
                                V = 1 - y
                                UpdateColor()
                            elseif DraggingHue then
                                local size = HueSlider.AbsoluteSize
                                local pos = HueSlider.AbsolutePosition
                                local x = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
                                H = x
                                UpdateColor()
                            end
                        end
                    end)

                    Preview.MouseButton1Click:Connect(function()
                        Opened = not Opened
                        if Opened then
                            Tween(PickerFrame, {Size = UDim2.new(0, 180, 0, 140)}, 0.2)
                        else
                            Tween(PickerFrame, {Size = UDim2.new(0, 180, 0, 0)}, 0.2)
                        end
                    end)
                    
                    UpdateColor()
                    return self
                end
                
                return ToggleFunctions
            end

            function SectionFunctions:Slider(cfg)
                local Value = cfg.Default or cfg.Min
                local DraggingSlider = false

                local Frame = Create("Frame", {
                    Parent = Content,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1
                })

                local Label = Create("TextLabel", {
                    Parent = Frame,
                    Text = cfg.Name,
                    TextColor3 = CFG.TextDark,
                    TextSize = 11,
                    Font = CFG.Font,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Create("TextLabel", {
                    Parent = Frame,
                    Text = Value .. (cfg.Suffix or ""),
                    TextColor3 = CFG.TextDark,
                    TextSize = 11,
                    Font = CFG.Font,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBG = Create("Frame", {
                    Parent = Frame,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = CFG.SecondaryColor,
                    BorderSizePixel = 0
                }, {
                    Create("UIStroke", {Color = CFG.StrokeColor}),
                    Create("UICorner", {CornerRadius = UDim.new(1, 0)})
                })

                local Fill = Create("Frame", {
                    Parent = SliderBG,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = CFG.AccentColor
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

                local function Update(input)
                    local SizeX = SliderBG.AbsoluteSize.X
                    local PosX = SliderBG.AbsolutePosition.X
                    local InputX = input.Position.X
                    
                    local Percent = math.clamp((InputX - PosX) / SizeX, 0, 1)
                    Value = math.floor(cfg.Min + (cfg.Max - cfg.Min) * Percent)
                    
                    Fill.Size = UDim2.new(Percent, 0, 1, 0)
                    ValueLabel.Text = Value .. (cfg.Suffix or "")
                    Library.Flags[cfg.Flag] = Value
                    if cfg.Callback then cfg.Callback(Value) end
                end

                Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        DraggingSlider = true
                        Update(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if DraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        DraggingSlider = false
                    end
                end)

                local percent = (Value - cfg.Min) / (cfg.Max - cfg.Min)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                Library.Flags[cfg.Flag] = Value
            end

            function SectionFunctions:Dropdown(cfg)
                local Expanded = false
                local Current = cfg.Default or (cfg.Items and cfg.Items[1]) or ""

                local Frame = Create("Frame", {
                    Parent = Content,
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    ZIndex = 20
                })

                Create("TextLabel", {
                    Parent = Frame,
                    Text = cfg.Name,
                    TextColor3 = CFG.TextDark,
                    TextSize = 11,
                    Font = CFG.Font,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local MainBox = Create("TextButton", {
                    Parent = Frame,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 16),
                    BackgroundColor3 = CFG.SecondaryColor,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UIStroke", {Color = CFG.StrokeColor}),
                    Create("UICorner", {CornerRadius = UDim.new(0, 3)}),
                    Create("TextLabel", {
                        Name = "Val",
                        Text = Current,
                        Size = UDim2.new(1, -20, 1, 0),
                        Position = UDim2.new(0, 5, 0, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = CFG.TextColor,
                        TextSize = 11,
                        Font = CFG.Font,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    Create("TextLabel", {
                        Text = "▼",
                        Size = UDim2.new(0, 20, 1, 0),
                        Position = UDim2.new(1, -20, 0, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = CFG.TextDark,
                        TextSize = 10
                    })
                })

                local ListFrame = Create("ScrollingFrame", {
                    Parent = MainBox,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = CFG.SecondaryColor,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 50,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2
                }, {
                    Create("UIStroke", {Color = CFG.StrokeColor}),
                    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}),
                    Create("UICorner", {CornerRadius = UDim.new(0, 3)})
                })

                for _, opt in pairs(cfg.Items or {}) do
                    local Btn = Create("TextButton", {
                        Parent = ListFrame,
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = (opt == Current) and CFG.AccentColor or CFG.TextDark,
                        TextSize = 11,
                        Font = CFG.Font
                    })
                    Btn.MouseButton1Click:Connect(function()
                        Current = opt
                        MainBox.Val.Text = opt
                        Library.Flags[cfg.Flag] = opt
                        if cfg.Callback then cfg.Callback(opt) end
                        Expanded = false
                        Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.1)
                        task.wait(0.1)
                        ListFrame.Visible = false
                    end)
                end

                MainBox.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    if Expanded then
                        ListFrame.Visible = true
                        Tween(ListFrame, {Size = UDim2.new(1, 0, 0, math.min(#(cfg.Items or {}) * 20, 100))}, 0.1)
                    else
                        Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.1)
                        task.wait(0.1)
                        ListFrame.Visible = false
                    end
                end)
                Library.Flags[cfg.Flag] = Current
            end

            function SectionFunctions:Colorpicker(cfg)
                local Color = cfg.Default or Color3.fromRGB(255, 255, 255)
                local Opened = false
                
                local Frame = Create("Frame", {
                    Parent = Content,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    ZIndex = 15
                })
                
                Create("TextLabel", {
                    Parent = Frame,
                    Text = cfg.Name,
                    TextColor3 = CFG.TextDark,
                    TextSize = 11,
                    Font = CFG.Font,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Preview = Create("TextButton", {
                    Parent = Frame,
                    Size = UDim2.new(0, 30, 0, 14),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    BackgroundColor3 = Color,
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UIStroke", {Color = CFG.StrokeColor}),
                    Create("UICorner", {CornerRadius = UDim.new(0, 3)})
                })

                local PickerFrame = Create("Frame", {
                    Parent = Preview,
                    Size = UDim2.new(0, 180, 0, 0),
                    Position = UDim2.new(1, 0, 1, 5),
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = CFG.MainColor,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 60
                }, {
                    Create("UIStroke", {Color = CFG.StrokeColor}),
                    Create("UICorner", {CornerRadius = UDim.new(0, 3)})
                })

                local SatValPanel = Create("TextButton", {
                    Parent = PickerFrame,
                    Size = UDim2.new(1, -20, 0, 100),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = Color3.fromHSV(0, 1, 1),
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("ImageLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://4801885019"
                    }),
                    Create("ImageLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://4801885019",
                        ImageColor3 = Color3.new(0,0,0),
                        Rotation = 90
                    })
                })

                local Cursor = Create("Frame", {
                    Parent = SatValPanel,
                    Size = UDim2.new(0, 4, 0, 4),
                    BackgroundColor3 = Color3.new(1,1,1),
                    AnchorPoint = Vector2.new(0.5, 0.5)
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

                local HueSlider = Create("TextButton", {
                    Parent = PickerFrame,
                    Size = UDim2.new(1, -20, 0, 10),
                    Position = UDim2.new(0, 10, 0, 120),
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
                        })
                    }),
                    Create("UICorner", {CornerRadius = UDim.new(0, 2)})
                })

                local H, S, V = Color3.toHSV(Color)
                local DraggingHSV, DraggingHue = false, false

                local function UpdateColor()
                    Color = Color3.fromHSV(H, S, V)
                    Preview.BackgroundColor3 = Color
                    SatValPanel.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                    Library.Flags[cfg.Flag] = {Color = Color, Transparency = cfg.Alpha or 1}
                    if cfg.Callback then cfg.Callback(Color) end
                end

                SatValPanel.InputBegan:Connect(function(inp) 
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                        DraggingHSV = true 
                    end 
                end)
                HueSlider.InputBegan:Connect(function(inp) 
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                        DraggingHue = true 
                    end 
                end)
                
                UserInputService.InputEnded:Connect(function(inp) 
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                        DraggingHSV = false
                        DraggingHue = false 
                    end 
                end)

                UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                        if DraggingHSV then
                            local size = SatValPanel.AbsoluteSize
                            local pos = SatValPanel.AbsolutePosition
                            local x = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
                            local y = math.clamp((inp.Position.Y - pos.Y) / size.Y, 0, 1)
                            S = x
                            V = 1 - y
                            UpdateColor()
                        elseif DraggingHue then
                            local size = HueSlider.AbsoluteSize
                            local pos = HueSlider.AbsolutePosition
                            local x = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
                            H = x
                            UpdateColor()
                        end
                    end
                end)

                Preview.MouseButton1Click:Connect(function()
                    Opened = not Opened
                    if Opened then
                        Tween(PickerFrame, {Size = UDim2.new(0, 180, 0, 140)}, 0.2)
                    else
                        Tween(PickerFrame, {Size = UDim2.new(0, 180, 0, 0)}, 0.2)
                    end
                end)
                
                UpdateColor()
                
                return {
                    Colorpicker = function(self, subcfg)
                        -- Support chaining colorpicker to toggle
                        return self
                    end
                }
            end

            function SectionFunctions:Label(text)
                local LabelFrame = Create("Frame", {
                    Parent = Content,
                    Size = UDim2.new(1, 0, 0, 15),
                    BackgroundTransparency = 1
                })
                
                local Label = Create("TextLabel", {
                    Parent = LabelFrame,
                    Text = text,
                    TextColor3 = CFG.TextDark,
                    TextSize = 11,
                    Font = CFG.Font,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local LabelFunctions = {}
                
                function LabelFunctions:Colorpicker(subcfg)
                    local Color = subcfg.Default or Color3.fromRGB(255, 255, 255)
                    local Opened = false
                    
                    LabelFrame.Size = UDim2.new(1, 0, 0, 20)
                    
                    local Preview = Create("TextButton", {
                        Parent = LabelFrame,
                        Size = UDim2.new(0, 30, 0, 14),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        BackgroundColor3 = Color,
                        Text = "",
                        AutoButtonColor = false
                    }, {
                        Create("UIStroke", {Color = CFG.StrokeColor}),
                        Create("UICorner", {CornerRadius = UDim.new(0, 3)})
                    })

                    local PickerFrame = Create("Frame", {
                        Parent = Preview,
                        Size = UDim2.new(0, 180, 0, 0),
                        Position = UDim2.new(1, 0, 1, 5),
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundColor3 = CFG.MainColor,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        ZIndex = 60
                    }, {
                        Create("UIStroke", {Color = CFG.StrokeColor}),
                        Create("UICorner", {CornerRadius = UDim.new(0, 3)})
                    })

                    local SatValPanel = Create("TextButton", {
                        Parent = PickerFrame,
                        Size = UDim2.new(1, -20, 0, 100),
                        Position = UDim2.new(0, 10, 0, 10),
                        BackgroundColor3 = Color3.fromHSV(0, 1, 1),
                        Text = "",
                        AutoButtonColor = false
                    }, {
                        Create("ImageLabel", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://4801885019"
                        }),
                        Create("ImageLabel", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://4801885019",
                            ImageColor3 = Color3.new(0,0,0),
                            Rotation = 90
                        })
                    })

                    local Cursor = Create("Frame", {
                        Parent = SatValPanel,
                        Size = UDim2.new(0, 4, 0, 4),
                        BackgroundColor3 = Color3.new(1,1,1),
                        AnchorPoint = Vector2.new(0.5, 0.5)
                    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

                    local HueSlider = Create("TextButton", {
                        Parent = PickerFrame,
                        Size = UDim2.new(1, -20, 0, 10),
                        Position = UDim2.new(0, 10, 0, 120),
                        Text = "",
                        AutoButtonColor = false
                    }, {
                        Create("UIGradient", {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
                                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                                ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
                            })
                        }),
                        Create("UICorner", {CornerRadius = UDim.new(0, 2)})
                    })

                    local H, S, V = Color3.toHSV(Color)
                    local DraggingHSV, DraggingHue = false, false

                    local function UpdateColor()
                        Color = Color3.fromHSV(H, S, V)
                        Preview.BackgroundColor3 = Color
                        SatValPanel.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                        Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        Library.Flags[subcfg.Flag] = {Color = Color, Transparency = subcfg.Alpha or 1}
                        if subcfg.Callback then subcfg.Callback(Color) end
                    end

                    SatValPanel.InputBegan:Connect(function(inp) 
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                            DraggingHSV = true 
                        end 
                    end)
                    HueSlider.InputBegan:Connect(function(inp) 
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                            DraggingHue = true 
                        end 
                    end)
                    
                    UserInputService.InputEnded:Connect(function(inp) 
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then 
                            DraggingHSV = false
                            DraggingHue = false 
                        end 
                    end)

                    UserInputService.InputChanged:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                            if DraggingHSV then
                                local size = SatValPanel.AbsoluteSize
                                local pos = SatValPanel.AbsolutePosition
                                local x = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
                                local y = math.clamp((inp.Position.Y - pos.Y) / size.Y, 0, 1)
                                S = x
                                V = 1 - y
                                UpdateColor()
                            elseif DraggingHue then
                                local size = HueSlider.AbsoluteSize
                                local pos = HueSlider.AbsolutePosition
                                local x = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
                                H = x
                                UpdateColor()
                            end
                        end
                    end)

                    Preview.MouseButton1Click:Connect(function()
                        Opened = not Opened
                        if Opened then
                            Tween(PickerFrame, {Size = UDim2.new(0, 180, 0, 140)}, 0.2)
                        else
                            Tween(PickerFrame, {Size = UDim2.new(0, 180, 0, 0)}, 0.2)
                        end
                    end)
                    
                    UpdateColor()
                    return self
                end
                
                return LabelFunctions
            end

            return SectionFunctions
        end

        return PageFunctions
    end

    function WindowFunctions:KeybindList()
        return {add = function() end, remove = function() end}
    end

    function WindowFunctions:ModeratorList()
        return {add_mod = function() end, remove_mod = function() end}
    end

    function WindowFunctions:ArmorViewer()
        return {SetVisibility = function() end, ClearAllItems = function() end, SetTitle = function() end, Add = function() end}
    end

    return WindowFunctions
end

function Library:CreateSettingsPage()
    return {}
end

return Library
