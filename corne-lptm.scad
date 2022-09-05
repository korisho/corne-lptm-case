include <common.scad>
include <case-params.scad>

use <case-shape.scad>
use <tent-shape.scad>
use <palmrest-shape.scad>



module palmrest() {
    w = 100;
    d = 130;
    h = 30;
    r = 2;
    pts = [ // [x, y, size]
        [[   0,   0,    0 ], r ],
        [[   0,   w,    0 ], r ],
        [[   d,   w,    0 ], r ],
        [[   d,   0,    0 ], r ],
        [[   d,   w,    h ], r ],
        [[   d,   w,  h/3 ], r ],
    ];
    
    translate([0,-40-d,0])
    //hull() for (p = pts) translate(p[0]) sphere(p[1]);
    hull() {
    //union() {
        r=60;
        s=0.2;
        translate([0,0,0]) linear_extrude(1) scale([1,s,1]) circle(r);
        //translate([-r,-r*s,0]) rotate([3,-5,0]) translate([r,r*s,0]) linear_extrude(1) scale([1,s,1]) circle(r);
        
        pts = [
            [-w/2,0,0],
            [ w/2,0,0],
            [-w/2,0,h],
            [ w/2,0,h],
        ];
    }
}


case(build=true);

translate([100,55,0]) tent(build=true);

palmrest();



//====================================================================================


module mcu_box_top() {
    intersection(){
        case();
        color("red",0.25) translate([0,0,-50]) linear_extrude(100) {
            translate([-77,45]) square([40,70]);
            translate([-45,78]) square([30,30]);
            translate([-23,27]) rotate(120) square([50,35]);
        }
    }

    //translate([-46,50,0]) rotate(120) cube([35,30,30],center=true);
}

module keys_top() {
    intersection(){
        case();
        translate([56.5,84,0]) cube([39,25,40],center=true);
    } 
    
}

module section_cut() {
    module selection() { translate([0,-150,-100]) cube([200,300,200]); }
    intersection() {  selection(); case(); }
    translate([-50, 0, 0]) difference() { case(); selection();  }
}


module show_case_shape() {
    difference() {
        linear_extrude(1) shape_of_case();
        linear_extrude(2) shape_of_pcb();
    }
}

//show_case_shape();


