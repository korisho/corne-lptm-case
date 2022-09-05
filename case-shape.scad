include <common.scad>
include <case-params.scad>


has_lcd = false;
has_version_top = false;
has_version_bottom = false;
has_trrs_hole = false;

no_lcd_dh = 1;
mcu_box_top = pcb_top + promicro_height+(has_lcd ? lcd_height : no_lcd_dh)+mcu_box_ceiling_thickness;

function case_total_height() = mcu_box_top;

module shape_of_case_trimmed() {

    module case_trim(dx=2,dy=2) {
        translate(promicro_position+[
            -promicro_dimension[0]/2,
            promicro_dimension[1]/2-dy
        ])
        square(promicro_dimension+[20,0], center=false);

        translate(promicro_position+[
            promicro_dimension[0]/2-dx,
            -promicro_dimension[1]/2-50,
        ])
        square(promicro_dimension+[0,70], center=false);
    }

    difference() {
        shape_of_case();
        case_trim();
    }
}

module basic_shape_of_case(build=false) { // make me
  if (!build) {
    import("stl/basic_shape_of_case.stl");
  }
  else {

    rad=case_rounding;

    minkowski($fn=30)
    {
        union() {
            translate([ 0, 0, rad ]) linear_extrude(height = max(0.0001, case_height-rad*2))
                offset(max(0,3-rad)) shape_of_case_trimmed();

            ext=max(0.0001, mcu_box_top-rad*2);
            echo("ext=",ext);
            translate([ 0, 0, rad ]) linear_extrude(height = ext)
                offset(delta=max(0,3-rad))
                intersection() {
                    translate([rad,rad,0]) mcu_box_space();
                    shape_of_case_trimmed();
                }
        }

        sphere(r=rad);
    }
  }    
}

module screw_pillar() {
    cylinder(pcb_thickness, r=2);
    cylinder(switch_socket_height, r=3);
}

module screw_hole() {
    cylinder(1.5, r1=3, r2=1);
    cylinder(pcb_top+key_h1-1.5, r=1);
}

module screw_pillars() {
    for (loc = pcb_screw_positions) {
        translate([loc[0],loc[1],0]) screw_pillar($fn=30);
    }
}

module screw_holes() {
    for (loc = pcb_screw_positions) {
        translate([loc[0],loc[1],0]) screw_hole($fn=30);
    }
}

module pcb_support_posts() {
    linear_extrude(height = switch_socket_height)
    intersection() {
        shape_of_case();
        union() {
            for (pos = pcb_supports) {
                translate(pos) circle(2.5, $fn=30);
            }

            // support around trrs hole
            translate(trrs_position+[1,-trrs_width/2]) polygon([
                [5,-1],[0,-1],
                [-2,0.5],
                [-2,trrs_width-0.5],
                [0,trrs_width+1],
                [5,trrs_width+1]
                ]);
            
            // support around ucb-c hole
            translate(promicro_position+[0,promicro_dimension[1]/2]) square([promicro_dimension[0],5], center=true);
        }
    }
}

module key_holes()
{
    key_bottom_width = key_width + 1 + 0.25; // Kailh switches are 15mm wide (14+1), plus extra 0.25mm buffer
    key_cap_thumb_width = key_cap_width+0.8; 
    linear_extrude(height = key_holes_height) alpha_holes();
    linear_extrude(height = key_holes_height) thumb_holes();
    translate([ 0, 0, -pcb_height ]) linear_extrude(height = pcb_height+key_h0) alpha_holes(key_bottom_width);
    translate([ 0, 0, -pcb_height ]) linear_extrude(height = pcb_height+key_h0) thumb_holes(key_bottom_width,key_bottom_width);
    translate([ 0, 0, key_h1 ]) linear_extrude(height = key_holes_height) alpha_holes(key_cap_width);
    translate([ 0, 0, key_h1 ]) linear_extrude(height = key_holes_height) thumb_holes(key_cap_thumb_width, key_cap_thumb_width * 1.5);
}


module rounded_rectangle(w, h, r, center=false)
{
    module rr() {
        if (w>2*r && h>2*r) {
            offset(r=r) offset(delta=-r) square([w,h],center=false);
        }
        else { // TODO: this doesn't really work if both w>2*r and h>2*r
            translate([w/2,h/2]) {
                square([w, h-2*r], center=true);
                square([w-2*r, h], center=true);
                translate([r-w/2, h/2-r,0]) circle(r);
                translate([r-w/2, r-h/2,0]) circle(r);
                translate([w/2-r, r-h/2,0]) circle(r);
                translate([w/2-r, h/2-r,0]) circle(r);
            }
        }
    }
    
    if (center) {
        translate([-w/2,-h/2]) rr();
    }
    else {
        rr();
    }
}

