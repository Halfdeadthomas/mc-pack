import mods.create.HeatCondition;
import mods.create.MillingManager;
import mods.create.CuttingManager;
import mods.create.PressingManager;
import mods.create.DeployerApplicationManager;
import mods.create.CrushingManager;



# Creative Gravitron
craftingTable.addShaped("creativegravitron", <item:vs_clockwork:creative_gravitron>, [
    [<item:vs_clockwork:wanderlite_matrix>, <item:minecraft:nether_star>, <item:vs_clockwork:wanderlite_matrix>],
    [<item:createdeco:netherite_sheet>, <item:vs_clockwork:gravitron>, <item:createdeco:netherite_sheet>],
    [<item:createdeco:netherite_sheet>, <item:create_sa:brass_cube>, <item:createdeco:netherite_sheet>]
]);

# Creative Filling Tank
craftingTable.addShaped("creativefillingtank", <item:create_sa:creative_filling_tank>, [
    [<item:createdeco:netherite_sheet>, <item:create_sa:large_filling_tank>, <item:createdeco:netherite_sheet>],
    [<item:vs_clockwork:wanderlite_matrix>, <item:minecraft:nether_star>, <item:vs_clockwork:wanderlite_matrix>],
    [<item:createdeco:netherite_sheet>, <item:create_sa:large_fueling_tank>, <item:createdeco:netherite_sheet>]
]);

