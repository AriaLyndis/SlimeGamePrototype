pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--main
function _init()
	mapstart=player.x
    run_frame = 0
    rundelay = 0
end

function _update()
	frame_count = flr(time()*30)
	player_update()
	update_torch()
	update_block()
    update_real_block()
    slimeter.update()
end

function _draw()
	cls()
	map((player.x-mapstart)/8+1,0,-(player.x%8),0,18,16)
	draw_torch()
	draw_real_block()
	--debug_log()
    draw_player()
	spr(16,-player.x+120,10,2,2) --skeleton
	--draw_roll()
    slimeter.draw()
end	

function debug_log()
    rectfill(0,0,70,60,0)
	print(coordinates,1,1,7)
	print(velocities,1,7,8)
	print("time: "..time()) --time in seconds
	print("frame: "..frame_count) --frame number
    print("free: "..tostr(player.state.free))
    print("grounded: "..tostr(player.state.grounded))
    print("boosting: "..tostr(player.state.boosting))
    print("slimeter: "..tostr(slimeter.level))
end

function collision(entity1, entity2)
    if (((entity1.right >= entity2.left) and (entity1.right <= entity2.right))or ((entity1.left <= entity2.right) and (entity1.left >= entity2.left))) and ((entity1.bottom >= entity2.top) and entity1.top <= entity2.bottom) then
        return true
    else
        return false
    end
end

function update_edges(entity)
    entity.right = entity.x + 7
    entity.left = entity.x
    entity.top = entity.y
    entity.bottom = entity.y+7
end
-->8
--player
player = {
sprite=1,
x=64,
y=64,
velX=0,
yvel=0,
x_accel=1,
x_deccel=.5,
jump_height=4,
gravity=.5,
right=0,
left=0,
top=0,
bottom=0,
flipped = false,
boost_speed = 4,
state = {free=true, grounded=false, boosting=true}
}

function player_update()
	coordinates = ("x:"..player.x.." y:"..player.y)
	velocities = ("x velocity:"..player.velX.."\ny velocity:"..player.yvel)

--boost
    if (btnp(❎) and player.state.free and slimeter.level > 0) then
        player.yvel = 0
        player.velX = 0
        player.state.boosting = true
        slimeter.level -= 1
    end
        if	(btn(❎) and player.state.boosting) then

            player.state.free = false
            player.state.boosting = true
            
        --MOVEMENT
            --left
            if (btn(⬅️) and player.velX>-player.boost_speed) then
                player.velX -= player.x_accel*3 
            end
            
            --right
            if (btn(➡️) and player.velX<player.boost_speed) then
                player.velX += player.x_accel*3 
            end
            
            --up
            if (btn(⬆️) and player.yvel>-player.boost_speed) then
                player.yvel -= player.x_accel*3
            end
            
            --down
            if (btn(⬇️) and player.yvel<player.boost_speed) then
                player.yvel += player.x_accel*3
            end
        else
            player.grounded = false
            player.state.free = true
            player.state.boosting = false
        end

--adjust velocity
    if player.state.free then
        --left
        if (btn(⬅️) and player.velX>=-1) then
            player.velX -= player.x_accel/2
        elseif (player.velX<0) then
        player.velX += player.x_deccel
        end
        
        --right
        if (btn(➡️) and player.velX<=1) then
            player.velX += player.x_accel/2

        elseif (player.velX>0) then
        player.velX -= player.x_deccel
        end
        --up
        if (btn(⬆️) and player.state.grounded) then
            player.yvel = -player.jump_height
            player.state.grounded = false
        else
            player.yvel += player.gravity
        end
        if(player.state.grounded) then 
        player.yvel=0
        end
    end
--velocity adjusts position
    if player.state.free then
        player.x += player.velX
        player.y += player.yvel
    end
--update edges
    player.right = 64+7
    player.left = 64
    player.top = player.y+2
    player.bottom = player.y+9

--update sprite
				if player.velX < 0 then
					player.flipped = true
				elseif player.velX> 0 then 
					player.flipped = false
				end
				if  not player.state.grounded and player.yvel < 0 then
    				player.sprite = 11
                elseif not player.state.grounded and player.yvel > 0 then
                    player.sprite = 12
    elseif frame_count%40<20 then
        player.sprite = 9
    elseif player.state.free then
        player.sprite = 10
    end

    if btn(🅾️) and btn(⬇️) then
    	player.sprite = 26
    elseif btn(🅾️) then
    player.sprite = 25  
    end

--turnaround
    if (btn(➡️) and player.flipped) then
        player.sprite = 26
    elseif (btn(⬅️) and not player.flipped) then
        player.sprite = 26
    end
