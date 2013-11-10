thickness = 5.85;
size = 45;
tab_length = 15;
level_height = 36;
led_radius = 2.5;
quadrant = (size/2-15)/2+thickness;

module side_plate(height = level_height) {
  difference() {
    union() {
      translate([thickness,0])                    square([size-thickness, height]);
      translate([thickness/2, height/2])          square([thickness, height*(15/36)], center=true); // left tab
      translate([size/2, height+thickness/2])     square([level_height*(15/36), thickness], center=true); // top tab
    }
    translate([size/2, thickness/2])              square([level_height*(15/36), thickness], center=true); // bottom tab
    translate([size-thickness/2, height/2])       square([thickness, height*(15/36)], center=true); // right tab
  }
}

/*
module side_plate() {
  difference() {
    union() {
      translate([thickness,0])                          square([size-thickness, level_height]);
      translate([thickness/2, level_height/2])          square([thickness, tab_length], center=true); // left tab
      translate([size/2, level_height+thickness/2])     square([tab_length, thickness], center=true); // top tab
    }
    translate([size/2, thickness/2])                    square([tab_length, thickness], center=true); // bottom tab
    translate([size-thickness/2, level_height/2])       square([thickness, tab_length], center=true); // right tab
  }
}
*/

module last_plate(height) {
	side_plate(10+thickness);
}

module top_plate() {
  difference() {
    union() {
      translate([thickness, thickness]) square(size-thickness*2);
      tabs();
    }
    for (x=[quadrant-2, -quadrant+2]) for (y=[quadrant-2, -quadrant+2]) {
      translate([size/2+x, size/2+y]) led_pinout();
    }
  }
}

module bottom_plate() {
  difference() {
    square(size);
    tabs();
    for (x=[quadrant-2, -quadrant+2]) for (y=[quadrant-2, -quadrant+2]) {
      translate([size/2+x, size/2+y]) led_pinout();
    }
  }
}

module tabs() {
  for(y=[thickness/2, size-thickness/2]) {
    translate([size/2, y])      square([tab_length, thickness], center=true);
  }
  for(x=[thickness/2, size-thickness/2]) {
    translate([x, size/2])      square([thickness, tab_length], center=true);
  }
}

module led_pinout() {
  for (x=[-1,1]) for (y=[-1,1]) {
    translate([x*led_radius+x, y*led_radius+y]) circle(0.48, $fn=12);
  }
  circle(led_radius, $fn=20);
}

// translate([0,size+5])   top_plate();
// translate([size+5, 0])  side_plate();
//                         bottom_plate();
top_plate();
//translate([size+1,0])   bottom_plate();
translate([size+1, 0]) last_plate();
translate([size+1, 10+thickness]) last_plate();
translate([-size-1, 0]) last_plate();
