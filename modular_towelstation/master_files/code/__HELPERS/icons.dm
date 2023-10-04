/* Gives the result RGB of a RGB string after a matrix transformation. No alpha.
* Input: rr, rg, rb, gr, gg, gb, br, bg, bb, cr, cg, cb
* Output: RGB string
*/
/proc/RGBMatrixTransform(list/color, list/cm)
	ASSERT(cm.len >= 9)
	if(cm.len < 12) // fill in the rest
		for(var/i in 1 to (12 - cm.len))
			cm += 0
	if(!islist(color))
		color = ReadRGB(color)
	color[1] = color[1] * cm[1] + color[2] * cm[2] + color[3] * cm[3] + cm[10] * 255
	color[2] = color[1] * cm[4] + color[2] * cm[5] + color[3] * cm[6] + cm[11] * 255
	color[3] = color[1] * cm[7] + color[2] * cm[8] + color[3] * cm[9] + cm[12] * 255
	return rgb(color[1], color[2], color[3])
