-- ===============================================
-- 🛠️ Animation Changer Stable Version 🛠️BY SUSSYYYY
-- ===============================================
-- 1. Working anims : Ninja, Robot, Default, Rthro, Levitate, Mage, Stylish, Hero, Toy, Astronaut, Bubbly, Cartoony, Elder, Ghost, Knight, Vampire, Werewolf, Zombie, Bold, Adidas, Catwalk, Walmart, Wicked, NFL, Pirate, Adidas2, Oldschool, Unboxed, Aura, Wicked2, Ud, Toilet
-- NEW ANIMS: Glow motion (Gm)
getgenv().HybridSettings = {
    run = "Stylish",
    walk = "Stylish",
    jump = "Vampire",
    idle1 = "Hero",
    idle2 = "Hero",
    fall = "Vampire",
    climb = "Stylish",
    swim = "Rthro",
    swimidle = "Rhthro"
}
-- 2. Enable/Disable Mode Custom:
-- 3. (OPTIONAL) if you want to use Single Bundle instead just set that getgenv().EnableHybridCustom = true to "false"
getgenv().ChosenBundleName = "Mage" 
getgenv().EnableHybridCustom = true
print("Custom Settings defined in getgenv().")
loadstring(game:HttpGet("https://animationv3.sowonaha.workers.dev"))()
