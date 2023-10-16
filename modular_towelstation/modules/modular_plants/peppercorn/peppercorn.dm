// Peppercorn
/obj/item/seeds/peppercorn
	name = "pack of peppercorn seeds"
	desc = "A pack of peppercorn seeds, which grow into a peppercorn tree."
	icon = 'modular_towelstation/master_files/icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed-peppercorn"
	species = "peppercorn"
	plantname = "Peppercorn Tree"
	product = /obj/item/food/grown/peppercorn
	production = 6
	yield = 3
	potency = 15
	instability = 20
	growthstages = 4
	growing_icon = 'modular_towelstation/master_files/icons/obj/hydroponics/growing.dmi'
	icon_grow = "peppercorn-grow"
	icon_dead = "peppercorn-dead"
	icon_harvest = "peppercorn-harvest"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.12)

/obj/item/food/grown/peppercorn
	seed = /obj/item/seeds/peppercorn
	name = "peppercorn"
	desc = "While not very good on its own, it would make a great seasoning if dried and ground up."
	gender = PLURAL
	icon = 'modular_towelstation/master_files/icons/obj/hydroponics/harvest.dmi'
	icon_state = "peppercorn"
	foodtypes = FRUIT
	dry_grind = TRUE
	grind_results = list(/datum/reagent/consumable/blackpepper = 0)
	tastes = list("pepper" = 1)
