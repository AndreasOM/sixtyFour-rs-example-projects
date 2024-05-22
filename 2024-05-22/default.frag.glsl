#version 410

// edit ... again

uniform float new_property;

uniform float fTime;
uniform vec2 fMouseClick;
uniform vec2 fMouseHover;
    
uniform float the_layout;
uniform vec3 palette_a;
uniform vec3 palette_b;
uniform vec3 palette_c;
uniform vec3 palette_d;
uniform vec3[4] default_pal;
uniform vec3[4] sphere_pal;

uniform float speed;
uniform float zoom0;
uniform float zoom1;
uniform vec2 offset0;
uniform vec2 offset1;
uniform float offset_mix;

uniform vec3 color0_rgb;
uniform vec3 color1_rgb;
uniform float not_gamma;

uniform float dtweak;

precision highp float;
//precision lowp float;


struct Surface
{
	float d; // distance
	int m; // material
	vec2	t; // tex_coords;
};

Surface surface()
{
	return Surface(
		0.0,
		0,
		vec2(0.0, 0.0)
	);
}

out vec4 out_color;
layout(location=0)in vec2 p;

float map( float v, float s0, float e0, float s1, float e1 )
{
	float n = ( v - s0 )/( e0 - s0 );

	return n*( e1-s1 ) + s1;
}

vec3 palette( float i, vec3 a, vec3 b, vec3 c, vec3 d )
{
	return a + b*cos( 6.28318*(c*i+d) );
}
 
vec4 palette0( float i )
{
	vec3 a = vec3( 0.5, 0.5, 0.5 );
	vec3 b = vec3( 0.5, 0.5, 0.5 );
	vec3 c = vec3( 1.0, 1.0, 1.0 );
	vec3 d = vec3( 0.0, 0.33, 0.66 );
	vec3 co = palette( i, a, b, c, d );
	return vec4( co, 1.0 );
}

vec4 palette_p( float i )
{
	vec3 co = palette( i, palette_a, palette_b, palette_c, palette_d );
	return vec4( co, 1.0 );
}

vec4 palette_lookup( vec3[4] pal, float i )
{
	vec3 co = palette( i, pal[0], pal[1], pal[2], pal[3] );
	return vec4( co, 1.0 );
}

vec3 palette_p3( float i )
{
	return palette( i, palette_a, palette_b, palette_c, palette_d );
}

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

//	return vec4( co, 1.0 );
	return palette_p( c );
}

vec4 click_pos( vec2 p, float time )
{
	vec2 mc = vec2(fMouseClick.x, fMouseClick.y*(9.0/16.0));

	float click_distance = length( p - mc);
	vec4 click_color = vec4( 1.0 )*pow(smoothstep(0.8, 2.2, 1-click_distance), 3);
	return 10000.0*click_color;
}

