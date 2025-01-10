/* 
 *  Classic Plastic Cup 3D Model © 2025 by Chad Kouse is licensed under CC BY-NC 4.0 
 *  Source: https://github.com/chadkouse/scadfiles
*/

//get the BOSL2 library here
// https://github.com/BelfrySCAD/BOSL2
// from BelfrySCAD - many contributors (THANK YOU)
include <BOSL2/std.scad>

// get the recycling symbol library here
// https://www.printables.com/model/136201-recymbol-customizable-recycling-symbols-and-librar/files
// from Xavier Faraudo (THANK YOU)
include <shapes/recycling_symbol.scad>

// variables that control shape smoothness
$fa= $preview ? 12 : 1;
$fs = $preview ? 1 : 0.25;

// variable to extend difference cutouts so they look properly in preview
// issue: https://github.com/openscad/openscad/issues/1409
// you can set to 0 when you render if you want.
face_diff = .001;
function get_diff_z(z) = ($preview ? (z-face_diff) : z);
function get_diff_h(h) = ($preview ? (h + (2*face_diff)) : h);

// measurements all done with metric calipers
// layer naming goes bottom to top
// bottom layer is A
// next layer is B
// after that comes 11 ribs
// above the ribs is layer C
// then the top ring

main_height = 116.5; //total height of the cup
main_top_diameter = 92.25; // diameter of top of the cup
main_top_radius = main_top_diameter/2;

// diameter of the bottom of LAYER B (not the whole cup)
// we only want to compute the angle from the bottom
// of layer B to the top of the cup
main_bottom_diameter = 65.5;
main_bottom_radius = main_bottom_diameter/2;
// ratio of top to bottom so we can calculate the angle for any z
main_radius_diff = main_top_radius - main_bottom_radius;

// thickness of the walls
// walls grow towards the center of the cup so 
// this doesn't affect the overall width of the cup
wall_thickness = 2.5;

layer_a_top_diameter=62.5; // diameter of the top of layer A
layer_a_top_radius=layer_a_top_diameter/2;
layer_a_bottom_diameter = 63.4; // diameter of the bottom of the cup / Layer A
layer_a_bottom_radius=layer_a_bottom_diameter/2;
layer_a_height=8; // total height of layer A
layer_a_bottom_ring_push_in=8.1; // the amount to inset the bottom bump in the cup
layer_a_bottom_ring_top_radius= layer_a_top_radius-layer_a_bottom_ring_push_in;
layer_a_bottom_ring_bottom_radius= layer_a_bottom_radius-layer_a_bottom_ring_push_in;
layer_a_bottom_ring_height = 3;

//layer A "bumps" around the bottom rim
bump_radius = 5.6;
bump_offset = 1.1;
bump_height = layer_a_height-1.5;

layer_b_bottom_diameter=main_bottom_diameter;
layer_b_bottom_radius=layer_b_bottom_diameter/2;
layer_b_top_diameter=72.5;
layer_b_top_radius=layer_b_top_diameter/2;
layer_b_height=25.6;

//the position to start the ribs
rib_z = layer_a_height+layer_b_height;
rib_count = 11; // number of ribs
rib_height = 5; // height of a single rib

// layer c
layer_c_z = rib_z+(rib_height*rib_count);
layer_c_height = 27.9;
layer_c_bottom_radius = get_main_radius(layer_c_z);

// Maximum width of the recycling symbol (x-axis).
Symbol_width = 20; // [8:0.5:40]
// Maximum depth of the recycling symbol (y-axis).
Symbol_depth = 30; // [10: 0.5: 50]
// Height of the recycling symbol (z-axis).
Symbol_height = 3; // [0.05: 0.05: 5]
Symbol_Text = "PLA";
Symbol_Code = "10";
Symbol_Font = "Liberation Sans";

// function to calculate the radius of any slice of the cup
// from the bottom of layer B to the top of the cup.
function get_main_radius(z) = ((((z/(main_height-layer_a_height))*main_radius_diff)+main_bottom_radius));

