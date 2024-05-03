#version 410

uniform float fTime;
uniform float speed;
uniform float zoom0;
uniform float zoom1;
uniform vec3 offset0;
uniform vec3 offset1;
uniform float offset_mix;

uniform vec3 color0_rgb;
uniform vec3 color1_rgb;
uniform float not_gamma;

precision highp float;
//precision lowp float;


out vec4 out_color;
layout(location=0)in vec2 p;


void main() {
    float time = speed*fTime;
	vec2 p = vec2(p.x, p.y*(9.0/16.0));
//	out_color = vec4( abs(p.x), abs(p.y), 0.0, 1.0);
	float om = offset_mix;
	om = abs(sin(time*0.1));

	float zoom = mix( zoom0, zoom1, om );
	float z = 10.0/zoom;// + 0.1*sin(time);
//	z = 1.0;
	vec3 offset = mix( offset0, offset1, om);

	vec2 p0 = z*(p+offset.xy);
//	p0 = p;
	float x0 = p0.x;
	float y0 = p0.y;

//	float x0 = z*(p.x+(offset_x-500.0)*0.01);
//	float y0 = z*(p.y+(offset_y-500.0)*0.01);

	float x = 0.0;
	float y = 0.0;

	int i = 0;
	int mi = 1000;

	while( i<mi && pow(x,2) + pow(y, 2) <= 4 ) { // 4 == pow(2,2)
		float xt = pow(x,2) - pow(y, 2) + x0;
		y = 2*x*y + y0;
		x = xt;
		i = i + 1;
	}

	float c = 1.0/i;
	c = pow(c,1/not_gamma);
	c = smoothstep( 0.0, 0.5, c);
	vec3 co = mix( color0_rgb, color1_rgb, c);
//	vec3 co = mix( offset, color1_rgb, c);
	out_color = vec4( co.r, co.g, co.b, 1.0 );
}

/*
for each pixel (Px, Py) on the screen do
    x0 := scaled x coordinate of pixel (scaled to lie in the Mandelbrot X scale (-2.00, 0.47))
    y0 := scaled y coordinate of pixel (scaled to lie in the Mandelbrot Y scale (-1.12, 1.12))
    x := 0.0
    y := 0.0
    iteration := 0
    max_iteration := 1000
    while (x^2 + y^2 ≤ 2^2 AND iteration < max_iteration) do
        xtemp := x^2 - y^2 + x0
        y := 2*x*y + y0
        x := xtemp
        iteration := iteration + 1

    color := palette[iteration]
    plot(Px, Py, color)

*/

// complex number
// z = x + yi
// i^2 = -1




