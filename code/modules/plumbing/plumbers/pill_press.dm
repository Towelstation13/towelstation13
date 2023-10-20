///the minimum size of a pill or patch
#define MIN_VOLUME 5
///the maximum size a pill or patch can be
#define MAX_VOLUME 50
///max amount of pills allowed on our tile before we start storing them instead
#define MAX_FLOOR_PRODUCTS 10

///We take a constant input of reagents, and produce a pill once a set volume is reached
/obj/machinery/plumbing/pill_press
	name = "chemical press"
	desc = "A press that makes pills, patches and bottles."
	icon_state = "pill_press"
	buffer = 60 //SKYRAT EDIT HYPOVIALS. This is needed so it can completely fill the vials up.
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2

	///maximum size of a pill
	var/max_pill_volume = 50
	///maximum size of a patch
	var/max_patch_volume = 40
	///maximum size of a bottle
	var/max_bottle_volume = 50
	//SKYRAT EDIT HYPOVIALS maximum size of a vial
	var/max_vial_volume = 60
	///current operating product (pills or patches)
	var/product = "pill"
	/// selected size of the product
	var/current_volume = 10
	/// prefix for the product name
	var/product_name = "factory"
	/// All packaging types wrapped up in 1 big list
	var/static/list/packaging_types = null
	///The type of packaging to use
	var/packaging_type
	///Category of packaging
	var/packaging_category
	/// list of products stored in the machine, so we dont have 610 pills on one tile
	var/list/stored_products = list()

/obj/machinery/plumbing/pill_press/Initialize(mapload, bolt, layer)
	. = ..()

	if(!packaging_types)
		var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/chemmaster)

		var/list/types = list(
			CAT_PILLS = GLOB.reagent_containers[CAT_PILLS],
			CAT_PATCHES = GLOB.reagent_containers[CAT_PATCHES],
			"Bottles" = list(/obj/item/reagent_containers/cup/bottle),
		)

		packaging_types = list()
		for(var/category in types)
			var/list/packages = types[category]

			var/list/category_item = list("cat_name" = category)
			for(var/obj/item/reagent_containers/container as anything in packages)
				var/list/package_item = list(
					"class_name" = assets.icon_class_name(sanitize_css_class_name("[container]")),
					"ref" = REF(container)
				)
				category_item["products"] += list(package_item)

			packaging_types += list(category_item)

	packaging_type = REF(GLOB.reagent_containers[CAT_PILLS][1])
	decode_category()

	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer)

/obj/machinery/plumbing/pill_press/examine(mob/user)
	. = ..()
	. += span_notice("The [name] currently has [stored_products.len] stored. There needs to be less than [MAX_FLOOR_PRODUCTS] on the floor to continue dispensing.")

/// decode product category from it's type path and returns the decoded typepath
/obj/machinery/plumbing/pill_press/proc/decode_category()
	var/obj/item/reagent_containers/container = locate(packaging_type)
	if(ispath(container, /obj/item/reagent_containers/pill/patch))
		packaging_category = CAT_PATCHES
	else if(ispath(container, /obj/item/reagent_containers/pill))
		packaging_category = CAT_PILLS
	else
		packaging_category = "Bottles"
	return container

/obj/machinery/plumbing/pill_press/process(seconds_per_tick)
	if(machine_stat & NOPOWER)
		return
	if(reagents.total_volume >= current_volume)
		if (product == "pill")
			var/obj/item/reagent_containers/pill/P = new(src)
			reagents.trans_to(P, current_volume)
			P.name = trim("[product_name] pill")
			stored_products += P
			if(pill_number == RANDOM_PILL_STYLE)
				P.icon_state = "pill[rand(1,21)]"
			else
				P.icon_state = "pill[pill_number]"
			if(P.icon_state == "pill4") //mirrored from chem masters
				P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
		else if (product == "patch")
			var/obj/item/reagent_containers/pill/patch/P = new(src)
			reagents.trans_to(P, current_volume)
			P.name = trim("[product_name] patch")
			P.icon_state = patch_style
			stored_products += P
		else if (product == "bottle")
			var/obj/item/reagent_containers/cup/bottle/P = new(src)
			reagents.trans_to(P, current_volume)
			P.name = trim("[product_name] bottle")
			stored_products += P
		//SKYRAT EDIT HYPOVIALS
		else if (product == "vial")
			var/obj/item/reagent_containers/cup/vial/small/P = new(src)
			reagents.trans_to(P, current_volume)
			P.name = trim("[product_name] vial")
			stored_products += P
		//SKYRAT EDIT HYPOVIALS END
	if(stored_products.len)
		var/pill_amount = 0
		for(var/thing in loc)
			if(!istype(thing, /obj/item/reagent_containers/cup/bottle) && !istype(thing, /obj/item/reagent_containers/pill) && !istype(thing, /obj/item/reagent_containers/cup/vial/small)) //SKYRAT EDIT  - Hypovials from chem presses
				continue
			pill_amount++
			if(pill_amount >= MAX_FLOOR_PRODUCTS) //too much so just stop
				break
		if(pill_amount < MAX_FLOOR_PRODUCTS && anchored)
			var/atom/movable/AM = stored_products[1] //AM because forceMove is all we need
			stored_products -= AM
			AM.forceMove(drop_location())

	use_power(active_power_usage * seconds_per_tick)

/obj/machinery/plumbing/pill_press/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chemmaster)
	)

/obj/machinery/plumbing/pill_press/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemPress", name)
		ui.open()

/obj/machinery/plumbing/pill_press/ui_static_data(mob/user)
	var/list/data = list()

	data["min_volume"] = MIN_VOLUME
	data["max_volume"] = MAX_VOLUME
	data["packaging_types"] = packaging_types

	return data

/obj/machinery/plumbing/pill_press/ui_data(mob/user)
	var/list/data = list()

	data["current_volume"] = current_volume
	data["product_name"] = product_name
	data["packaging_type"] = packaging_type
	data["packaging_category"] = packaging_category

	return data

/obj/machinery/plumbing/pill_press/ui_act(action, params)
	. = ..()
	if(.)
		return

	. = TRUE
	switch(action)
		if("change_current_volume")
			current_volume = round(clamp(text2num(params["volume"]), MIN_VOLUME, MAX_VOLUME))
		if("change_product_name")
			var/formatted_name = html_encode(params["name"])
			if (length(formatted_name) > MAX_NAME_LEN)
				product_name = copytext(formatted_name, 1, MAX_NAME_LEN + 1)
			else
				product_name = formatted_name
		if("change_product")
			product = params["product"]
			if (product == "pill")
				max_volume = max_pill_volume
			else if (product == "patch")
				max_volume = max_patch_volume
			else if (product == "bottle")
				max_volume = max_bottle_volume
			//SKYRAT EDIT HYPOVIALS
			else if (product == "vial")
				max_volume = max_vial_volume
			//SKYRAT EDIT HPYOVIALS END
			current_volume = clamp(current_volume, min_volume, max_volume)
		if("change_patch_style")
			patch_style = params["patch_style"]