vec4 hover_pos( vec2 p, float time )
{
	vec2 mc = vec2(fMouseHover.x, fMouseHover.y*(9.0/16.0));

	float distance = length( p - mc);
	vec4 click_color = vec4( 1.0, 1.0, 0.5, 1.0 )*pow(smoothstep(0.8, 2.2, 1-distance), 4);
	return 100000.0*click_color;
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

	while( i<mi && pow(x,2) + pow(y, 2) <= 16 ) {
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

//	float c = float(1)/i;
/*
	c = pow(c,1/not_gamma);
	c = smoothstep( 0.0, 0.5, c);
	vec3 co = mix( color0_rgb, color1_rgb, c)*0.75;
*/
//	return vec4( co, 1.0 );
//	return palette0( c );
	float c = float(1)/i;
	//float c = float(i)/float(mi);
//	c = 1/c;
	c = pow(c,1/not_gamma);
	c = smoothstep( 0.0, 0.5, c);
	return palette_lookup( default_pal, c );
//	return palette_p( c );

}

float v3max( vec3 p )
{
	return max(max( p.x, p.y ), p.z);
}

mat2 rot2( float a )
{
	float ca = cos(a);
	float sa = sin(a);
	return mat2(ca,-sa,
				sa,ca);
}


Surface scene( vec3 p )
{
	vec3 p_org = p;
	p.x += 1.5*sin( fTime );
	vec3 n = normalize(vec3( sin(fTime), 1.0, -0.3 ));
	vec3 pn = normalize(vec3( 0.0, 1.0, -0.2*0 ));
	float d = -10.001;
//	float plane_d = dot(p,pn)+d;
	float plane_d = v3max( abs(p - vec3( 0.0, -3.0, 0.0 ) ) - vec3( 2.0 ) );
	vec3 pn2 = normalize(vec3( 1.0, 0.0, 0.0 ));
//	float sphere_d = dot(p,pn2)+d;
//	p.yz = mat2( sin(fTime) )*p.yz;

	float sphere_r = 0.75;
	float sphere_d = length(p) - sphere_r;//+0.2*abs(n.x);

	float box_d = v3max( abs(p) - vec3( 0.6 ) );
//	return max( plane_d, box_d );
//	return min( sphere_d, box_d );
//	return max( box_d, -sphere_d );
	Surface s = surface();
	float box_sphere_d = max( -box_d, sphere_d );
	//float box_sphere_d = sphere_d;

	// create far back plane

	vec3 bpn = normalize(vec3( 0.0, 0.0, -1.0 ));
	float bpd = 100.00;
//	float plane_d = dot(p,pn)+d;
//	float back_plane_d = v3max( abs(p - vec3( 0.0, -3.0, 0.0 ) ) - vec3( 2.0 ) );
	float back_plane_d = dot(p_org,bpn)+bpd;


	float final_d = min( back_plane_d, min( box_sphere_d, plane_d ));
//final_d = back_plane_d;
	if( final_d == box_sphere_d )
	{
		s.d = box_sphere_d;
//	s.d = sphere_d;
		s.m = 4;
//		s.m = 3;
		s.t.x = 0.5+0.5*p.x;
		s.t.y = 0.5+0.5*p.z;

		s.t.x = 0.5+atan( p.z, p.y )/6.28;
		s.t.y = 0.5+atan( p.z, p.x )/6.28;
	}
	else if ( final_d == plane_d )
	{
		s.d = plane_d;
		s.m = 2;
		s.m = 2;
		s.t.x = 0.5+0.5*p.x;
		s.t.y = 0.5+0.5*p.z;
	}
	else if ( final_d == back_plane_d )
	{
		s.d = back_plane_d;
		s.m = 3;
		s.t.x = fract((p_org.x+110.5)*0.0046);
		s.t.y = fract((p_org.y+190)*0.008);
	}

	return s;
	//return max( -box_d, sphere_d );
	//return p.y+.1;//+0.175;
//	return length(p) - 1.0;
}

float scene_d( vec3 p )
{
	Surface s = scene( p );
	return s.d;
}



vec3 get_normal( vec3 p )
{
	vec2 eps = vec2( 0.01, 0.0);
	vec3 n = scene_d(p) - vec3(
		scene_d(p-eps.xyy),
		scene_d(p-eps.yxy),
		scene_d(p-eps.yyx)
	);
	return normalize( n );
}

float get_shadow( vec3 ro, vec3 l )
{
	vec3 rd = normalize( l - ro );

	int i;
	int mi = 100;
	float d = 1.0;

	for( i = 0; i<mi; ++i )
	{
		vec3 rp = ro + d*rd;

		Surface ts = scene( rp );		
		float delta = ts.d;
		// float delta = scene_d( rp );

		if ( delta < 0.001 )
		{
			return 0.0;
			break;
		}
		if ( d > 100000.0 ) {
			break;
		}
		d = d + delta;
		
	}

	return 1.0;
}


vec4 layout0( void )
{
	vec2 p_org = p;
    float time = speed*fTime;
	vec2 p = vec2(p.x, p.y*(9.0/16.0));

	// p = p * vec2( 2.5, 2.5 );

	vec3 light1_pos = vec3( 1.0, 10.0, -3.0 );
	vec3 light1 = normalize(light1_pos);
	vec3 ro = vec3( 0.0, 0.0, -3.0 );
	vec3 rd = normalize(vec3( p.x, p.y, 1.0 ));

	int i = 0;
	int mi = 100;

	float d = 0.0;

	float c = 0.5;
	Surface s = surface();

	vec3 rp;
	for( i = 0; i<mi; ++i )
	{
		rp = ro + d*rd;

		Surface ts = scene( rp );		
		float delta = ts.d;
		// float delta = scene_d( rp );

		if ( abs(delta) < 0.001 )
		{
			//c = 1.0;
			s = ts;
			break;
		}
		if ( d > 100000.0 ) {
			//c = 0.0;
			break;
		}
		d = d + delta;
		
	}

	
//	float c = 1./float(d);
//	float c = d;
//	c = smoothstep( 0.0, 1.0, d);
	float bri = 1.0;
	float sha = 1.0;
	if( s.m == 0 ) {
		return corner( p_org, fTime );
//		return vec4(0.0);
	}else if( s.m == 1 ) {
		c = d/dtweak;
		vec3 n = get_normal( ro + d*rd ); 
		bri = max(dot( light1, n ), 0.0);
		// bri = 1.0;
		n.x = map( n.x, -1.0, 1.0, 0.0, 1.0 );
		n.y = map( n.y, -1.0, 1.0, 0.0, 1.0 );
		//return vec4( n, 1.0 );
		// bri = smoothstep( 0.5, .7, bri );
		bri = smoothstep( 0.0, 1.0, 0.25 + bri );
//		vec3 col = vec3( 1.0 )*bri * sha;
		//vec3 col = palette_p3( bri );
		vec4 col = palette_lookup( sphere_pal, bri*sha );
		return col;
//		return vec4( col, 1.0 );
	} else if( s.m == 2 ) {
		c = d/dtweak;
		vec3 n = get_normal( ro + d*rd ); 
		float bri = dot( light1, n );
		// bri = 1.0;
		n.x = map( n.x, -1.0, 1.0, 0.0, 1.0 );
		n.y = map( n.y, -1.0, 1.0, 0.0, 1.0 );
		//return vec4( n, 1.0 );
		// bri = smoothstep( 0.5, .7, bri );
		bri = max(dot( light1, n ), 0.0);
		float fog = smoothstep( 0.1, 1.0, 50.0/d);
		//fog = 0.5;

		// shadow
		sha = get_shadow( rp, light1_pos );

		vec3 col = color1_rgb*bri * sha;
		//vec3 col = normalize( light1_pos - rp ).xyz;
		//vec3 col = normalize( rp ).zzz;
//		vec3 col = palette_p3( bri );
//		vec3 col = n;
		vec4 back = corner( p_org, fTime );
//		vec4 back = vec4( 1.0 );
		fog = 1.0; // unfog
		return mix( back, vec4( col, 1.0 ), fog );
//		return vec4( col, 1.0 )*fog;
	} else if( s.m == 3 ) {
		return corner( s.t, fTime );
//		return vec4( s.t.x, s.t.y, 0.2, 1.0 );
	} else if( s.m == 4 ) {
//		return corner( s.t, fTime );
		return vec4( s.t.x, s.t.y, 0.2, 1.0 );
	} else {
		return vec4( 1.0, 1.0, 1.0, 1.0 );
	}
}

vec4 layout1( void )
{
    float time = speed*fTime;
	vec2 p = vec2(p.x, p.y*(9.0/16.0));

	vec4 click_col = click_pos( p, time );
	vec4 hover_col = hover_pos( p, time );

	vec4 co;
	co = mandel( p, time );

	return co + click_col + hover_col;
}

vec4 layout2( void )
{
    float time = speed*fTime;
	vec2 p = vec2(p.x, p.y*(9.0/16.0));

	vec4 co;
	float s = 4.0;
	//p = p * s - vec2( s/2.0, s/2.0 );
	co = corner( p, time+new_property );

	return co;
}


vec4 layout3( void )
{
    float time = speed*fTime;
	vec2 p = vec2(p.x, p.y*(9.0/16.0));

	float i = map( p.x, -1.0, 1.0, 0.0, 1.0 );

	return palette_lookup( default_pal, i );
//	return palette_p( i );
}

void main() {
	if ( the_layout < 1.0 ) {
		out_color = layout0();
	} else if ( the_layout < 2.0 ) {
		out_color = layout1();
	} else if ( the_layout < 3.0 ) {
		out_color = layout2();
	} else {
		out_color = layout3();
	}
}




