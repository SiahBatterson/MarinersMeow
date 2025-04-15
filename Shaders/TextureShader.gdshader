shader_type canvas_item;

// Noise texture (ensure it's assigned in the material inspector)
uniform sampler2D noise_texture;

uniform vec2 fog_offset = vec2(0.0, 0.0);
uniform vec2 image_offset = vec2(0.0, 0.0);


// Fog density (adjust this value to control how dense the fog effect is)
uniform float density = 0.7;  // Higher density for noticeable fog

// Speed at which the fog effect moves
uniform vec2 speed = vec2(0.05, 0.02);  // Movement speed for the fog

// Speed at which the image itself moves (for tiling)
uniform vec2 image_speed = vec2(0.01, 0.01);  // Slow movement for the image

// Two background images to blend between
uniform sampler2D background_image1;
uniform sampler2D background_image2;

// Blending factor to control how much of each background image is visible
uniform float blend_factor: hint_range(0.0, 1.0) = 0.5;  // 0.0 = full image1, 1.0 = full image2

// Y threshold to control where the fog starts fading out (fades as it moves downward)
uniform float y_threshold = 0.3;  // Start fading near the bottom

// Strength of the fade-out (how fast the fog fades out over Y, original direction)
uniform float fade_strength = 1.0;  // Gradual fade effect as it moves downward

// Y cutoff for the fog itself (smooth fade-out for the fog, fading downward)
uniform float y_cutoff = 0.1;  // Y cutoff for fog fading (closer to the bottom)

// Strength of the fade-out near the fog cutoff
uniform float cutoff_fade_strength: hint_range(0.0, 1.0) = 0.1;  // Smooth fade-out strength for the fog

// Y cutoff for the image itself (smooth fade-out for the image)
uniform float image_y_cutoff = 0.1;  // Y cutoff for image fading

// Strength of the fade-out near the image cutoff
uniform float image_cutoff_fade_strength: hint_range(0.0, 1.0) = 0.1;  // Smooth fade-out strength for the image

// Overall opacity control for the fog effect
uniform float fog_opacity: hint_range(0.0, 1.0) = 1.0;  // Control the opacity of the fog

// Randomization factor for noise fluctuation
uniform float random_factor = 0.05;  // Add slight randomness to the noise

void fragment() {
    // Move the UV coordinates based on time and speed for the fog
    vec2 moving_uv = UV + fog_offset;

    // Add slight randomization to the noise UVs using sine and cosine functions
    float random_x = sin(TIME * random_factor + UV.y * 10.0) * random_factor;
    float random_y = cos(TIME * random_factor + UV.x * 10.0) * random_factor;

    // Apply the random offsets to the UVs
    moving_uv += vec2(random_x, random_y);

    // Wrap the UVs using modulo to avoid gaps between tiles
    moving_uv = mod(moving_uv, vec2(1.0, 1.0));

    // Sample the noise texture using the wrapped UVs
    vec4 noise_sample = texture(noise_texture, moving_uv);

    // Fog alpha based on the noise texture
    float fog_alpha = noise_sample.r * density;

    // Y-based fade factor: gradually fade out as the fog moves downward (original behavior)
    float fade_factor = smoothstep(y_threshold - fade_strength, y_threshold, UV.y);

    // Y-based fade-out near the fog cutoff (fades closer to the bottom)
    float cutoff_fade = smoothstep(y_cutoff, y_cutoff + cutoff_fade_strength, UV.y);

    // Move the UV coordinates based on time for the image tiling
    vec2 image_moving_uv = UV + image_offset;

    // Wrap the UVs for the image to ensure smooth tiling
    image_moving_uv = mod(image_moving_uv, vec2(1.0, 1.0));

    // Sample the two background images and blend between them
    vec4 image1_color = texture(background_image1, image_moving_uv);
    vec4 image2_color = texture(background_image2, image_moving_uv);

    // Blend the two background images based on the blend factor
    vec4 blended_image = mix(image1_color, image2_color, blend_factor);

    // Y-based fade-out for the background itself
    float image_fade = smoothstep(image_y_cutoff, image_y_cutoff + image_cutoff_fade_strength, UV.y);

    // Apply fog fade
    float final_fog_alpha = fog_alpha * fade_factor * fog_opacity * cutoff_fade;

    // Apply the final fog alpha to the blended background color, along with image fade
    COLOR = vec4(blended_image.rgb, blended_image.a * image_fade * (1.0 - final_fog_alpha));
}
