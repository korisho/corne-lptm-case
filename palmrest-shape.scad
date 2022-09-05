include <common.scad>
include <case-params.scad>

use <case-shape.scad>
use <tent-shape.scad>

module palmrest(build=false) { // make me
    _palmrest(build, fn1=60, fn2=30);
}

module rot_orig(angle, origin) {
    translate(-origin)
    rotate(angle)
    translate(origin)
    children();
}

module _palmrest(build=false, fn1 = 30, fn2 = 15) {
    
    top_rounding = case_rounding*2;

    tdz = 2;

    brnd = 1;
    l = 110;
    w = 100;
    
    tfp = tent_front_wall_pts(); 
    echo("tfp=",tfp);
    
    xrnd = 30;
    
    //translate(p1[0]-r*p1[1]) for (a=[0:2:10] circle(r);

    ptA = [-5.18,-28.4,0];
    ptB = [30,-30,0];
    ptC = [111.4,-57.1,0];
    ptD = [w-30,-l,0];
    ptE = [-3.9,-l,0];
    
    r = tent_front_wall_rounding();
    p1 = tent_front_wall(s=0.25);
    p2 = tent_front_wall(s=1);
    br = (p1[0][1]-(ptA[1]+case_rounding))/(abs(p1[1][1])-1);
        
    pts = [
        ptA,
        ptB,
    ];
    
    rot_orig=[-65.8,105,bumper_height_outside];
    
    module point_labels() {
        module ptlab(pt, lab) {
            translate(pt) {
               text(lab, size=5); 
               circle(0.5,$fn=30);
            }
        }
        
        %color("green",0.5) {
            ptlab(ptA, "A");
            ptlab(ptB, "B");
            ptlab(ptC, "C");
            ptlab(ptD, "D");
            ptlab(ptE, "E");
            ptlab(p1[0], "p1");
            ptlab(p2[0], "p2");
        }
    }


    point_labels();

    function scalex(p, pad=false) = 
        let(x = p[0]*cos(tent_angle))
        (pad || len(p)>2)
            ? [ x, p[1], p[2]] 
            : [ x, p[1] ];
    
    module ptA_sphere(incl_sphere=true) {
        translate([0,0,bumper_height_outside/2])
        translate(ptA)
        scale([1,1,(case_rounding-bumper_height_outside/2)/case_rounding])
        hull() {
            if (incl_sphere) sphere(case_rounding, $fn=fn1);
            translate([0,0,-case_rounding+brnd]) torushull(case_rounding, brnd, fn1=fn1, fn2=fn2);
        }
    }
    
    module attachment() {
        module base1() {
            translate([0,0,bumper_height_outside+brnd]) hull() {
                scale([0.995*cos(tent_angle),1,1]) translate(ptC) torushull(case_rounding, brnd, fn1=fn1, fn2=fn2);
                intersection() {
                    translate(p1[0]+p1[1]*br) torushull(br,brnd, fn1=fn1, fn2=fn2); 
                    translate(p1[0]+p1[1]+[-br*p1[1][0]-5,br-1]) cube([br*2,br*2, brnd*4], center=true);
                }
                translate(p2[0]+p2[1]*case_rounding) torushull(case_rounding, brnd, fn1=fn1, fn2=fn2);
                //translate(scalex(ptA)) torushull(case_rounding, brnd, fn1=fn1, fn2=fn2);
                translate([ptB[0],ptA[1],0]) torushull(case_rounding, brnd, fn1=fn1, fn2=fn2);
            }
        }
        
        color("green",0.8) hull() {
            dx=-2.75*case_rounding/cos(tent_angle);
            base1();
            //translate([dx,0,0]) rotate(-tent_angle, [0,1,0]) translate([dx,0,0])
            rot_orig([0,-tent_angle,0], [dx,0,0])
                scale([1/cos(tent_angle),1,1]) base1();
        }
    }
   
    bumper_hole_pos = let(bhr=bumper_hole_radius) [
        scalex(ptA+[bhr,-bhr,0]),
        scalex(ptC+[-bhr/4-0.25,-bhr/4,0]),
        scalex(ptD+[xrnd/sqrt(2)-bhr+0.10,-xrnd/sqrt(2)+bhr-1,0]),
        scalex(ptE+[-xrnd/sqrt(2)+bhr,-xrnd/sqrt(2)+bhr,0]+[-3,3,0]),
    ];
    
    module bumpers() {
        for (p=bumper_hole_pos) 
            translate(p+[0,0,bumper_height_inside+bumper_height_outside]) bumper();
    }
    
    module bumper_holes() {
        for (p=bumper_hole_pos) {
            translate([0,0,bumper_height_outside]) bumper_hole(p);
            translate([0,0,bumper_height_outside/2]) bumper_hole(p);
        }
    }
    
