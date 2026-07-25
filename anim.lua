-- ===============================================
-- 🛠️ Animation Changer Stable Version 🛠️BY SUSSYYYY
-- ===============================================
-- 1. Working anims : Ninja, Robot, Default, Rthro, Levitate, Mage, Stylish, Hero, Toy, Astronaut, Bubbly, Cartoony, Elder, Ghost, Knight, Vampire, Werewolf, Zombie, Bold, Adidas, Catwalk, Walmart, Wicked, NFL, Pirate, Adidas2, Oldschool, Unboxed, Aura, Wicked2, Ud, Toilet
-- NEW ANIMS: Glow motion (Gm)
getgenv().HybridSettings = {
    run = "Rthro",
    walk = "Rthro",
    jump = "Ninja",
    idle1 = "Zombie",
    idle2 = "Zombie",
    fall = "Ninja",
    climb = "Vampire",
    swim = "Zombie",
    swimidle = "Zombie"
}
-- 2. Enable/Disable Mode Custom:
-- 3. (OPTIONAL) if you want to use Single Bundle instead just set that getgenv().EnableHybridCustom = true to "false"
getgenv().ChosenBundleName = "Mage" 
getgenv().EnableHybridCustom = true
print("Custom Settings defined in getgenv().")
loadstring(game:HttpGet("https://animationv3.sowonaha.workers.dev"))()
