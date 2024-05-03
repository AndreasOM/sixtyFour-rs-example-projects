#version 410

// saved from new editor
// from loaded
// save me please
// save me again
// and once more

uniform float fTime;
uniform float speed;
uniform float scale_red_x;
uniform float scale_green_y;
uniform float scale_period_f1;
uniform float new_thing;

uniform vec3 color1_rgb;
uniform float color1_factor;
uniform vec3 color2_rgb;

uniform float zoom;
uniform float zoom_y;

uniform vec3 fx1_col0_rgb;
uniform vec3 fx1_col1_rgb;
uniform vec3 fx2_col0_rgb;
uniform vec3 fx2_col1_rgb;

/*
uniform float color1_r;
uniform float color1_g;
uniform float color1_b;
*/

precision mediump float;
out vec4 out_color;
layout(location=0)in vec2 p;

float rand(float n){
    return fract(sin(n) * 43758.5453123);
}
float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(float p){
    float fl = floor(p);
    float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}
float noise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}
float n1( float x ) {
    #define hash(v) fract(sin(100.0*v)*4375.5453)
    float f = fract(x);
    float p = floor(x);

    f = f*f*(3.0-2.0*f);

    return mix(hash(f),hash(p),f);
}


vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 f1( float a, float l )
{
	float h = 0.5*sin( a )+0.5;
	float h2 = (0.5*sin( scale_red_x*a )+0.5)+(scale_green_y/10.0)-5.0;
	l = l + h2;
	vec3 hsv=vec3( h, 0.5, l);
	vec3 rgb = hsv2rgb( hsv );

	return vec4( rgb.x, rgb.y, rgb.z, 1.0 );
}
vec4 f2( float a, float l, float r, float o )
{
	vec3 hsv=vec3( 0.15, 1.0, (1.0-l)*r + o);
	vec3 rgb = hsv2rgb( hsv );

	rgb = clamp( rgb, 0.0, 1.0);
	return vec4( rgb.x, rgb.y, rgb.z, 1.0 );
}

float mixer( vec2 p0, float t )
{
	vec2 p = p0 * ( 0.5+0.25*sin(t) );
	return abs(sin(t+mod(floor(p.x*10.0)+floor(p.y*10.0),2.0)));
	//return 1.0;
}

mat2 rot2( float a )
{
	float ca = cos(a);
	float sa = sin(a);
	return mat2(ca,-sa,
				sa,ca);
}

float fun( float f )
{
	return smoothstep(0.99, 1.0, f*1.0);
}

vec3 fx1( vec2 p, float t )
{
	vec2 pl = p*vec2( 1.0+0.25*sin( p.y+t ), 1.0+0.23*sin( p.x+t*1.04 ));
	float m = mod(floor(pl.x*10.0)+floor(pl.y*10.0),2.0);
	return mix( fx1_col0_rgb, fx1_col1_rgb, m );
}

vec3 fx2( vec2 p, float t )
{
	vec2 pl = p*vec2( 1.0+0.25*sin( p.y+t ), 1.0+0.25*sin( p.x+t*1.02 ));

	float a = atan(pl.y,pl.x);
	float l = length( pl );

	float m = 0.5*(1+sin( a*10 + 5.0*t-12.5*sin(10*l+t) ));
	return mix( fx2_col0_rgb, fx2_col1_rgb, m );
}


void main() {
    float time = speed*fTime;
	vec2 p = vec2(p.x, p.y*(9.0/16.0));
	vec2 pc = rot2( time )*p;
	float a = atan(p.y,p.x);
	float l = length( p );
//	float r = 0.5+a/(4*3.14);
	float r = 0.5*(1+sin( a*10 + 5.0*time-12.5*sin(10*l+time) ));
	float g = 0.5*(1+sin( a*11 + 5.0*time-12.5*sin(12*l+time) ));
	float mf = mixer( pc, time );
//	vec3 col1 = vec3( 0.8, 0.5, 0.8 )*r;
//	vec3 col2 = vec3( 0.2, 0.6, 0.4 )*g;
	//vec3 col1 = color1_rgb*r*color1_factor;
	vec3 col1 = fx1( p, time );
	vec3 col2 = fx2( p, time );
//	vec3 col2 = color2_rgb*g;
	// vec3 col2 = color2_rgb*(1-r*color1_factor);
	//vec3 col1 = vec3( color1_r, color1_g, color1_b )*r;

	vec3 col = mix( col1, col2, mf );
	out_color = vec4( col.r, col.g, col.b, 1.0);
	//out_color = vec4( mf, mf, mf, 1.0);
/*
	float x = p.x*zoom;
	float y = p.y*zoom*zoom_y;
	float lw = 0.01*zoom;

	float f = fun( x+y );
	float c = smoothstep(1.0-lw, 1.0+lw, 1-abs(f-y));
	c = f;
	out_color = vec4( c, c, c, 1.0 );
*/
}