    module magnet_holes() {
        for (pu = tent_front_magnet_hole_pos(tent_angle)) {
            p = pu[0];
            u = pu[1];
            translate(p) rotate(90,u) translate([0,0,-magnet_height]) 
                linear_extrude(0.1+magnet_height) circle(magnet_hole_radius, $fn=30);
        }
    }
    
    module shape_back_outer(r=case_rounding, top=true) {
        hull() {
            translate(ptB) sphere(r, $fn=fn1);
            if (top) ptA_sphere();
            else translate(ptA) torushull(case_rounding, r, fn1=fn1, fn2=fn2);
            translate([32.5,-54,0]) rotate(15) torus(30,r,90, fn1=fn1, fn2=fn1);
        }
    }
    
    module shape_back_inner(r=case_rounding) {
        hull() {
            translate([0,0,r-case_rounding]) translate([56.25,-164.45,0]) 
                rotate(63) torus(125,r,30, fn1=fn1*4, fn2=fn2);
            translate([0,0,r-case_rounding]) translate(ptC) 
                if (r<case_rounding) torushull(case_rounding, r, fn1=fn1, fn2=fn2);
                else sphere(r, $fn=fn1);
        }
    }
 
    module shape_top_back() {
        rotate(-tent_angle, [0,1,0])
        translate([0,0,case_rounding+bumper_height_outside]) {
            shape_back_outer();
            shape_back_inner();
        }
    }

    module shape_back() {
        hull() {
            translate([0,0,bumper_height_outside+brnd])
                scale([cos(tent_angle),1,1]) shape_back_outer(brnd, top=false);
            translate([0,0,tdz])
            rotate(-tent_angle, [0,1,0]) 
                translate([0,0,case_rounding+bumper_height_outside])
                shape_back_outer();
        }
        
        hull() {
            translate([0,0,case_rounding+bumper_height_outside])
                scale([cos(tent_angle),1,1]) shape_back_inner(brnd);
            translate([0,0,tdz])
            rotate(-tent_angle, [0,1,0]) 
                translate([0,0,case_rounding+bumper_height_outside])
                shape_back_inner();
        }
    }

    module shape_top_main() {
        hull() {
            rr = case_rounding;
            ptA_sphere();
            
            translate(ptC) sphere(rr, $fn=fn1);
            //translate([w, -l, 2]) sphere(rr, $fn=fn1);
            
            translate(ptD) torushull(xrnd,rr, fn1=fn1, fn2=fn2);
            //translate([-5.18,-l,-rr+brnd]) torushull(30,brnd, fn1=fn1, fn2=fn2);
            translate(ptE+[0,0,rr-brnd-tdz]) difference() {
                torushull(xrnd, brnd+tdz, fn1=fn1, fn2=fn2);
                translate([0,0, -(brnd+tdz+1)/2]) cube([xrnd*3, xrnd*3, brnd+tdz+1], center=true);
            }
        }
    }
    
    module basic_shape() {
        
        //shape_top_back();
        shape_back();
        
        hull() 
        {
            translate([0,0,tdz])
            rotate(-tent_angle, [0,1,0])
            translate([0,0,case_rounding+bumper_height_outside]) {
                shape_top_main();
            }

            translate([0,0,bumper_height_outside+brnd])
                translate(ptA) torushull(case_rounding, brnd, fn1=fn1, fn2=fn2);

            translate([0,0,bumper_height_outside+brnd]) scale([cos(tent_angle),1,1]) {
                translate([-5.18,-l,0]) torushull(30, brnd, fn1=fn1, fn2=fn2);
                translate([w-30,-l,0]) torushull(30, brnd, fn1=fn1, fn2=fn2);
                translate([ptC[0],ptC[1],0]) torushull(case_rounding, brnd, fn1=fn1, fn2=fn2);
            }
        }
        
        attachment();
    }
    
    module tent_cutout() {
        translate([68,-85,0])
        rotate([0,0,-15])
        scale(80.5/80.0) // add about 0.5mm wiggle room
        translate([-102,0,0])
        translate([100,0,0]) scale([1.01,1.01,1]) translate([-100,0,0])
        hull() {
            tent(show_attachments=false);
            translate([0,0,-20]) tent(show_attachments=false);
        }
    }
    
    difference() {
        basic_shape();
        magnet_holes();
        bumper_holes();
        tent_cutout();
    }
    
    %color("purple",0.5) bumpers();
}

_palmrest(build=true);


//%rotate(tent_angle,[0,1,0]) tent();

//%tent();

module show_case() {
    translate([1,0,0])
    rotate(-tent_angle, [0,1,0]) {
        rot_orig=[-65.8,105,bumper_height_outside];
            translate(rot_orig) basic_shape_of_case();
    }
}

//%color("blue",0.25) show_case();


if (false) {
    %translate([-200,0,0])
    difference() {
        _palmrest(build=true);
        translate([0,-100,0]) cube(100,center=true);
    }
}