--draw roll
    if (btn(➡️) or btn(⬅️)) then
        rundelay += 1
    else 
        rundelay = 0
    end

    if rundelay >= 4 then
        if (btn(➡️) and player.state.free and player.state.grounded) then
            run_frame += 1
            player.sprite = 41 + (run_frame / 3  % 6)
        elseif (btn(⬅️) and player.state.free and player.state.grounded) then
            run_frame += 1
            player.sprite = 41 + (run_frame / 3  % 6)
            player.flipped = true
        else
            run_frame = 0
        end
    end

    if player.state.boosting then
    	player.flipped = false
    	player.sprite = 13
    end
end

function draw_player()
 --hitbox
	--rect(64,player.y,71,player.y+7,7)
	--sprite
--boost line
    if player.state.boosting then
        line(64+4, player.y+4, ((64+4)+player.velX*3), ((player.y+4)+player.yvel*3),12)--mid to mid
        line(64+3, player.y+4, ((64+4)+player.velX*3)+1, ((player.y+4)+player.yvel*3),12) --left to right
        line(64+5, player.y+4, ((64+4)+player.velX*3)-1, ((player.y+4)+player.yvel*3),12)--right to left
        line(64+4, player.y+3, ((64+4)+player.velX*3), ((player.y+4)+player.yvel*3)+1,12)--up to down
        line(64+4, player.y+5, ((64+4)+player.velX*3), ((player.y+4)+player.yvel*3)-1,12)--down to up
        circfill((64+4)+player.velX*3, (player.y+4)+player.yvel*3,2,12)
        if frame_count%4<=2 then
        circ(64+3,player.y+3,7,7)
        end 
    end
    spr(player.sprite,64,player.y,1,1,player.flipped)
end

-->8
--torch
torch = {
x=100,
y=70,
sprite = 2,
alive = true,
unlit_timer = 0,
left=0,
right=0,
top=0,
bottom=0
}
function pickup()
	if torch.alive == true and collision(player, torch) then
    torch.alive = false
    torch.unlit_timer = 0
    player.yvel = -8
    slimeter.level = 3
 else 
 	torch.unlit_timer += 1
 end
 
 if torch.unlit_timer >= 60 then
 	torch.alive = true
 end
end

function update_torch()
    torch.x = -player.x+165
	--current sprite
    update_edges(torch)
	pickup()
 if torch.alive == true then
	 torch.sprite = 2+frame_count/3%3
 else
  torch.sprite = 5
 end
end

function draw_torch()
	--hitbox
	--rect(torch.x, torch.y, torch.x+7,torch.y+7,7)
	spr(torch.sprite,torch.x,torch.y)
end
-->8
--block
block = {
x=24,
y=96,
sprite=6,
left=0,
right=0,
top=0,
bottom=0
}

function update_block()
--update edges
    update_edges(block)
--collide
	collide()
end

function draw_block()
	spr(block.sprite,block.x,block.y)
end

function collide()
	if (player.bottom >= block.top) then
		player.y = block.top-8
        player.state.grounded = true
        slimeter.level = 3
	end
end
-->8
--actual real_block
real_block = {
x=25,
y=65,
sprite=6,
left=0,
right=0,
top=0,
bottom=0
}

function update_real_block()
--update x
real_block.x = -player.x+64
--update edges
 update_edges(real_block)
--collide
 real_collide()
end

function draw_real_block()
	spr(real_block.sprite,real_block.x,real_block.y)
end

function real_collide()

	if collision(player, real_block) then
		player.y = real_block.top - 7
        player.state.grounded = true
        slimeter.level = 3
    end
end
-->8
--roll demo

function draw_roll()
	roll_sprites = {9,41,42,43,44,45,46}
    roll_sprite = roll_sprites[frame_count%7]
    spr(roll_sprite,20,20)
end
-->8
--slimeter