# Concrete Colors:
craftingTable.addShaped("whiteconcrete", <item:minecraft:white_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/white>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("grayconcrete", <item:minecraft:gray_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/gray>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("brownconcrete", <item:minecraft:brown_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/brown>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("blackconcrete", <item:minecraft:black_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/black>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("yellowconcrete", <item:minecraft:yellow_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/yellow>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("orangeconcrete", <item:minecraft:orange_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/orange>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("redconcrete", <item:minecraft:red_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/red>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("magentaconcrete", <item:minecraft:magenta_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/magenta>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("purpleconcrete", <item:minecraft:purple_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/purple>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("blueconcrete", <item:minecraft:blue_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/blue>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("cyanconcrete", <item:minecraft:cyan_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/cyan>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("greenconcrete", <item:minecraft:green_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/green>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("limeconcrete", <item:minecraft:lime_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/lime>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("pinkconcrete", <item:minecraft:pink_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/pink>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

craftingTable.addShaped("lightblueconcrete", <item:minecraft:light_blue_concrete_powder> * 8, [
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <tag:items:forge:dyes/light_blue>, <item:minecraft:light_gray_concrete_powder>],
    [<item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>, <item:minecraft:light_gray_concrete_powder>]
]);

# Vanilla Concrete
craftingTable.addShapeless("lightgrayconcrete", <item:minecraft:light_gray_concrete_powder> * 8, [<item:minecraft:sand>, <item:minecraft:gravel>, <item:tfmg:concrete_mixture>, <item:minecraft:sand>, <item:minecraft:gravel>]);

# Limesand Fixing
<recipetype:create:crushing>.removeByInput(<item:create:limestone>);
<recipetype:create:crushing>.addRecipe("limesand", [<item:tfmg:limesand>], <item:create:limestone>, 200);




# Tweaked Controller Hub
craftingTable.addShaped("tweakedhub", <item:drivebywire:tweaked_controller_hub>, [
    [<item:minecraft:air>, <item:tfmg:aluminum_wire>, <item:minecraft:air>],
    [<item:create:electron_tube>, <item:create:brass_casing>, <item:create:electron_tube>],
    [<item:minecraft:air>, <item:minecraft:air>, <item:minecraft:air>]
]);


# Cable
craftingTable.addShaped("cable", <item:drivebywire:wire>, [
    [<item:minecraft:air>, <item:minecraft:air>, <item:minecraft:air>],
    [<item:tfmg:plastic_sheet>, <item:tfmg:copper_wire>, <item:tfmg:plastic_sheet>],
    [<item:minecraft:air>, <item:minecraft:air>, <item:minecraft:air>]
]);


# Cable Cutter
craftingTable.addShaped("cutter", <item:drivebywire:wire_cutter>, [
    [<item:minecraft:air>, <item:minecraft:air>, <item:minecraft:air>],
    [<item:minecraft:stick>, <item:minecraft:iron_nugget>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:stick>, <item:minecraft:air>]
]);

# Network Backup Block
craftingTable.addShaped("networkbb", <item:drivebywire:backup_block>, [
    [<item:minecraft:air>, <item:minecraft:iron_nugget>, <item:minecraft:air>],
    [<item:minecraft:iron_nugget>, <item:minecraft:black_concrete>, <item:minecraft:iron_nugget>],
    [<item:minecraft:air>, <item:minecraft:iron_nugget>, <item:minecraft:air>]
]);


# Netherrack TO Cinderflour Millstone Recipe
<recipetype:create:milling>.addRecipe("cinderflour", [<item:create:cinder_flour>], <item:minecraft:netherrack>, 200);

# Rebar Concrete
craftingTable.addShaped("rebarcrete", <item:tfmg:rebar_concrete>, [
    [<item:tfmg:concrete>, <item:tfmg:rebar>],
    [<item:minecraft:air>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:air>]
]);

# Slag Melting Conversion 1
<recipetype:create:mixing>.addRecipe("slagitem", <constant:create:heat_condition:heated>, [<fluid:tfmg:molten_slag> * 144], [<item:molten_metals:slag>], [], 200);

# Slag Melting Conversion 2
<recipetype:create:mixing>.addRecipe("slagblock", <constant:create:heat_condition:heated>, [<fluid:tfmg:molten_slag> * 1296], [<item:molten_metals:slag_block>], [], 200);

# Calcite
<recipetype:create:mixing>.addRecipe("calcite", <constant:create:heat_condition:heated>, [<item:minecraft:calcite> * 4], [<item:minecraft:diorite> * 4, <item:minecraft:bone_meal>], [<fluid:minecraft:lava> * 50], 200);

# Deepslate
<recipetype:create:mixing>.addRecipe("deepslate", <constant:create:heat_condition:heated>, [<item:minecraft:cobbled_deepslate> * 4], [<item:minecraft:basalt> * 2, <item:minecraft:blackstone> * 2], [<fluid:minecraft:lava> * 50], 200);

# Veridium
<recipetype:create:mixing>.addRecipe("veridium", <constant:create:heat_condition:heated>, [<item:create:veridium>], [<item:create:copper_nugget> * 2, <item:minecraft:dripstone_block> * 2], [<fluid:minecraft:lava> * 50], 200);

# Dripstone Block
<recipetype:create:mixing>.addRecipe("dripstone", <constant:create:heat_condition:heated>, [<item:minecraft:dripstone_block> * 8], [<item:minecraft:cobblestone> * 8, <item:minecraft:clay_ball>], [<fluid:minecraft:water> * 250], 200);

# Ochrum
<recipetype:create:mixing>.addRecipe("ochrum", <constant:create:heat_condition:heated>, [<item:create:ochrum>], [<item:minecraft:diorite> * 2, <item:minecraft:gold_nugget> * 2], [<fluid:minecraft:lava> * 50], 200);

# Limestone
<recipetype:create:mixing>.addRecipe("limestone", <constant:create:heat_condition:heated>, [<item:create:limestone> * 4], [<item:minecraft:sandstone> * 4, <item:tfmg:limesand>], [<fluid:minecraft:water> * 250], 200);

# Crimsite
<recipetype:create:mixing>.addRecipe("crimsite", <constant:create:heat_condition:heated>, [<item:create:crimsite>], [<item:minecraft:granite> * 2, <item:minecraft:iron_nugget> * 2], [<fluid:minecraft:lava> * 50], 200);

# Asurine
<recipetype:create:mixing>.addRecipe("asurine", <constant:create:heat_condition:heated>, [<item:create:asurine>], [<item:minecraft:andesite> * 2, <item:create:zinc_nugget> * 2], [<fluid:minecraft:lava> * 50], 200);

# Industrial Iron Compat
craftingTable.addShaped("ironcompat", <item:createdeco:industrial_iron_ingot>, [
    [<item:createbigcannons:cast_iron_ingot>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:air>]
]);
craftingTable.remove(<item:createbigcannons:cast_iron_nugget>);
craftingTable.addShaped("castnugget", <item:createbigcannons:cast_iron_nugget> * 9, [
    [<item:minecraft:air>, <item:createbigcannons:cast_iron_ingot>],
    [<item:minecraft:air>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:air>]
]);

# Cast Iron Conversion
craftingTable.addShaped("castconvert", <item:tfmg:cast_iron_block>, [
    [<item:createbigcannons:cast_iron_block>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:air>]
]);

craftingTable.addShaped("castconvert1", <item:createbigcannons:cast_iron_block>, [
    [<item:tfmg:cast_iron_block>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:air>],
    [<item:minecraft:air>, <item:minecraft:air>]
]);

# White Concrete
craftingTable.addShaped("whitecrete", <item:tfmg:white_concrete> * 8, [
    [<item:tfmg:concrete>, <item:tfmg:concrete>, <item:tfmg:concrete>],
    [<item:tfmg:concrete>, <item:minecraft:white_dye>, <item:tfmg:concrete>],
    [<item:tfmg:concrete>, <item:tfmg:concrete>, <item:tfmg:concrete>]
]);

# Light Gray Concrete
craftingTable.addShaped("lightgraycrete", <item:tfmg:light_gray_concrete> * 8, [
    [<item:tfmg:concrete>, <item:tfmg:concrete>, <item:tfmg:concrete>],
    [<item:tfmg:concrete>, <item:minecraft:light_gray_dye>, <item:tfmg:concrete>],
    [<item:tfmg:concrete>, <item:tfmg:concrete>, <item:tfmg:concrete>]
]);

# Gray Concrete
craftingTable.addShaped("graycrete", <item:tfmg:gray_concrete> * 8, [
    [<item:tfmg:concrete>, <item:tfmg:concrete>, <item:tfmg:concrete>],
    [<item:tfmg:concrete>, <item:minecraft:gray_dye>, <item:tfmg:concrete>],
    [<item:tfmg:concrete>, <item:tfmg:concrete>, <item:tfmg:concrete>]
]);