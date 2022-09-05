include <common.scad>
include <case-params.scad>
use <case-shape.scad>


module tent(tent_angle=tent_angle, build=false, show_attachments=true) { // make me
    if (!build) {
        echo("loading tent shape from file");
        import("stl/tent.stl");
    }
    else {
        _tent(tent_angle=tent_angle);
    }
    
    if (show_attachments) {
      %show_case(tent_angle);
      %color("purple",0.5) tent_bumpers();
    }
}

module tent_bumpers() {
    translate(rot_origin())
    translate([0,0,bumper_height_inside])
    for (p=tent_bpts()) {
        translate(p) bumper();
    }
}

module show_case(tent_angle, rot_orig=[-65.8,105,bumper_height_outside]) {
    rotate(-tent_angle,[0,1,0])
    translate(rot_orig) {
        %color("red",0.5) basic_shape_of_case();
        %color("blue",0.5) magnet_holes();
        %color("green",0.5) case_bumper_holes();
        %color("purple",0.5) case_bumpers(); 
    }
}

module _tent1(tent_angle, round_edge) {
    rot_orig = [-65.8,105,bumper_height_outside];

    module case_shape() {
        translate([-126,105]) offset(r=case_rounding) shape_of_case_trimmed();
    }
    
    function scale_floor_pts(pts) = [
        for (p=pts) [rot_orig[0]+(p[0]-rot_orig[0])*cos(tent_angle),p[1]]
    ];
    
    pts=[
        [ 136.61, -123.1 ],
        [ 128.4, -100.25 ],
        [ 182.3-3, -73.9 ],
        [ 188.1, -73.9 ],
        [ 188.1, -79.7 ],
        [ 185.51, -88.0 ],
        [ 185.51, -125.8 ],
        [ 187.4, -131.2 ],
        [ 181.1, -142.4 ],
        [ 178.25, -147.45],
        [ 173.2, -144.6 ],
    ];
    
    bptsx=180*cos(tent_angle);
    bpts=[
        [ bptsx, -147.45],
        [ bptsx, -73.9 ],
    ];
    
    tent_height = 140 * sin(tent_angle);
    echo("tent height:", tent_height);

    round_edge_radius=1;
    round_edge_fn=30;
    
    
    module tent_shape_top() {
        echo("tent_shape_top()");
        offset(case_rounding) offset(-case_rounding) hull() {
            for (p=[pts[0],pts[1]])
                translate(p) circle(bumper_hole_radius+3); 
            offset(delta=bumper_hole_radius+3) polygon(pts);
        }
    }
     
    module basic_tent_shape() {
        mcu_box_top = pcb_top + promicro_height+lcd_height+mcu_box_ceiling_thickness;
        
        echo("basic_tent_shape()");
        difference() {
            rer = round_edge ? round_edge_radius : 0;
            irer = !round_edge ? round_edge_radius : 0;
            translate([0,0,bumper_height_outside+rer])
            linear_extrude(tent_height+mcu_box_top + 2*irer)
                rotate(-tent_angle,[0,1,0])
                translate(rot_orig)
                offset(1+irer) tent_shape_top();
        
            rotate(-tent_angle,[0,1,0]) translate(rot_orig) {
                translate([0,0,case_height/2])
                linear_extrude(mcu_box_top*3)
                offset(delta=case_rounding*4) shape_of_case_trimmed();
            }
            
            rot_orig_dx = bpts[0][0]-bounding_box(bumper_hole_positions)[0];
            bb = bounding_box(pts);
            s = [bb[2]-bb[0], bb[3]-bb[1]]*2;
            translate([rot_orig_dx,bb[1]+s[1]/2,rer])
            rotate(180+tent_angle/2,[0,1,0])
            linear_extrude(mcu_box_top*3)square(s);
        }
    }
    
    module rounded_difference(r=0, fn) {
        echo("rounded_difference() start");
        if (r <= 0) {
            difference() { 
                children(0); 
                children([1:$children-1]);
            }
        }
        else {
            minkowski() {
                difference() {
                    children(0);
                    minkowski() {
                        children([1:$children-1]);
                        sphere(r=round_edge_radius, $fn=round_edge_fn);
                    }
                }
                sphere(r=round_edge_radius, $fn=round_edge_fn);
            }
        }
        echo("rounded_difference() finish");
    }

    translate([85,55,0]) 
    //rotate(tent_angle,[0,1,0])
    {
        difference() {
            
            rounded_difference(r=round_edge?round_edge_radius:0, fn=0) {
                basic_tent_shape();
                rotate(-tent_angle,[0,1,0]) translate(rot_orig) basic_shape_of_case();
            }
        
            translate(rot_orig) 
            for (p=bpts) {
                bumper_hole(p);
            }
            
            color("blue")
            rotate(-tent_angle,[0,1,0]) translate(rot_orig) {
                translate([0,0,-bumper_height_outside])
                linear_extrude(bumper_height_outside+1) 
                for (p=bumper_hole_positions) translate(p) circle(bumper_hole_radius, $fn=30);
            }
            
            color("purple")
            rotate(-tent_angle,[0,1,0]) translate(rot_orig) {
                translate([0,0,-magnet_height])
                    magnet_holes();
            }
        }        
    }
}


function rot_origin() = [-65.8,105,bumper_height_outside];