module mcu_plug_hole() {
    w=14;h=8.5;
    translate([promicro_plug_position[0],promicro_plug_position[1],promicro_height-h/2]) 
    rotate([-90,0,0]) linear_extrude(promicro_plug_dimension[1], scale=1.3, center=false) rounded_rectangle(w,h,h/2, center=true, $fn=30);
    linear_extrude(height = promicro_height-h/3) promicro_plug_space();
}

module pcb_cover_screw_holes() {
    // screw holes to reinforce MCU box
    screw_length=pcb_thickness+(mcu_box_top-pcb_top-case_rounding)*0.75;
    translate([0,0,-pcb_thickness+0.01])
    linear_extrude(screw_length-0.01)
    for (pos=pcb_cover_screw_positions) {
        translate(pos) circle(r=pcb_cover_screw_radius, $fn=30);
    }
}

module mcu_hole()
{
    top_hole_height=promicro_height+(has_lcd ? lcd_height : 0);
    if (has_lcd) {
        translate([ 0, 0, top_hole_height-0.1]) linear_extrude(height = 5) lcd_view_hole();
        translate([ 0, 0, -pcb_height ]) linear_extrude(height = pcb_height+promicro_height+lcd_height) lcd_hole();
    }
    
    translate([ 0, 0, -pcb_height ]) linear_extrude(height = pcb_height+promicro_height-0.5) difference() {
        offset(r=1, $fn=30) offset(delta=-1) promicro_ext_space();
        // reinforce weak spot near plug hole on key-side
        translate(promicro_position+[-promicro_dimension[0],promicro_dimension[1]]/2+[0.5,0]) scale([1,1.5]) circle(2, $fn=30);
        translate(promicro_position+[ promicro_dimension[0],promicro_dimension[1]]/2-[0.5,0]) scale([1,1.5]) circle(2, $fn=30);
    }

    mcu_plug_hole();

    if (has_trrs_hole) {
      translate([trrs_position[0],trrs_position[1],trrs_height/2]) rotate([0,90,0]) linear_extrude(10, scale=1.5) circle(r=trrs_height/2+0.3, $fn=30);
      translate([trrs_position[0]+2,trrs_position[1],trrs_height/2]) rotate([0,90,0]) linear_extrude(10, scale=1.5) circle(r=trrs_height/2+1, $fn=30);
      translate([ 3, 0, trrs_height/4]) linear_extrude(height = trrs_height/4) trrs_hole();
      translate([ 0, 0, -0.01 ]) linear_extrude(height = trrs_height+0.5) trrs_hole();
    }

    translate([reset_button_position[0], reset_button_position[1], -0.001]) {
        linear_extrude(top_hole_height+5) circle(0.75, $fn=15);
        linear_extrude(4) square([5,9],center=true);
    }

    pcb_cover_screw_holes();
}

module power_switch_hole1() {
    sh=1.5;
    h=2;
    w=7;
    d=1;
    wt=1.5;
    translate([163,-61,0]) {
        translate([0,0,sh]) cube([w,d,h],center=false);
        translate([1,0,0])  cube([w-2,d,pcb_bottom+0.01],center=false);
        translate([1,-0.5,0]) trapezoid(d1=[w-2,d+1],d2=[w-2,d],h=1);
    }
    translate([163,-61,floor_thickness-0.001]) linear_extrude(pcb_thickness) {
        translate([0.5,-3,0]) square([12+wt,wt]);
        translate([11.9,-8+wt,0]) square([wt,3.2+wt]);
        translate([0.5,-3,0]) square([wt,2.4+wt]);
        
        translate([6.5-wt,-3+wt,0]) square([8.4+wt,wt]);
        translate([14.9-wt,-8+wt,0]) square([wt,5+wt]);
        translate([6.5-wt,-1.5,0]) square([wt,1+wt]);
    }
}


module power_switch_hole() {
    h=1.5;
    w=7;
    d=2.75;

    translate([promicro_plug_position[0]-w/2,promicro_plug_position[1]-d, pcb_bottom-h]) {
        cube([w,d,h], center=false);
        translate([w/2,d,h/2]) rotate([-90,0,0]) linear_extrude(5,scale=2) square([w-2,h],center=true);
    }
}

module power_switch_support() {
    h=1.5;
    w=7;
    d=2.75;
    hd=0.5;
    wd=2;
    dd=2;
    kd=1;
    
    translate([promicro_plug_position[0]-w/2,promicro_plug_position[1]-d, pcb_bottom-h]) {
        difference() {
            translate([-wd/2,-dd/2,h-switch_socket_height]) cube([w+wd,d+dd,switch_socket_height-hd], center=false);
            translate([kd/2,-dd,0]) cube([w-kd,d+dd,h], center=false);
        }
    }
}

