
promicro_position  = [185,-85.25];
promicro_dimension = [20,36.5];

//promicro_plug_position = [ 185.5, -68];
promicro_plug_position = promicro_position + [0,promicro_dimension[1]/2-1];
promicro_plug_dimension = [ 11, 20 ];

reset_button_position = [ 192.5, -107];

lcd_position = [ 185, -88.5 ];
lcd_dim = [ 13, 42 ];
lcd_view_dim = [ 10, 25.5 ];


promicro_lcd_position = [185.5,-88.5];
promicro_lcd_dimension = [21,41];


tenting_screw_positions = [
    [ 170, -57 ],
    [ 193, -147 ],
    [ 54, -120 ],
    [ 54, -75 ],
];

tenting_screw_small_positions = [
    [ 170, -57 ],
    [ 193, -147 ],
    [ 71.5, -97.5 ],
];

tenting_screw_rotation = [
    0,
    0,
    30,
    30,
];

integrated_tenting_screw_positions = [
    [ 16.3, -23.5 ],
    [ 16.3, -153 ],
    [ 88, -154 ],
    [ 140.5, -101 ],
    [ 140, -18.1 ],
];

tightening_screw_positions = [
    [ 17.5, -26, 0 ],
    [ 18.5, -88, 0 ],
    [ 81.0, -116, 0 ],
    [ 118.5, -132.5, 0 ],
    [ 139, -88.5, 0 ],
    [ 140, -56.5, 0 ],
    [ 140, -20.5, 0 ],
    [ 112.5, -17.2, 0 ],
    [ 71, -8.6, 0 ]
];

stagger = [ -77.125, -77.125, -72.375, -70, -72.375, -74.75 ];

bumper_hole_positions = [
    [ 128.4, -100.25 ],
    [ 136.5, -100.25 ],
    [  65.8, -119.5 ],
    [  65.8, -111.4 ],
    [  65.8, -71.7 ],
    [  65.8, -79.8 ],
    [ 182.3, -73.9 ],
    [ 188.1, -79.7 ],
    [ 181.1, -142.4 ],
    [ 173.2, -144.6 ],
];

magnet_hole_positions = [
    [ 70.37, -91.14 ],
    [ 127.05, -66.17 ],
    [ 136.61, -123.1 ],
    [ 185.51, -88.0 ],
    [ 185.51, -125.8 ],
];

pcb_supports = [
    [60.5, -67.125],
    [79.5, -67.125],
    [98.25, -65],
    [101, -62],
    [117.5, -61.1875],
    [136.5, -61.1875],
    [155.5, -63.5625],
    [176, -68],
    [60.5, -86.125],
    [136.5, -84.6],
    [60.5, -105.125],
    [117.5, -98.8],
    [136.5, -99.1875],
    [155.5, -99.9],
    [185.5, -101.5],
    //[185.5, -70],
    [60.5, -124.125],
    [79.5, -124.125],
    [104, -124],
    [146, -142],
    [192.8, -130.0],
    [180, -151.7],
    [167, -146.5],
];

pcb_screw_positions = [
    [122.75, -122.75],
    [169.25, -130.52],
    [155.45,  -83.05],
    [ 79.45, -105.65],
    [ 79.45,  -86.62],
];

pcb_cover_screw_positions = [
    [ 192.1, -124.3 ],
    [ 177.65, -115.58 ]
];

pcb_cover_screw_radius=1;

module rect(position, size) {
    pts = [
        position + [ -size[0],  size[1] ]/2,
        position + [ -size[0], -size[1] ]/2,
        position + [  size[0], -size[1] ]/2,
        position + [  size[0],  size[1] ]/2,
    ];
    polygon(points = pts);
}

// the extent of the children projection on x axis
module __xExtent()
    hull() translate([0,1/2])
    projection() rotate([90,0,0])
    linear_extrude(1) children();

// the bounding rectangle of children
module bounding_rect()
    offset(-1/2)
    minkowski() {
    __xExtent() children();
    rotate(-90) __xExtent() rotate(90) children();
}

function sqr(x) = x*x;
module sectorx(p1,p2,d,n=10) {
    pm = (p1+p2)/2;
    p12 = p2-p1;
    dp = sqrt(p12*p12);
    vn = [-p12[1],p12[0]]/dp;   
    s = sqr(dp)/8/d-d/2;
    c = pm + vn*s;    
    r = d+s;
    x = -vn * (p1-c)/r;
    th = acos(x);
    da_=acos(-vn[0]);
    da = vn[1] < 0 ? da_ : -da_;
    pts_ = [for (a=[(da-th):(th*2/n):(da+th)]) c+r*[cos(a),sin(a)]];
    pts = concat([p1],pts_,[p2]);
    polygon(pts);
}

