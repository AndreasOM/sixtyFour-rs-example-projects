#version 410

uniform float fTime;
uniform vec2 fMouseClick;

uniform float speed;
uniform float zoom0;
uniform float zoom1;
uniform vec2 offset0;
uniform vec2 offset1;
uniform float offset_mix;

uniform vec3 color0_rgb;
uniform vec3 color1_rgb;
uniform float not_gamma;


precision highp float;
//precision lowp float;


out vec4 out_color;
layout(location=0)in vec2 p;


vec4 mandel( vec2 p, float time )
{
	// f(z) = z^2 + i
	float om = offset_mix;
	om = abs(sin(time*0.1));

	float zoom = mix( zoom0, zoom1, om );
	float z = 10.0/zoom;// + 0.1*sin(time);
	vec2 offset = mix( offset0, offset1, om);

	vec2 p0 = z*(p+offset);
	float x0 = p0.x;
	float y0 = p0.y;

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

	return vec4( co, 1.0 );
}

vec4 click_pos( vec2 p, float time )
{
	vec2 mc = vec2(fMouseClick.x, fMouseClick.y*(9.0/16.0));

	float click_distance = length( p - mc);
	vec4 click_color = vec4( 1.0 )*pow(smoothstep(0.8, 2.2, 1-click_distance), 3);
	return 10000.0*click_color;
}


vec4 corner( vec2 p, float time )
{
	// f(z) = z^2 + c
	vec2 mc = vec2(fMouseClick.x, fMouseClick.y*(9.0/16.0));

	float om = offset_mix;
	om = abs(sin(time*0.1));

	float zoom = mix( zoom0, zoom1, om );
	float z = 10.0/zoom;// + 0.1*sin(time);
	vec2 offset = mix( offset0, offset1, om);

	vec2 p0 = z*(p+offset);
//	float x0 = p0.x;
//	float y0 = p0.y;

	float x0 = p.x;
	float y0 = p.y;

	float x = x0;
	float y = y0;

	int i = 0;
	int mi = 1000;

	float cx = mc.y + 0.1*sin(time);
	float cy = mc.x + 0.1*sin(time*1.01);

	while( i<mi && pow(x,2) + pow(y, 2) <= 16 ) { // 4 == pow(2,2)
		float xt = pow(x,2) - pow(y, 2);
		y = 2*x*y + cy;
		x = xt + cx;
		i = i + 1;
	}
/*
	if ( i >= mi ) {
		return vec4( 0.0, 0.0, 0.0, 1.0 );
	} else {
//		return vec4( p.x, p.y, 0.0, 1.0 );
		return vec4( i, i, i, 1.0 );
	}
*/

	float c = 1.0/i;
	c = pow(c,1/not_gamma);
	c = smoothstep( 0.0, 0.5, c);
	vec3 co = mix( color0_rgb, color1_rgb, c)*0.75;

	return vec4( co, 1.0 );

}


void main() {
    float time = speed*fTime;
	vec2 p = vec2(p.x, p.y*(9.0/16.0));

	vec4 click_col = click_pos( p, time );

	vec4 co;
	if ( p.x > 0 && p.y > 0 )
	{
		float s = 4.0;
		p = p * s - vec2( s/2.0, s/2.0 );
		co = corner( p, time );
	}
	else
	{
		co = mandel( p, time );
	}

	out_color = co + click_col;
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