module power_switch_case_split() {
    translate([0,0,floor_thickness])
    linear_extrude(height = pcb_bottom-floor_thickness)difference() {
        translate([160,-68,0]) square([20,15]);
        offset(pcb_offset) shape_of_pcb();
    }
}

module emboss_text(vstr, size=3, height=text_emboss_depth, halign="center", font="courier:style=Bold")
{
    color("red")
    linear_extrude(height = height)
        text(vstr, size=size, font=font, halign=halign, valign="center", $fn=text_fn, $fa=text_fa);
}

module version_embossing() {
    if (has_version_bottom) {
        translate([ 170, -114, floor_thickness-text_emboss_depth ]) rotate([0,0,90]) emboss_text("Corne", size=4.5, halign="left");
        translate([ 176, -114, floor_thickness-text_emboss_depth ]) rotate([0,0,90]) emboss_text(str(case_name," ",case_version), size=4.5, halign="left");
    }
    
    if (has_version_top) {
        translate([ 180, -150, pcb_top ]) rotate(150,[0,0,1]) emboss_text(case_name, size=4.5, halign="left");
        translate([ 190.5, -129, pcb_top ]) rotate(150,[0,0,1]) emboss_text(case_version, size=4.5, halign="left");
    }
}

module bumper_hole(pos) {
    delta=bumper_height_outside/4;
    translate(pos) translate([0,0,-delta])
        linear_extrude(bumper_height_inside+delta)
        circle(bumper_hole_radius, $fn=30);
}

module case_bumper_holes() {
    for (pos = bumper_hole_positions) {
        bumper_hole(pos);
    }
}

module bumper() {
    difference() { 
        scale([1,1,(bumper_height_inside+bumper_height_outside)/bumper_hole_radius]) sphere(bumper_hole_radius, $fn=20); 
        translate([0,0,bumper_hole_radius+1]) cube((bumper_hole_radius+1)*2, center=true);
    }
}

module case_bumpers() {
    translate([0,0,bumper_height_inside]) for (p=bumper_hole_positions) translate(p) bumper();
}

module magnet_holes() {
    linear_extrude(floor_thickness-magnet_hole_height+switch_socket_height/2)
    for (pos = magnet_hole_positions) {
        translate(pos) circle(magnet_hole_radius, $fn=30);
    }
}

module case_uncut(build=false) // make me
{
    difference()
    {
        basic_shape_of_case(build);
        difference() {
            union() {
                translate([ 0, 0, floor_thickness ]) linear_extrude(height = pcb_thickness)
                    intersection() {
                        shape_of_pcb();
                        translate([-0.5,0]) shape_of_pcb();
                    }
                translate([ 0, 0, floor_thickness+switch_socket_height]) linear_extrude(height = pcb_height)
                    offset(pcb_offset) shape_of_pcb();
            }
            translate([ 0, 0, floor_thickness ]) screw_pillars();
            translate([ 0, 0, floor_thickness ]) pcb_support_posts();
            //translate([ 0, 0, 0 ]) power_switch_support();
        }
        translate([ 0, 0, pcb_top ]) key_holes();
        translate([ 0, 0, 0 ]) screw_holes();
        translate([ 0, 0, 0 ]) case_bumper_holes();
        translate([ 0, 0, magnet_hole_height ]) magnet_holes();
        translate([ 0, 0, pcb_top ]) mcu_hole();
        //translate([ 0, 0, 0 ]) power_switch_hole();

        version_embossing();
    }
}

module case_split_cut(delta=0)
{
    union()
    {
        difference() {
            linear_extrude(height = pcb_bottom) offset(delta) offset(r=1, $fn=30) offset(delta=-1) offset(pcb_offset/2) shape_of_case();
            //power_switch_case_split();
        }
        if (has_trrs_hole) {
          linear_extrude(height = floor_thickness + pcb_thickness+trrs_height/2) offset(delta) trrs_plug_space();
        }
        //linear_extrude(height = floor_thickness + promicro_height) offset(delta) promicro_plug_space();
    }
}

module case(build=false) { // make me
  if (!build) {
      import("stl/case.stl");
  }
  else {
    //mirror(v=[1,0,0])
    translate([-127,105,0]) {
        case_cut_offset=0.2;
        translate([0, -55, 0]) intersection() { case_uncut(); case_split_cut(delta=-case_cut_offset); } // bottom
        translate([0,  55, 0]) difference()   { case_uncut(); case_split_cut(); } // top
    }
  }
}

case(build=true);

%translate([-200,0,0]) difference() {
    case(build=true);
    translate([60,10,-10]) cube([20,100,50]);
}
