teeth_depth = 3.175;

module teeth(length, teeth_width = 10) {
  // teeth width is rounded down
  length = length - 2*teeth_depth;
  teeth_count = floor(((length/teeth_width)-1) / 2) * 2 + 1;
  teeth_width = length / teeth_count;
  echo (length, teeth_count, teeth_width);
  for (x=[-length/2 : teeth_width * 2 : length/2]) translate([x + teeth_width/2, 0])
    square([teeth_width, teeth_depth], center = true);
}

module reverse_teeth(length, teeth_width = 10) {
  difference() {
    square([length, teeth_depth], center = true);
    //translate([-length/2 + teeth_depth/2, 0, 0]) square(teeth_depth, center = true);
    teeth(length, teeth_width);
  }
}

module panel(width, height, top = 0, right = 0, bottom = 0, left = 0, w_teeth = 10, h_teeth = 10) {
  x_corner = (width-teeth_depth)/2;
  y_corner = (height-teeth_depth)/2;
  difference() {  // subtracting some of the four corners
    union() {     // adding the four corners
      difference() {
        square([width, height], center = true);
        
        // top, right, bottom, left. 1 is reverse, 0 is normal
        for(i = [[top,    width,  w_teeth, [0,  height/2 - teeth_depth/2], 0],
                 [bottom, width,  w_teeth, [0, -height/2 + teeth_depth/2], 0],
                 [left,   height, h_teeth, [-width/2 + teeth_depth/2, 0], 90],
                 [right,  height, h_teeth, [ width/2 - teeth_depth/2, 0], 90]]) {
          translate(i[3]) rotate([0, 0, i[4]]) {
            if(i[0] == 0) { teeth(i[1], i[2]); }
            else          { reverse_teeth(i[1], i[2]); }
          }
        }
      }

      // the four corners
      for (x=[-1, 1]) for (y=[-1, 1]) {
        translate([x*x_corner, y*y_corner])
          square(teeth_depth, center = true);
      }
    }

    // brute force. me no likey
    if (top == 0 && right == 0) 
      translate([x_corner, y_corner]) square(teeth_depth, center = true);
    if (bottom == 0 && right == 0) 
      translate([x_corner, -y_corner]) square(teeth_depth, center = true);
    if (bottom == 0 && left == 0) 
      translate([-x_corner, -y_corner]) square(teeth_depth, center = true);
    if (top == 0 && left == 0) 
      translate([-x_corner, y_corner]) square(teeth_depth, center = true);
  }
    
}

module show_all() {
  base_x = 152.5;
  base_y = 152.5;
  base_z = 152.5;
  padding = 5;

  x_spacing = base_x + padding;
  y_spacing = base_y + padding;
  z_spacing = base_z + padding;
  xy_spacing = base_x/2 + base_y/2 + padding;
  yz_spacing = base_y/2 + base_z/2 + padding;
                                          panel(base_x, base_y, h_teeth = 7, w_teeth = 7);                // bottom
  translate([x_spacing, 0, 0])            panel(base_x, base_y, 1, 1, 1, 1, 7, 7);    // top
  //translate([0, yz_spacing, 0]) {
  //                                        panel(base_x, base_z, 0, 1, 1, 0, 7, 7);    // side
  //  translate([0, 1*z_spacing, 0])        panel(base_x, base_z, 0, 1, 1, 0, 7, 7);    // side
  //  translate([xy_spacing, 0, 0])         panel(base_y, base_z, 0, 1, 1, 0, 7, 7);    // side
  //  translate([xy_spacing, z_spacing, 0]) panel(base_y, base_z, 0, 1, 1, 0, 7, 7);    // side
  //}
}
show_all();
