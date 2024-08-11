local useAlt = CreateClientConVar("sitting_use_alt",               "1.00", true, true)
local notOnMe = CreateClientConVar("sitting_disallow_on_me",       "0.00", true, true)
local forceBinds = CreateClientConVar("sitting_force_binds",       "0", true, true)
local SittingNoAltServer = CreateConVar("sitting_force_no_alt","0", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
local activeTimer = {}

local function ShouldSit(ply)
	return hook.Run("ShouldSit", ply)
end

hook.Remove("KeyPress","seats_use",function(ply,key)
	if not IsFirstTimePredicted() and not game.SinglePlayer() then return end


	if key ~= IN_USE then return end
	local good = not useAlt:GetBool()
	local alwaysSit = ShouldSit(ply)

	if forceBinds:GetBool() then
		if useAlt:GetBool() and (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)) then
			good = true
		end
	else
		if useAlt:GetBool() and ply:KeyDown(IN_WALK) then
			good = true
		end
	end

	if SittingNoAltServer:GetBool() then
		good = true
	end

	if alwaysSit == true then
		good = true
	elseif alwaysSit == false then
		good = false
	end

	if not good then return end
	local trace = LocalPlayer():GetEyeTrace()
	local ang = trace.HitNormal:Angle() + Angle(-270, 0, 0)


	if trace.Hit then
		RunConsoleCommand("sit")
	end
end)


local sitting_smooth = CreateClientConVar("sitting_smooth","1",true,false)


local lp,la=Vector(),Angle()
local lliv=false
local frac
local startt
local wasdrawing
local curpos
local function CalcView(ply, pos, angles, ...)
    local iv = ply:InVehicle()
    if lliv~=iv and sitting_smooth:GetBool() then
        lliv=iv
        
        --ignore if we were drawing local player already
        if wasdrawing then
        	wasdrawing=false
        	return
        end
        
        startt=RealTime()
        --print("CV",ply:ShouldDrawLocalPlayer())
        la.r=0
        
        local dif
        if iv then
            dif = angles-ply:EyeAngles()
        else
            dif = Angle(0,0,0)
        end
        dif.r=0
        if not iv then
        	ply:SetEyeAngles(la-dif)
        else
        	ply:SetEyeAngles(la-dif)
        	
        end
        angles = la
        
    end
    if startt then
        local f=((RealTime()-startt)*2)
        f=f>1 and 1 or f<=0 and 0 or f
       -- print(f)
        if f==1 then startt=nil end
        local res = LerpVector(math.sin(f*math.pi*0.5),lp,pos)
		local ret = GAMEMODE:CalcView(ply,res,angles,...)
        curpos = ret.origin or res or pos
		return ret
    end

    lp=pos
    la=angles
 
end

hook.Add("CalcView","sitanywhere",CalcView)


local lp,la=Vector()
local lliv=false
local frac
local startt
local ply
local curpos
local function CalcViewModelView(wep, vm, op, oa, pos,ca,...)
    
    ply=ply or LocalPlayer()
    
    local iv = ply:InVehicle()
    if lliv~=iv and sitting_smooth:GetBool() then
        lliv=iv
        wasdrawing = ply:ShouldDrawLocalPlayer()
        
        if not iv and wasdrawing then return end
        
        startt=RealTime()
    end
    if startt then
        local f=((RealTime()-startt)*2)
        f=f>1 and 1 or f<=0 and 0 or f
        if f==1 then startt=nil end
        
        local res = LerpVector(math.sin(f*math.pi*0.5),lp,pos)
		local p,a = GAMEMODE:CalcViewModelView(wep, vm, res, oa, res,ca,...)
		return p or res,a or ca
    end

    lp=pos
end

hook.Add("CalcViewModelView","sitanywhere",CalcViewModelView)


local sitting_smooth = CreateClientConVar("sitting_smooth","1",true,false)


local lp,la=Vector(),Angle()
local lliv=false
local frac
local startt
local wasdrawing
local curpos
local function CalcView(ply, pos, angles, ...)
    local iv = ply:InVehicle()
    if lliv~=iv and sitting_smooth:GetBool() then
        lliv=iv
        
        --ignore if we were drawing local player already
        if wasdrawing then
        	wasdrawing=false
        	return
        end
        
        startt=RealTime()
        --print("CV",ply:ShouldDrawLocalPlayer())
        la.r=0
        
        local dif
        if iv then
            dif = angles-ply:EyeAngles()
        else
            dif = Angle(0,0,0)
        end
        dif.r=0
        if not iv then
        	ply:SetEyeAngles(la-dif)
        else
        	ply:SetEyeAngles(la-dif)
        	
        end
        angles = la
        
    end
    if startt then
        local f=((RealTime()-startt)*2)
        f=f>1 and 1 or f<=0 and 0 or f
       -- print(f)
        if f==1 then startt=nil end
        local res = LerpVector(math.sin(f*math.pi*0.5),lp,pos)
		local ret = GAMEMODE:CalcView(ply,res,angles,...)
        curpos = ret.origin or res or pos
		return ret
    end

    lp=pos
    la=angles
 
end

hook.Add("CalcView","sitanywhere",CalcView)


local lp,la=Vector()
local lliv=false
local frac
local startt
local ply
local curpos
local function CalcViewModelView(wep, vm, op, oa, pos,ca,...)
    
    ply=ply or LocalPlayer()
    
    local iv = ply:InVehicle()
    if lliv~=iv and sitting_smooth:GetBool() then
        lliv=iv
        wasdrawing = ply:ShouldDrawLocalPlayer()
        
        if not iv and wasdrawing then return end
        
        startt=RealTime()
    end
    if startt then
        local f=((RealTime()-startt)*2)
        f=f>1 and 1 or f<=0 and 0 or f
        if f==1 then startt=nil end
        
        local res = LerpVector(math.sin(f*math.pi*0.5),lp,pos)
		local p,a = GAMEMODE:CalcViewModelView(wep, vm, res, oa, res,ca,...)
		return p or res,a or ca
    end

    lp=pos
end

hook.Add("CalcViewModelView","sitanywhere",CalcViewModelView)