// layer A
difference() {
  group() {
    cylinder(r=layer_a_bottom_radius, r2=layer_a_top_radius, h=layer_a_height, center=false);
    translate([0, layer_a_bottom_radius-bump_radius+bump_offset, 2]) {
      cyl(r=bump_radius-1, h=bump_height, rounding=0.5, center=false);
    }

    translate([0, -(layer_a_bottom_radius-bump_radius+bump_offset), 2]) {
      cyl(r=bump_radius-1, h=bump_height, rounding=0.5, center=false);
    }

    translate([(layer_a_bottom_radius-bump_radius+bump_offset), 0, 2]) {
      cyl(r=bump_radius-1, h=bump_height, rounding=0.5, center=false);
    }

    translate([-(layer_a_bottom_radius-bump_radius+bump_offset), 0, 2]) {
      cyl(r=bump_radius-1, h=bump_height, rounding=0.5, center=false);
    }

  }

  group() {
    translate([0, 0, get_diff_z(0)]) {
      cylinder(r=(layer_a_bottom_ring_top_radius), r2=(layer_a_bottom_ring_bottom_radius-2), h=get_diff_h(layer_a_bottom_ring_height));
    }
    translate([0, 0, get_diff_z(layer_a_height)]) {
      cylinder(r=(layer_b_bottom_radius-wall_thickness), r2=(layer_b_top_radius-wall_thickness), h=get_diff_h(layer_a_height+bump_height));
    }

  }
  
}

// layer A bottom ring with inset recycling symbol
difference() {
  group() {
    translate([0, 0, layer_a_height]) {
      cylinder(r=(layer_a_bottom_ring_top_radius), r2=(layer_a_bottom_ring_bottom_radius-2), h=layer_a_bottom_ring_height);
    }

    translate([0, 0, layer_a_height]) {
      cylinder(r=(layer_a_bottom_ring_top_radius), r2=(layer_a_bottom_ring_bottom_radius-2), h=layer_a_bottom_ring_height);
    }
  }
  group() {
    inner_size = [Symbol_width, Symbol_depth, get_diff_h(8)];

    translate([0, 0, get_diff_z(layer_a_height+4)]) {
      recymbol( text = Symbol_Text, size = inner_size, code = Symbol_Code, use_single_digit = false,
          offset = 0, text_offset = 0, code_offset = 0,
          arrow_offset = 0, triangle = false, font = Symbol_Font, flip = false );
    }
  }
}

// recycling symbol on the bottom of the cup
outer_size = [Symbol_width, Symbol_depth, Symbol_height];

translate([0, 0, layer_a_height-5.5]) {
  recymbol( text = Symbol_Text, size = outer_size, code = Symbol_Code, use_single_digit = true,
      offset = 0, text_offset = 0, code_offset = 0,
      arrow_offset = 0, triangle = false, font = Symbol_Font, flip = true );
}



// layer B
difference() {
  group() {
    translate([0, 0, layer_a_height]) {
      cyl(r=layer_b_bottom_radius, r2=layer_b_top_radius, h=layer_b_height, center=false, rounding1=1);
    }
  }
  translate([0, 0, get_diff_z(layer_a_height)]) {
    cylinder(r=(layer_b_bottom_radius-wall_thickness), r2=(layer_b_top_radius-wall_thickness+.9), h=get_diff_h(layer_b_height));
  }
}

//ribs
group() {
  for (i = [0:rib_count-1]) {
    z = rib_z + (i*rib_height);

    rib_radius = get_main_radius(z);
    ellipse = xscale(1, p=circle(r=rib_radius-(wall_thickness/2)));
    if (i == 0) {
      translate([0, 0, z+3.5]) {
        path_sweep(rect([wall_thickness, rib_height+2], rounding=[1, 1, 0, 1]), path3d(ellipse), closed=true);
      }
    } else {
      translate([0, 0, z+3.5]) {
        path_sweep(rect([wall_thickness, rib_height+2], rounding=1), path3d(ellipse), closed=true);
      }
    }
  }
}

//layer C
difference() {
  group() {
      translate([0, 0, layer_c_z]) {
        cyl(r=layer_c_bottom_radius, r2=get_main_radius(layer_c_z+layer_c_height-1.5), h=layer_c_height-1.5, center=false, rounding1=1);
      }
      translate([0, 0, layer_c_z+layer_c_height-1.5]) {
        ellipse = xscale(1, p=circle(r=main_top_radius+.5));
        resize([0, 0, 3])
        path_sweep(circle(r=2.75), path3d(ellipse), closed=true);
      }
      translate([0, 0, layer_c_z+layer_c_height-5]) {
        cylinder(r=get_main_radius(layer_c_z+layer_c_height-9), r2=get_main_radius(layer_c_z+layer_c_height)+1.5, h=3);
      }

  }
  group() {
    translate([0, 0, get_diff_z(layer_c_z)]) {
      cylinder(r=(get_main_radius(layer_c_z)-wall_thickness), r2=(get_main_radius(layer_c_z+layer_c_height)-wall_thickness+.4), h=get_diff_h(layer_c_height));
    }
  }
}

