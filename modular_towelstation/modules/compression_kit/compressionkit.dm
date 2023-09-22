//Whether it is on compress or expand mode
#define COMPRESSION_MODE 0
#define EXPAND_MODE 1

/obj/item/compressionkit
	name = "bluespace compression kit"
	desc = "An illegally modified BSRPED, capable of reducing the size of most items."
	icon = 'modular_towelstation/modules/compression_kit/compressionkit.dmi'
	icon_state = "compression_c"
	inhand_icon_state = "BS_RPED"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/charges = 3
	// var/damage_multiplier = 0.2 Not in use yet.
	var/mode = COMPRESSION_MODE

/obj/item/compressionkit/examine(mob/user)
	. = ..()
	. += span_notice("It has [charges] charges left. Recharge with telecrystals.")
	. += span_notice("Use in-hand to swap toggle compress mode.")

/obj/item/compressionkit/attack_self(mob/user)
	if(mode == COMPRESSION_MODE)
		mode = EXPAND_MODE
		icon_state = "compression_e"
		to_chat(user, span_notice("You switch the compressor to expand mode. This isn't implemented yet, so right now it wont do anything different!"))
		return
	if(mode == EXPAND_MODE)
		mode = COMPRESSION_MODE
		icon_state = "compression_c"
		to_chat(user, span_notice("You switch the compressor to compress mode. Usage will now reduce the size of objects."))
		return
	else
		mode = COMPRESSION_MODE
		icon_state = "compression_c"
		to_chat(user, span_notice("Some coder cocked up or an admin broke your compressor. It's been set back to compress mode.."))

/obj/item/compressionkit/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is sticking their head in [src] and turning it on! [user.p_Theyre(TRUE)] going to compress their own skull!"))
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		return SHAME
	var/turf/droploc = user.drop_location()
	var/list/organs = user.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)
	for(var/obj/item/organ/internal_organ in organs)
		internal_organ.Remove()
		internal_organ.forceMove(droploc)
	head.drop_limb()
	qdel(head)
	user.spawn_gibs()
	user.add_splatter_floor(droploc)
	playsound(user, 'sound/weapons/flash.ogg', 50, 1)
	playsound(user, 'sound/effects/splat.ogg', 50, 1)

	return OXYLOSS

/obj/item/compressionkit/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !target)
		return
	else
		if(charges == 0)
			playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 1)
			to_chat(user, span_notice("The bluespace compression kit is out of charges! Recharge it with telecrystals."))
			return
	if(istype(target, /obj/item))
		var/obj/item/O = target
		if(O.w_class == WEIGHT_CLASS_TINY)
			playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, TRUE)
			to_chat(user, span_notice("[target] cannot be compressed smaller!"))
			return
		if(istype(O.atom_storage))
			to_chat(user, span_notice("You feel like compressing an item that stores other items would be counterproductive."))
			return
		if(O.w_class > WEIGHT_CLASS_TINY)
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 50, 1)
			user.visible_message(span_warning("[user] is compressing [O] with their bluespace compression kit!"))
			if(do_after(user, 4 SECONDS, O) && charges > 0 && O.w_class > 1)
				playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 50, 1)
				do_sparks(5, TRUE, src)
				flash_lighting_fx(3, 3, LIGHT_COLOR_CYAN)
				O.w_class -= 1
				// O.force_mult -= damage_multiplier
				charges -= 1
				to_chat(user, span_notice("You successfully compress [target]! The compressor now has [charges] charges."))
		else
			to_chat(user, span_notice("Anomalous error. Summon a coder."))

/obj/item/compressionkit/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/stack/telecrystal))
		var/obj/item/stack/telecrystal/crystal = I
		charges += 1 * crystal.amount
		to_chat(user, span_notice("You insert [I] into [src]. It now has [charges] charges."))
		qdel(I)

#undef COMPRESSION_MODE
#undef EXPAND_MODE
