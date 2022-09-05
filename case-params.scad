case_name = "LPTM";
case_version = "v0.11";

version_str = str("Corne ",case_name," ",case_version);

case_fn = 0;
case_fa = 0;
case_fs = 0;

//$fs = 1.0;


floor_thickness = 2;
switch_socket_height = 1.9; // 1.85+-0.1
pcb_height = 1.9;
pcb_thickness = switch_socket_height + pcb_height;
key_h0 = 3;
key_h1 = 3; // bottom (flat) part of key switch to bottom of key cap when depressed (including sufficent gap)
promicro_height = 8;
lcd_height = 2.5;
text_emboss_depth = 0.5;
text_fn = 16;
text_fa = 3;
case_height = floor_thickness+pcb_thickness+key_h1;
pcb_top = floor_thickness + pcb_thickness;
pcb_bottom = floor_thickness + switch_socket_height;
key_holes_height = case_height;
pcb_offset=0.8;
mcu_box_ceiling_thickness = 1; // min thickness of top of mcu box (around LCD screen)
magnet_hole_radius=3 + 0.03; // 6mm diameter + buffer
magnet_hole_height=0.5; // distance from bottom of case to bottom of magnet
magnet_height = 2;
bumper_hole_radius=4.15;
bumper_height_inside=1;
bumper_height_outside=1;

case_rounding=case_height/2;

tent_angle=10;
