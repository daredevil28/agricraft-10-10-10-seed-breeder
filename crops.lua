local component = require("component")
local s = require("sides")
local r = require("robot")
local g = component.geolyzer
local ic = component.inventory_controller
 
UpgradeTime = false
PlacedCropStick = false

function PlaceCropStick ()
    r.select(1) -- select cropstick
    r.place(s.bottom,true) -- place the cropstick
end
 
function PlaceStick ()
    r.select(1) -- select cropstick
    r.place() -- place cropstick
end
 
function PlaceSeed ()
    r.select(6) 
    ic.equip()
    r.use()
end

function DestroySeed ()
    r.select(2)
    r.turnAround()
    r.drop()
    r.turnAround()
end

function Replant()
    r.select(1) -- select cropsticks
    r.swing() -- destroy cropstick
    DestroySeed() -- destroy weed seed
    PlaceCropStick() -- call PlaceCropstick
end

function ScanSeed ()
    r.select(1) -- select slot 1, the seed is in slot 2
    r.swing() -- destroy cropstick
    r.turnRight() -- turn to seed analyzer
    r.forward() -- move to seed analyzer
    r.select(2) -- select new seed
    r.drop() -- drop the new seed
    os.sleep(5) -- wait untill it's scanned
    r.select(6) -- select slot 5
    r.suck() -- suck that bad boi up
    UpgradePlants() -- call UpgradePlants
end

function UpgradePlants()
    r.turnLeft() -- turn to right parent cropstick
    r.select(1) -- select cropstick
    r.swing() -- destroy cropstick
    DestroySeed() -- destroy the seed
    PlaceStick() -- place a cropstick
    PlaceSeed() -- place the new seed
    UpgradeTime = true -- start the upgradetime in the while loop which runs WaitTillFullGrownThenCut()
end


function WaitTillFullGrownThenCut()
    print("checking plant if full grown")
    PlantTable = g.analyze(s.front) -- puts de table of the cropstick in front of it in a variable
    if PlantTable["growth"] == 1 then -- checks if plant is mature
        CutPlantThenUpgrade() -- cut the plant for upgrading
    else
        os.sleep(1)
    end
end
 
function CutPlantThenUpgrade()
    r.select(16) -- select clipper
    ic.equip() -- equip clipper
    r.select(13) -- select slot 13
    UseConstantly(6) -- use clipper constantly
    r.select(16) -- select slot 16
    ic.equip() -- put clipper in slot 16
    r.turnLeft() -- turn left
    r.forward() -- move to left parent crop
    r.forward()
    r.turnRight() -- turn to parent crop
    r.select(1) -- select slot 1
    r.swing() -- destroy crop
    DestroySeed() -- destroy the old parent seed
    PlaceStick() -- place cropstick
    r.select(13) -- select clippings
    ic.equip() -- equip clippings
    UseConstantly(6) -- use clippings constantly
    PlantTable = g.analyze(s.front) -- analyze plant
    if setContains(PlantTable, "agricraft") then -- is clipping succesful?
        ic.equip() -- unequip clippings
        r.turnAround() -- turn to trashcan
        r.drop() -- destroy clippings
        r.turnAround() -- turn back
        ReturnToOriginalSpot() -- return to original spot
    else
        r.turnRight() -- go back to right parent and clip some more
        r.forward()
        r.forward()
        r.turnLeft()
    end
end
 
function ReturnToOriginalSpot()
    UpgradeTime = false -- upgrading is completed
    r.turnRight() -- turn to middle
    r.forward() -- move to middle
    r.turnLeft() -- turn to cropstick
end
 
function UseConstantly(amount) -- use constantly function
    for i=amount,1,-1 do
        r.use()
    end
end
 
function CheckCropStick () -- checks the crop stick
    PlantTable = g.analyze(s.front) -- puts de table of the cropstick in front of it in a variable
    if setContains(PlantTable, "agricraft") then -- if it has agricraft as a key in the table
        if PlantTable["agricraft"]["isWeed"] then -- if it's a weed destroy it
            print("plant is weed")
            Replant()
            os.sleep(0.5)
        elseif PlantTable["agricraft"]["isWeed"] == false then -- if it's not a weed then it's a new plant
            print("plant is crop")
            ScanSeed() -- scan the new plant
            PlacedCropStick = false
        end
    elseif PlacedCropStick == false then -- if we haven't placed a new crosscrop stick yet
        print("No plant or crop")
        PlaceCropStick()
        PlacedCropStick = true
    end
end

function setContains(set, key) -- used for looking if a value exists in a table
    return set[key] ~= nilt
end
 
while true do
    if UpgradeTime == false then
        print("checking cropstick")
        CheckCropStick() -- check the cropstick
    else
        WaitTillFullGrownThenCut()
    end
    os.sleep(0.5)
end