function tent_pts() = [
        [ 136.61, -123.1 ],
        [ 128.4, -100.25 ],
        [ 182.3-3, -73.9 ],
        [ 188.1, -73.9 ],
        [ 188.1, -79.7 ],
        [ 185.51, -88.0 ],
        [ 185.51, -125.8 ],
        [ 187.4, -131.2 ],
        [ 181.1, -142.4 ],
        [ 178.25, -147.45],
        [ 173.2, -144.6 ],
    ];

function tent_bpts() = let(bptsx=179) [
        [ bptsx, -147.45],
        [ bptsx, -73.9 ],
    ];

function tent_front_wall_pts() =
    let(pts = tent_pts())
    [pts[0],pts[9]];

function tent_front_wall_rounding() = bumper_hole_radius+case_rounding;

function tent_front_wall(s,tent_angle=tent_angle) =
    let(rot_orig = rot_origin())
    let(pts = tent_front_wall_pts())
    let(p1 = pts[0])
    let(p2 = pts[1])
    let(p12 = p2-p1)
    let(pu = p12 / sqrt(p12*p12))
    let(pt = [pu[1],-pu[0]])
    let(ps = rot_orig + p1 + s*p12 + pt * tent_front_wall_rounding())
    [[ps[0]*cos(tent_angle),ps[1]],pt];
    
    
function tent_front_magnet_hole_pos(tent_angle) = [
    let(dx = tent_bpts()[0][0])
    for (s=[0.3,0.55,0.80]) 
        let(pu=tent_front_wall(s, tent_angle))
        let(p=pu[0], u=pu[1])
        let(z=sin(tent_angle)*dx*0.3)
        [[p[0],p[1],z],[u[1],-u[0],0]]
];
    


module _tent(tent_angle=10, round_edge_radius=1, round_edge_fn=20) {
    
    rot_orig = rot_origin();

    module case_shape() {
        translate([-126,105]) offset(r=case_rounding) shape_of_case_trimmed();
    }
    
    function scale_floor_pts(pts) = [
        for (p=pts) [rot_orig[0]+(p[0]-rot_orig[0])*cos(tent_angle),p[1]]
    ];
    
    pts=tent_pts();
    bpts=tent_bpts();
    
    module tent_shape_top_2D() {
        echo("tent_shape_top()");
        offset(case_rounding) offset(-case_rounding) hull() {
            for (p=[pts[0],pts[1]])
                translate(p) circle(bumper_hole_radius+3); 
            offset(delta=bumper_hole_radius+3) polygon(pts);
        }
    }
    
    module tent_shape_top() {
        echo("tent_shape_top()");
        hull() {
            for (p=pts)
                translate(p) torushull(r1=tent_front_wall_rounding(), r2=round_edge_radius, fn2=round_edge_fn);
        }
    }
    
    module tent_shape_bottom() {
        echo("tent_shape_bottom()");
        hull() {
            for (p=[bpts[0],bpts[1]])
                translate(p) torushull(r1=bumper_hole_radius, r2=round_edge_radius, fn2=round_edge_fn);
            for (p=pts) if (p[0] > bpts[0][0]-case_rounding)
                translate(p) torushull(r1=tent_front_wall_rounding(), r2=round_edge_radius, fn2=round_edge_fn);
        }
    }
    
    module tent_bumper_holes() {
        translate(rot_orig)
        for (p=bpts) {
            bumper_hole(p);
        }
        
        rotate(-tent_angle,[0,1,0]) translate(rot_orig) {
            translate([0,0,-bumper_height_outside])
            linear_extrude(bumper_height_outside+1) 
            for (p=bumper_hole_positions) translate(p) circle(bumper_hole_radius, $fn=30);
        }
    }
    
    module tent_magnet_holes_top() {
        rotate(-tent_angle,[0,1,0])
            translate(rot_orig)
            translate([0,0,-magnet_height])
            magnet_holes();
    }
    
    module tent_magnet_holes_front() {
        for (pu = tent_front_magnet_hole_pos(tent_angle)) {
            p = pu[0];
            u = pu[1];
            translate(p) rotate(90,u) translate([0,0,-0.1]) linear_extrude(0.1+magnet_height) circle(magnet_hole_radius, $fn=30);
        }
    }
    
    module basic_tent_shape() {        
        tbbox = bounding_box(pts);
        txmin = rot_orig[0]+tbbox[0]-bumper_hole_radius-case_rounding;
        
        hull() {
            rotate(-tent_angle,[0,1,0])
                translate(rot_orig)
                translate([0,0,-round_edge_radius])
                tent_shape_top();
            
            scale([cos(tent_angle),1,1])
                translate(rot_orig)
                translate([0,0,round_edge_radius+sin(tent_angle)*txmin*0.5])
                tent_shape_top();
            
            scale([cos(tent_angle),1,1])
                translate(rot_orig)
                translate([0,0,round_edge_radius])
                tent_shape_bottom();
        }
    }
    
    difference() {
        basic_tent_shape();

        color("blue") tent_bumper_holes();
        color("purple") tent_magnet_holes_top();
        color("purple") tent_magnet_holes_front();
        
        %color("red") rotate(-tent_angle,[0,1,0]) translate(rot_orig) for (p=bpts) bumper_hole(p);
    }
}

tent(build=true);