module sector(radius, angles, fn = 60)
{
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat(
        [[ 0, 0 ]],
        [for (a = [angles[0]:step:angles[1] - 360])[r * cos(a), r * sin(a)]],
        [[r * cos(angles[1]), r * sin(angles[1])]]);

    difference()
    {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

module arc(radius, angles, width = 1, fn = 60)
{
    difference()
    {
        sector(radius + width, angles, fn);
        sector(radius, angles, fn);
    }
}

module
tenting_hole()
{
    circle(r = 3.2, $fn = 30);
}

module tenting_holes(small = false)
{
    tenting_location =
        small ? tenting_screw_small_positions : tenting_screw_positions;
    for (i = [0:len(tenting_location) - 1]) {
        translate(tenting_location[i]) linear_extrude(height = 25)
            tenting_hole();
    }
}

module tenting_screw_housing(small = false)
{
    tenting_location =
        small ? tenting_screw_small_positions : tenting_screw_positions;
    for (i = [0:len(tenting_location) - 1]) {
        translate(tenting_location[i]) translate([ 0, 0, 17 ])
            rotate(tenting_screw_rotation[i]) linear_extrude(height = 5.5)
                circle(r = 6.5, $fn = 6);
    }
}

module
tightening_hole()
{
    circle(r = 1.2);
}

module
promicro_plug_space()
{
    x = promicro_plug_position[0];
    y = promicro_plug_position[1];
    w = promicro_plug_dimension[0];
    l = promicro_plug_dimension[1];

    pts = [
        [ x-w/2, y ],
        [ x-w/2, y+l ],
        [ x+w/2, y+l ],
        [ x+w/2, y ],
    ];
    polygon(points = pts);
}

module
promicro_space()
{
    rect(promicro_position,promicro_dimension);
}

module promicro_ext_space0() {
polygon(points = [
        [ 175, -67 ],
        [ 196, -67 ],
        [ 196, -105 ],
        [ 191, -106 ],
        [ 190.5, -111.5 ],
        [ 179.5, -111.5 ],
        [ 175, -105 ],
    ]);
}

module
promicro_ext_space()
{
    x=promicro_position[0];
    y=promicro_position[1];
    w=promicro_dimension[0];
    l=promicro_dimension[1];

    lw=lcd_dim[0];
    ll=lcd_dim[1];
    pmy=promicro_lcd_position[1];
    pml=promicro_lcd_dimension[1];

    dx=-0.5;
    polygon(points = [
        [ x-w/2-dx,  y+l/2 ],
        [ x+w/2,      y+l/2 ],
        [ x+w/2,      y-l/2-1.5 ],
        [ x+lw/2-1,   y-l/2-2.5],
        [ x+lw/2-1.5, pmy-pml/2-3.5 ],
        [ x-lw/2+0.5, pmy-pml/2-3.5 ],
        [ x-w/2-dx,  y-l/2-1.5 ],
    ]);    
}

module
promicro_lcd_space()
{
    rect(promicro_lcd_position,promicro_lcd_dimension);
}

module
lcd_hole()
{
    rect(lcd_position, lcd_dim);
}

module
lcd_view_hole()
{
    rect(lcd_position + [0,-1], lcd_view_dim);
}

trrs_position = [194.43, -115.5];
trrs_width = 7;
trrs_height = 5.5;

module
trrs_hole()
{
    polygon(points = [
        [ 182, trrs_position[1]+trrs_width/2 ],
        [ 182, trrs_position[1]-trrs_width/2 ],
        [ trrs_position[0]+1, trrs_position[1]-trrs_width/2 ],
        [ trrs_position[0]+1, trrs_position[1]+trrs_width/2 ],
    ]);
}

module
trrs_plug_space()
{
    polygon(points = [
        [ trrs_position[0]+10, trrs_position[1]+trrs_width/2 ],
        [ trrs_position[0]+10, trrs_position[1]-trrs_width/2 ],
        [ trrs_position[0]-1,  trrs_position[1]-trrs_width/2 ],
        [ trrs_position[0]-1,  trrs_position[1]+trrs_width/2 ],
    ]);
}

module
mcu_box_space()
{
    polygon(points = [
        [ 174.5,  -68],
        [ 195,  -68],
        [ 195, -130],
        [ 174.5, -118.1],
    ]);
}

key_width = 14.1; // 14mm + 0.1mm buffer
key_cap_width = 18.5;

module alpha_holes(width = 14, start = 0)
{
    for (j = [0:2]) {
        for (i = [start:len(stagger) - 1]) {
            translate([ (70 + i * 19), (stagger[i] - j * 19), 0 ])
            {
                square(size = [ width, width ], center = true);
            }
        }
    }
}

module thumb_holes(width = 14, long_thumb = 14)
{
    union()
    {
        translate([ 136.5, -130, 0 ])
        {
            rotate([ 0, 0, 0 ])
            {
                square(size = [ width, width ], center = true);
            }
        }
        translate([ 157.5, -132.75, 0 ])
        {
            rotate([ 0, 0, 165 ])
            {
                square(size = [ width, width ], center = true);
            }
        }
        translate([ 179.75, -136.5, 0 ])
        {
            rotate([ 0, 0, 240 ])
            {
                square(size = [ long_thumb, width ], center = true);
            }
        }
    }
}

module
shape_of_pcb()
{
    import("shape-of-pcb.dxf");
}

module
shape_of_small_pcb()
{
    import("shape-of-small-pcb.dxf");
}

module shape_of_case()
{
    pts = [
        [  60.75,  -67 ],
        [  60.75, -124.55 ],
        [  99.00, -124.55 ],
        [ 127.00, -140 ],
        [ 180.76, -154 ],
        [ 195.23, -128.56 ],
        [ 195.23,  -67 ],
        [ 175,  -67 ],
        [ 175,  -65.5 ],
        [ 80.00,  -67 ],
    ];

    np=10;
    sectorx(pts[8],pts[9],6,np*2);
    
    difference() {
        s=[20,2.4];
        p=pts[9]+[0,s[1]/2];
        p1=p+[-1.5*s[0],s[1]/2];
        p2=p+s/2;
        rect(p,s);
        sectorx(p1,p2,s[1]);
    }
    
    difference() {
        polygon(pts);
        sectorx(pts[3],pts[2],4,np);
        polygon([pts[3]-[0.1,0.1],pts[3],pts[2],pts[2]+[0.1,-0.1]]);
        sectorx(pts[4],pts[3],3,np);
    }
}

module
shape_of_small_case()
{
    top_angles = [ 59, 120.3 ];
    top_center = [ 136.5, -164.5 ];
    top_radius = 112.6;
    left_angles = [ 165.4, 194.5 ];
    left_center = [ 190, -96 ];
    left_radius = 113.9;
    lower_left_angles = [ 0, 180 ];
    lower_left_center = [ 80, -210 ];
    lower_left_radius = 85.42;
    lower_right_angles = [ 0, 180 ];
    lower_right_center = [ 125, -262 ];
    lower_right_radius = 121.5;
    right_angles = [ -8.9, 10.3 ];
    right_center = [ 4.5, -102.5 ];
    right_radius = 193.55;
    difference()
    {
        union()
        {
            translate(top_center) sector(top_radius, top_angles);
            translate(left_center) sector(left_radius, left_angles);
            difference()
            {
                translate(right_center) sector(right_radius, right_angles);
                square(size = [ 300, 300 ], center = true);
            }
            polygon(points = [
                [ 80, -68 ],
                [ 80, -125 ],
                [ 127, -139 ],
                [ 143.5, -142 ],
                [ 182.5, -157.5 ],
                [ 195.5, -132.2 ],
                [ 193.75, -68 ],
            ]);
        }
        translate(lower_right_center)
            sector(lower_right_radius, lower_right_angles);
        translate(lower_left_center)
            sector(lower_left_radius, lower_left_angles);
    }
}

module torus(r1, r2, angle=360, fn1=0, fn2=0) {
    rotate_extrude(angle=angle, $fn=fn1) translate([r1-r2,0]) circle(r2, $fn=fn2);
}

module torushull(r1, r2, angle=360, fn1=0, fn2=0) {
    hull() torus(r1, r2, angle, fn1=fn1, fn2=fn2);
}

module trapezoid(d1,d2,h)
{
  x1=d1[0];
  y1=d1[1];
  x2=d2[0];
  y2=d2[1];
  dx=(x1-x2)/2;
  dy=(y1-y2)/2;
  
  points = [
  [     0,     0,  0 ],  //0
  [    x1,     0,  0 ],  //1
  [    x1,    y1,  0 ],  //2
  [     0,    y1,  0 ],  //3
  [    dx,    dy,  h ],  //4
  [ x2+dx,    dy,  h ],  //5
  [ x2+dx, y2+dy,  h ],  //6
  [    dx, y2+dy,  h ]]; //7
  
  faces = [
  [0,1,2,3],  // bottom
  [4,5,1,0],  // front
  [7,6,5,4],  // top
  [5,6,2,1],  // right
  [6,7,3,2],  // back
  [7,4,0,3]]; // left
  
  polyhedron(points, faces);
}

function bounding_box(pts) = [
    min([for(p=pts) p[0]]),
    min([for(p=pts) p[1]]),
    max([for(p=pts) p[0]]),
    max([for(p=pts) p[1]]),
];
