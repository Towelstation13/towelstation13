
/obj/item/clothing
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	/// For clothing that does not have body_parts_covered = CHEST /etc but that we would still like to be able to attach an accessory to
	var/attachment_slot_override = NONE

/obj/item/clothing/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(atom_integrity <= 0 && damage_flag == FIRE) // Our clothes don't get destroyed by fire, shut up stack trace >:(
		return

	return ..()
