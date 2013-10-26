material_thickness = 10;

teeth_depth = material_thickness;

base_x = 100;
base_y = 200;
base_z = 100;

padding = 5;

module teeth(length, teeth_width = 10) {
  // teeth width is rounded down
  length =  length - 2*teeth_depth;
  length = floor((length) / teeth_width) * teeth_width;
  for (x=[-length/2 : teeth_width * 2 : length/2]) translate([x + teeth_width/2, 0])
    square([teeth_width, teeth_depth], center = true);
}

module reverse_teeth(length, teeth_width = 10) {
  difference() {
    square([length, teeth_depth], center = true);
    teeth(length, teeth_width);
  }
}

module panel(width, height, top = 0, right = 0, bottom = 0, left = 0) {
  difference() {
    square([width, height], center = true);
    // top, right, bottom, left. 1 is reverse, 0 is normal
    for(i = [[top,    width, [0,  height/2 - teeth_depth/2], 0],
             [bottom, width, [0, -height/2 + teeth_depth/2], 0],
             [left,   height, [-width/2 + teeth_depth/2, 0], 90],
             [right,  height, [ width/2 - teeth_depth/2, 0], 90]]) {
      translate(i[2]) rotate([0, 0, i[3]]) {
        if(i[0] == 0) { teeth(i[1]); }
        else          { reverse_teeth(i[1]); }
      }
    }
  }
}

x_spacing = base_x + padding;
y_spacing = base_y + padding;
z_spacing = base_z + padding;
xy_spacing = base_x/2 + base_y/2 + padding;
yz_spacing = base_y/2 + base_z/2 + padding;
                                        panel(base_x, base_y);                // top
translate([x_spacing, 0, 0])            panel(base_x, base_y, 1, 1, 1, 1);    // bottom
translate([0, yz_spacing, 0]) {
                                        panel(base_x, base_z, 1, 0, 1, 0);    // side
  translate([0, 1*z_spacing, 0])        panel(base_x, base_z, 1, 0, 1, 0);    // side
  translate([xy_spacing, 0, 0])         panel(base_y, base_z, 1, 0, 1, 0);    // side
  translate([xy_spacing, z_spacing, 0]) panel(base_y, base_z, 1, 0, 1, 0);    // side
}