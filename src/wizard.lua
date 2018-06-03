--Wizard quest giver

mobs:register_mob("minetest_rpg:wizard", {
    type="npc",
    passive=false,
    damage=3,
    attack_type="dogfight",
    attacks_monsters=true,
    owner_loyal=true,
    pathfinding=true,
    hp_min=10,
    hp_max=20,
    armor=100,
    collisionbox={-0.35,-1.0,-0.35, 0.35,0.8,0.35},
    visual="mesh",
    mesh="character.b3d",
    drawtype="front",
    textures={{"mobs_npc2.png"},},
    child_texture={{"mobs_npc_baby.png"},},
    makes_footstep_sound=true,
    sounds={},
    walk_velocity=0,
    run_velocity=3,
    jump=true,
    drops={},
    water_damage=0,
    lava_damage=2,
    light_damage=0,
    follow={},
    view_range=15,
    owner="",
    order="follow",
    fear_height=3,
    animation={
        speed_normal=0,
        speed_run=30,
        stand_start=0,
        stand_end=79,
        walk_start=168,
        walk_end=187,
        run_start=168,
        run_end=187,
        punch_start=200,
        punch_end=219,
    },
    on_rightclick=function(self, clicker)
        local today=minetest.get_day_count()
        if self.quest~=nil and today>self.deadline then
            self.quest=nil
        end
        if self.quest==nil then
            self.questname=generatequest()
            self.quest=minetest.registered_items[self.questname]
            local deadline=1+roll(1,6)
            self.deadline=today+deadline
            self.reward=7-deadline+randomize(4)
            if self.reward<1 then
                self.reward=1
            end
        end
        local inventory=minetest.get_inventory({type="player",name=clicker:get_player_name()})
        if checkcompleted(inventory,self.questname) then
            self.quest=nil
            inventory:add_item("main", ItemStack('default:gold_ingot '..self.reward))
            minetest.show_formspec(clicker:get_player_name(), "minetest_rpg:wizardquestdone",
                    "size[10,2]"..
                    "label[0,0;Thanks! Here's your "..self.reward.." gold!]"..
                    "button_exit[0,1;2,1;exit;OK]")
            return
        end
        local timeleft=self.deadline-today
        local description=self.quest.description
        print(self.questname)
        minetest.show_formspec(clicker:get_player_name(), "minetest_rpg:wizardquest",
                "size[10,5]"..
                "label[0,0;Can you find one "..description.. " for me?]"..
                "label[0,1;I'll pay you "..self.reward.." gold.]"..
                "label[0,2;You have "..timeleft.." days remaining.]"..
                "button_exit[0,3;2,3;exit;OK]")
    end,
})

-- returns the itemstring name of the quest item
function generatequest()
    local items={}
    for name,val in pairs(minetest.registered_items) do
      table.insert(items,name)
    end
    local choice=nil
    while choice==nil or minetest.registered_items[choice].description:gsub("%s+","")=='' do
        choice=choose(items)
    end
    return choice
end

-- returns true if quest is completed (also removes item from inventory)
function checkcompleted(inventory,itemname)
    for i,stack in pairs(inventory:get_list("main")) do
        if stack:get_name()==itemname then
            inventory:remove_item('main',stack)
            return true
        end
    end
    return false
end
