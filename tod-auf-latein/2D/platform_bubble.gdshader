/*
	Floating Bubbles by PmkExpert
	Create floating and colliding bubbles using worley and color them with a gradient

	MIT License
*/

shader_type canvas_item;

uniform float speed = .5; //How fast the bubbles move
uniform sampler2D gradient; //The gradient texture used to color the bubbles; if it's repeated, it should start and end with the same color
uniform vec4 background_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec2 grid_vec = vec2(2.0, 2.0); //How to repeat the gradient
uniform vec2 grid_bubbles = vec2(20.0, 10.0); //How many bubbles; can also make them oval



vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			point = vec2( cos(TIME * point.x * speed), sin(TIME * point.y * speed) ) * 0.5 + 0.5;
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}
	
	return minimum_dist;
}

vec2 grid(vec2 uv, float columns, float rows){
	return fract(vec2(uv.x * columns, uv.y * rows));
}

void fragment() {
	vec2 repeat = grid(UV, grid_vec.x, grid_vec.y); //Divide in grid, used to repeat the gradient
	float worley = worley(UV, grid_bubbles.x, grid_bubbles.y); //Create bubbles
	vec4 multi_color = texture(gradient, vec2(repeat.x, worley)); //Use gradient colors; you can change to repeat.x for a horizontal repeat
	//You can change the float values here to modify the bubbles; don't ask for a mathematical explanation, I don't know
	vec3 color = mix(vec3(worley) * multi_color.rgb * 3.0, background_color.rgb , smoothstep(0.4, 0.5, worley * 1.5)); //The weight controls the bubbles' rim and size
	COLOR.rgb = color;
	COLOR.a = 0.7; //Preserve the original texture's transparency
}