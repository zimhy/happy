local weapon_arr = {"empty","scar","akm"}
local cur_weapon = 1
local cur_scope = 1

--- 混淆设置
local confusion_mode = false
local random_limit = 11

--- Recoil Table
-- 压枪数据表，interval代表了武器的开火间隔(官方数据)，basic中的数据为“当开过第n枪，鼠标下移多少像素”

local recoil_table = {}
----仅适合akm----

recoil_table["akm"] = {
    basic = 5 ,
    interval = 20,
    round_basic = 1.1,
-----倍镜---  1,2, 3, 4, 6--
    scope = {1,1.75,2.5,3.56},
    sing_click = 24
	
}
recoil_table["scar"] = {
    interval = 20,
    basic = 4.5 ,
    round_basic = 1.0,
    scope = {1,1.75,2.5,3.56},
    sing_click = 24	
	
}

---不下压------
recoil_table["empty"] = {
    basic =0,
    interval = 100,
    round_basic = 1.2
}
----单点下压
function single_click_recoil(_weapon,_cur_scope)
     local scop_basic = recoil_table[_weapon]["scope"][_cur_scope]	
     local single_value = recoil_table[_weapon]["sing_click"]
     single_value = scop_basic*single_value - 2
     return single_value
end
--根据武器名和已开火时间计算压枪值, _weapon:武器名， _round:已开枪次数
function recoil_value(_weapon, _round,_cur_scope)
    local step = _round%40+1

    -- 本次的下压量
    local weapon_recoil = recoil_table[_weapon]["basic"]
    local weapon_intervals = recoil_table[_weapon]["interval"]
    local weapon_round_basic = recoil_table[_weapon]["round_basic"]
    local scop_basic = recoil_table[_weapon]["scope"][_cur_scope]

    -- 武器开枪间隔

        -- 产生的是[1,random_limit]的随机数，所以减一是[0, random_limit
    -- 开枪间隔加上随机值
    
    weapon_recoil = (_round^0.3*weapon_round_basic + weapon_recoil)*scop_basic
    OutputLogMessage("round %s weapon_recoil: %s\n",_round, weapon_recoil)
    return weapon_intervals, weapon_recoil
end

-- arg代表按下了鼠标上的哪个键
function OnEvent(event, arg)
    OutputLogMessage("event = %s, arg = %s\n", event, arg)

    if ("PROFILE_ACTIVATED" == event)
    then
        OutputLogMessage("PROFILE_ACTIVATED\n")

        EnablePrimaryMouseButtonEvents(true)
    end

    if (3 == arg and "MOUSE_BUTTON_RELEASED" == event and "empty" ~= cur_weapon)
    then
        --单点下压
        local round = 1
        local cur_weapon_name = weapon_arr[cur_weapon]
        local single_click_recoil = single_click_recoil(cur_weapon_name,cur_scope)
		MoveMouseRelative(0, single_click_recoil)
		
    end
    -- 切换武器键
    if (6 == arg and "MOUSE_BUTTON_RELEASED" == event)
    then
        cur_weapon = cur_weapon + 1
        if (cur_weapon > table.getn(weapon_arr))
        then
            cur_weapon = 1
        end

        OutputLogMessage("Current Weapon: %s\n", weapon_arr[cur_weapon])
    end


    if(4 == arg and "MOUSE_BUTTON_RELEASED" == event)
    then
        cur_scope = cur_scope - 1
        if(cur_scope<1)
        then
            cur_scope = 1
        end
        OutputLogMessage("Current Scope : %s\n", cur_scope)
             
    end

    if(5 == arg and "MOUSE_BUTTON_RELEASED" == event)
    then
        cur_scope = cur_scope + 1
        if(cur_scope>5)
        then
            cur_scope = 5
        end
        OutputLogMessage("Current Scope : %s\n", cur_scope)
             
    end

    
    if (1 == arg)
    then
	    --  上侧键
        local cur_weapon_name = weapon_arr[cur_weapon]
        if ("MOUSE_BUTTON_PRESSED" == event and "empty" ~= cur_weapon_name )
        then
	    --连射下压
            local round = 1
            repeat
                --OutputLogMessage("Fire!\n")
                -- 按下左键并且释放
             
                local intervals,recovery = recoil_value(cur_weapon_name, round ,cur_scope)

                -- 回复鼠标，MoveMouseRelative(x,y)，y为正数时鼠标向下
                MoveMouseRelative(0, recovery)

                Sleep(intervals)
                round = round + 1
            until not IsMouseButtonPressed(1) 
        end
    end
end
