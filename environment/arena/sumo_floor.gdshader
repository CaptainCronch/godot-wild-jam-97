shader_type canvas_item;

//uniform int texture_length = 1428;
uniform float percentage = 1.0;

//float linear(float old_min, float old_max, float new_min, float new_max, float current) {
	//float old_range = (old_max - old_min);
	//float new_range = (new_max - new_min);
	//float new_val = (((current - old_min) * new_range) / old_range ) + new_min;
	//return new_val;
//}

void fragment() {
	//float left_limit = linear(0.0, 1.0, 0.0, float(texture_length), percentage);
	if (UV.x > (percentage / 2.0) + 0.5 || UV.x < (1.0 - percentage) / 2.0) {
		COLOR.a = 0.0;
	}
}
