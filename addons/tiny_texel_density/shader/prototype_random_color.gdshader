shader_type spatial;

group_uniforms Material_Settings;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

group_uniforms Texture_Settings;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform bool use_triplanar = true;

group_uniforms Triplanar_Settings;
uniform vec3 triplanar_scale = vec3(1.0);
uniform vec3 triplanar_offset = vec3(0.0);

group_uniforms Tint_Settings;
uniform float tint_strength : hint_range(0.0, 1.0) = 1.0;

varying vec3 world_pos;
varying vec3 world_normal;

float rand(vec3 co) {
	return fract(sin(dot(co, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec4 albedo_tex;
	
	if (use_triplanar) {
		vec3 blend = abs(world_normal);
		blend /= (blend.x + blend.y + blend.z);
		
		vec3 triplanar_pos = world_pos * triplanar_scale + triplanar_offset;
		
		vec4 tex_x = texture(texture_albedo, triplanar_pos.zy);
		vec4 tex_y = texture(texture_albedo, triplanar_pos.xz);
		vec4 tex_z = texture(texture_albedo, vec2(-triplanar_pos.x, triplanar_pos.y));
		
		albedo_tex = tex_x * blend.x + tex_y * blend.y + tex_z * blend.z;
	} else {
		albedo_tex = texture(texture_albedo, UV);
	}
	
	vec3 obj_pos = MODEL_MATRIX[3].xyz;
	vec3 random_full_color = vec3(
		rand(obj_pos + vec3(14.51, 42.12, 71.83)),
		rand(obj_pos + vec3(92.34, 11.56, 64.21)),
		rand(obj_pos + vec3(43.12, 85.67, 22.41))
	);
	
	vec3 final_albedo = mix(albedo_tex.rgb, albedo_tex.rgb * random_full_color, 1.0);
	
	ALBEDO = final_albedo;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}