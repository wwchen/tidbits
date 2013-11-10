material_thickness = 4.8;
led_separation = 36;
led_radius = 2.5;

teeth_width = material_thickness;

base_size = led_separation*4 + 22;
base_height = 50; 

module led_pinout() {
  for (x=[-1,1]) for (y=[-1,1]) {
    translate([x*led_radius+x, y*led_radius+y]) circle(0.48, $fn=15, center=true);
  }
}

module teeth(length = base_size, teeth_count = 19, reverse = 0, cut_corner = 1) {
  length = length - 2*teeth_width;
  teeth_height = length / teeth_count;
  range = (length-teeth_height)/2 - reverse*teeth_height;
  //#square([teeth_width, length], center = true);
  // the middle teeth
  for (y=[-range : teeth_height*2 : range]) translate([0, y])
    square([teeth_width, teeth_height], center = true);
  // the corner teeth
  if (cut_corner == 1) {
    translate([0, (length+teeth_width)/2])
      square(teeth_width, center = true);
  }
}

module reverse_teeth() {
}

module base(reverse = 0, cut_corner = 1) {
  difference() {
    square(base_size, center=true);

    for (deg=[0 : 90 : 359]) rotate([0, 0, deg]) 
      translate([base_size/2-teeth_width/2, 0])
        teeth(reverse=reverse, cut_corner = cut_corner);
  }
}

module bottom() { base(reverse = 1, cut_corner = 0); }
module top() {
  difference() {
    base();
    for (x=[-2.5 : 1 : 2.5]) for (y=[-2.5 : 1 : 2.5]) {
      translate([x*led_separation, y*led_separation]) led_pinout();
    }
  }
}

module side() {
  difference() {
    square([base_size, base_height], center = true);
    // top and bottom
    for (deg=[90, 270]) rotate([0, 0, deg]) 
      translate([base_height/2-teeth_width/2, 0])
        if (deg <= 90) { teeth(reverse = 1, cut_corner = 0); }
        else           { teeth(); }
    // sides
    for (deg=[0, 180]) rotate([0, 0, deg]) 
      translate([base_size/2-teeth_width/2, 0])
        if (deg <= 0) { teeth(base_height, 5); }
        else          { teeth(base_height, 5, 1); }
  }
}


for (i=[0:3]) {
  translate([-base_size-2, base_size/2 - base_height/2 - i*(base_height+2)]) side();
}
translate([base_size+2, 0]) bottom();
top();