slimeter = {
level = 3,
sprite = 19,
length = 3,
y=0,
update = function()
    slimeter.y = 125 - slimeter.level * 8
end,

draw = function()
    spr(slimeter.sprite,0,slimeter.y,1,slimeter.level,0,1)
    spr(20,0,101    ,1,3,0,0)
    
end
}
__gfx__
00000000000500500000a0000000a0000000a000000000000000000000800000005005000000000000000000000e00000000000000cecc001111111100000000
0000000000055000000a9000000a9000000a8a0000000000660aa0660888000000005500000e000000000000ee2eec0000cccc00ee2eecc01111111155555055
007007000055150000a98a00009989000098890000005000000aa0008888800000551500ee2eec00000e00000ec1cc100cceccc0cecccccc1111111155555055
0007700005571750009889000098890000a88900000540000aaaaaa000000000055717500eccccc0ee2eec00ccc1cc1cee2eecccc1cccc1c1111111155555055
00077000051a1a50000440000004400000044000000440000aaaaaa000000000051a1a50ccc1cc1c0eccccc0cccccccccecccccccc1cc1cc1111111155555055
007007000511115000044000000440000004400000044000000aa0000000000005111150ccc1cc1cccc1cc1cccccccccccc1cc1cc1cccc1c1111111100000000
000000000551155000054000000540000005400000054000660aa0660000000005511550ccccccccccc1cc1c0cccccc00cc1cc100cccccc01111111155055555
000000000055550000055000000550000005500000055000660aa06600000000005555000cccccc0cccccccc00cccc0000cccc0000cccc001111111155055555
00007777777700000009a000077777000777770000000000000000000000000000000000000e0000000000000000000000000000000000000000000033333333
0007766666667000000a80007ccccc707000007000000000000000000000000000000000ee2eec00000000000000000000000000000000000000000033333333
0077666666666700000770007ccccc7070000070000000000000000000000000000000000e1cc1c0000e00000000000000000000000000000000000033333333
0076666666666670000770007ccccc707000007000000000000000000000000000000000cc1cc1ccee2eecc00000000000000000000000000000000034334333
0776600066000670000770007ccccc707000007000000000000000000000000000000000cccccccccecccccc0000000000000000000000000000000044444334
076660006600067000a77a007ccccc707000007000000000000000000000000000000000cccccccccc1cc1cc0000000000000000000000000000000044544444
07666000660006700aa77aa07ccccc707000007000000000000000000000000000000000cccccccccc1cc1cc0000000000000000000000000000000044444445
077666666666667000aaaa007111117071111170000000000000000000000000000000000cccccc00cccccc00000000000000000000000000000000044445444
0076666666666700000000007ccccc70700000700000000000000000000000000000000000000000000000000000000000000000000000000000000044444444
0077666606067000000000007ccccc7070000070000000000000000000000000000000000000e000000000000000000000000000000e0000000e000045444444
0007766666667000000000007ccccc7070000070000000000000000000000000000000000ee2eec00000e0000000e000000e0000ee2ee000ee2eec0044444444
0000766666667000000000007ccccc70700000700000000000000000000000000000000000eccccc0ee2eec00ee2ee00ee2ee0000ecccc000eccccc044444544
0000776565657000000000007ccccc7070000070000000000000000000000000000000000ccc1cc10ceccccc0cecccc0ceccccc0cc1cc1c0ccc1cc1c44444444
0000077575757000000000007ccccc707000007000000000000000000000000000000000cccc1cc1cccc1cc1ccc1cc1ccc1cc1cccc1cc1ccccc1cc1c44444444
0000000000000000000000007ccccc707000007000000000000000000000000000000000cccccccccccc1cc1ccc1cc1ccc1cc1cccccccccccccccccc45444454
0000000000000000000000007111117071111170000000000000000000000000000000000cccccc00cccccccccccccccccccccc00cccccc00cccccc044444444
0000000000000000000000007ccccc70700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000007ccccc70700000700000000000000000000000000000000000000000000000000000000000000000000000000000000066666066
0000000000000000000000007ccccc70700000700000000000000000000000000000000000000000000000000000000000000000000000000000000066666066
0000000000000000000000007ccccc70700000700000000000000000000000000000000000000000000000000000000000000000000000000000000066666066
0000000000000000000000007ccccc70700000700000000000000000000000000000000000000000000000000000000000000000000000000000000066666066
0000000000000000000000007ccccc70700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000071111170711111700000000000000000000000000000000000000000000000000000000000000000000000000000000066066666
00000000000000000000000007777700077777000000000000000000000000000000000000000000000000000000000000000000000000000000000066066666
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888eeeeee888777777888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88ee88eee88778887788888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8eeee8eee87777787788888e88888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8eeee8eee8777888778888eee8888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8eeee8eee87778777788888e88888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee8eee888ee877788877888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8eeeeeeee877777777888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ddd11dd1ddd11dd1d1d1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111d11d1d1d1d1d111d1d1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ddd1ddd11d11d1d1dd11d111ddd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111d11d1d1d1d1d111d1d1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111d11dd11d1d11dd1d1d1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661166166611661616111111111111117711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11611616161616111616111117771111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11611616166116111666111111111111177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11611616161616111616111117771111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11611661161611661616111111111111117711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161611111cc11ccc1ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1616177711c11c1c1c1c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1161111111c11c1c1c1c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1616177711c11c1c1c1c117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161611111ccc1ccc1ccc171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161611111ccc1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16161777111c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661111111c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11161777111c1c1c1171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661111111c1ccc1711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1166166616661666166616661111111111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161116161616116111611611111117771111111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666166616611161116116611111111111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1116161116161161116116111111177711111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1661161116161666116116661111111111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
17711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11771111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
17711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116661166166611661616111116161666166116661666166611711171111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111611616161616111616111116161616161616161161161117111117111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111111611616166116111666111116161666161616661161166117111117111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111611616161616111616111116161611161616161161161117111117111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111111611661161611661616166611661611166616161161166611711171111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111dd1d1d1ddd1ddd1ddd1dd11ddd111111dd1ddd1ddd1ddd1ddd1ddd111111111111111111111111111111111111111111111111111111111111
1111111111111d111d1d1d1d1d1d1d111d1d11d111111d111d1d1d1d11d111d11d11111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1d111d1d1dd11dd11dd11d1d11d111111ddd1ddd1dd111d111d11dd1111111111111111111111111111111111111111111111111111111111111
1111111111111d111d1d1d1d1d1d1d111d1d11d11111111d1d111d1d11d111d11d11111111111111111111111111111111111111111111111111111111111111
11111111111111dd11dd1d1d1d1d1ddd1d1d11d111111dd11d111d1d1ddd11d11ddd111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666116616661166161611111166166616661666166616661111111111111ccc11111666166616661666166611111166116616161661166611171ccc1717
1111116116161616161116161111161116161616116111611611111117771111111c1171161116161616166616111111161116161616161611611171111c1117
11111161161616611611166611111666166616611161116116611111111111111ccc177716611661166616161661111116111616161616161161117111cc1171
11111161161616161611161611111116161116161161116116111111177711111c111171161116161616161616111111161116161616161611611171111c1711
11111161166116161166161611711661161116161666116116661111111111111ccc11111611161616161616166616661166166111661616116117111ccc1717
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116611666166616161111166611661666116616161171117111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616161111116116161616161116161711111711111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161661166616161111116116161661161116661711111711111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616661111116116161616161116161711111711111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661616161616661666116116611616116616161171117111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1ddd1ddd1ddd11dd1d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d11d111d11d1d1d1d1d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd1ddd11d111d11dd11d1d11d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d11d111d11d1d1d1d1d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111d1d1ddd11d11ddd1dd11d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111188888111
11111bbb1bbb11bb1bbb11711666116616661166161611111616111111111666116616661166161611111616111111111ccc11111ccc11111ccc117188888111
11111b1b1b111b1111b11711116116161616161116161111161611111111116116161616161116161111161611111111111c1111111c1111111c111788888111
11111bb11bb11b1111b11711116116161661161116661111116111111111116116161661161116661111166611111111111c1111111c1111111c111788888111
11111b1b1b111b1111b11711116116161616161116161111161611711111116116161616161116161111111611711111111c1171111c1171111c111788888111
11111b1b1bbb11bb11b11171116116611616116616161171161617111111116116611616116616161171166617111111111c1711111c1711111c117188888111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1bbb1171166611661666116616161111116616661666166616661666111116661166166611661616111116161111166611661666116616161111
11111b111b1b1b1b1711116116161616161116161111161116161616116111611611111111611616161616111616111116161111116116161616161116161111
11111bbb1bbb1bb11711116116161661161116661111166616661661116111611661111111611616166116111666111111611111116116161661161116661111
1111111b1b111b1b1711116116161616161116161111111616111616116111611611117111611616161616111616111116161171116116161616161116161111
11111bb11b111b1b1171116116611616116616161171166116111616166611611666171111611661161611661616117116161711116116611616116616161171
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822882828882822882888888888888888888888888888888888888888888888888888222828282888882822282288222822288866688
82888828828282888888882882828828882882888888888888888888888888888888888888888888888888888882828282888828828288288282888288888888
82888828828282288888882882228828882882228888888888888888888888888888888888888888888888888822822282228828822288288222822288822288
82888828828282888888882888828828882882828888888888888888888888888888888888888888888888888882888282828828828288288882828888888888
82228222828282228888822288828288822282228888888888888888888888888888888888888888888888888222888282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0003020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0f0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0f0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0f0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0f0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0f0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0f0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0f0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0e0f0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f3f3f063f3f063f3f063f3f063f3f060f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f3f3f3f3f3f3f3f3f3f3f3f3f3f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f3f3f3f3f3f3f3f3f3f3f3f3f0f0f0f0f0f0f0f0f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
