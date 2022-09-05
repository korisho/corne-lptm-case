include <common.scad>
include <case-params.scad>

use <case-shape.scad>


h = case_total_height()+0.5;
r = 1;

module bento(build=false) { // make me
    _bento(build, rounded=true, fn=30);
}

module bento_outer_shell(rounded=false, fn=0) {
    if (rounded) {
        translate([0,0,case_rounding])
        minkowski() {
            linear_extrude(2*(h-case_rounding))
            difference() {
                offset(case_rounding+r) shape_of_case_trimmed();
                offset(case_rounding+r-0.01) shape_of_case_trimmed();
            }
            sphere(r, $fn=fn);
        }
    }
    else {
        translate([0,0,case_rounding-r])
        linear_extrude(2*(h-case_rounding+r))
            offset(case_rounding+2*r) shape_of_case_trimmed();
    }
    
    hold_r = 3;
    hold_w = 15;
    module hold() {
        hull() {
            rr=3;
            d=case_rounding;
            translate([0,0,d]) torushull(rr,r, fn1=fn, fn2=fn);
            translate([0,0,2*h-d]) torushull(rr,r, fn1=fn, fn2=fn);
        }
    }
    
    hold_pos = [
        [125,-54,0],
        [125,-146,0],
        [125+hold_r*2+hold_w,-54.5],
        [125+hold_r*2+hold_w,-148.5,0],
    ];
    for (p=hold_pos) translate(p) hold();

      
    module handle1() {
        translate([174,-65,0]) {
            d=1.5;
            r1=3;
            r2=r1-d;
            gr=1;
            gh=case_rounding*2;
            gw=10;
            gd=5;
            minkowski() {
                translate([0,0,h-gh/2+gr])
                linear_extrude(gh-gr*2)
                difference() {
                    e=0.001;
                    square([gw,gd]);
                    square([gw-e,gd-e]);
                }
                sphere(gr);
            }
        }
    }
    
    module handle2() {
        gr1 = case_rounding;
        gr2 = r;
        gh = case_rounding*2;
        gw=10;
        gd=5;
        
        module half_handle() {
            linear_extrude(gh/2-gr2) {
                translate([gw-gr1,gd-gr1])
                difference() {
                    circle(gr1, $fn=fn);
                    circle(gr1-2*gr2, $fn=fn);
                    translate([-(gr1+1),-(gr1+1)]) square([2*(gr1+1), gr1+1]);
                    translate([-(gr1+1),-(gr1+1)]) square([gr1+1, 2*(gr1+1)]);
                }
                
                translate([0,gd-2*gr2]) square([gw-gr1,2*gr2]);
                translate([gw-2*gr2,0]) square([2*gr2,gd-gr1]);
            }
            
            translate([0,gd-gr2,gh/2-gr2]) rotate([0,90,0]) cylinder(h=gw-gr1, r=gr2);
            translate([gw-gr1,gd-gr1,gh/2-gr2]) torus(gr1, gr2, 90, fn1=fn, fn2=fn);
        }
        
        half_handle();
        mirror([0,0,1]) half_handle(); 
    }
    
    module handle() {
        gr1 = 4;
        gr2 = r;
        gh = case_rounding*2;
        gw=10;
        gd=5;
        
        module basic_shape() {
            hull() 
            {
                translate([0, (gh/2-gr2)]) circle(gr2, $fn=30);
                translate([0,-(gh/2-gr2)]) circle(gr2, $fn=30);
            }
        }
        
        translate([gw-gr1,gd-gr1]) rotate_extrude(angle=90, $fn=30) translate([gr1-gr2,0]) basic_shape();
        translate([0,gd-gr2]) rotate([90,0,0]) rotate([0,90,0]) linear_extrude(gw-gr1) basic_shape();
        translate([gw-gr2,0]) rotate([-90,0,0]) linear_extrude(gd-gr1) basic_shape();
       
    }

    translate([175,-64.2,h]) handle();
}

module _bento(build=false, rounded=true, show_cases=true, fn=0) {    
    module stacked_cases() {
        basic_shape_of_case();
        translate([0,0,h*2]) mirror([0,0,1]) basic_shape_of_case();
    }
    
    module case_hole() {
        linear_extrude(2*h) offset(1) shape_of_case_trimmed();
        stacked_cases();
    }

    module bento_basic_shape() {
        translate([0,0,case_rounding]) linear_extrude(2*(h-case_rounding)) offset(case_rounding) shape_of_case_trimmed();
        bento_outer_shell(rounded, fn=fn);
    }
    
    difference() {
        bento_basic_shape();
        case_hole();
    }
    
    if (show_cases) {
        %color("red",0.3) stacked_cases();
    }
}


_bento(build=true, rounded=false);
