material_thickness = 3.175;
led_separation = 36;
led_radius = 2.5;
teeth_width = material_thickness;

base_size = led_separation*4 + 8.5;
base_height = 65; 

arduino_displacement = 25;
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

module base(reverse = 0, cut_corner = 1) {
  difference() {
    square(base_size, center=true);

    for (deg=[0 : 90 : 359]) rotate([0, 0, deg]) 
      translate([base_size/2-teeth_width/2, 0])
        teeth(reverse=reverse, cut_corner = cut_corner);
  }
}

module bottom() {
  m3_radius = 2.55 / 2;
  difference() {
    base(reverse = 1, cut_corner = 0);
    
    translate([0, arduino_displacement, 0])
    // translated to bottom left corner
    translate([-base_size/2 + teeth_width + m3_radius, -base_size/2 + teeth_width + 3.175/2, 0]) {
      // holes to attach arduino uno.
      for( i = [[15.24, 50.8],
                [66.04, 35.56],
                [66.04, 7.62],
                [13.97, 2.54]]) {
        translate(i) circle(m3_radius, $fs = 0.2, center = true);
      }
    }
  }
}

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
        if (deg <= 90) {
          //translate([-teeth_width/2, 0, 0]) scale([2, 1, 1]) teeth(reverse = 1, cut_corner = 0);
          teeth(reverse = 1, cut_corner = 0);
        }
        else           { teeth(); }
    // sides
    for (deg=[0, 180]) rotate([0, 0, deg]) 
      translate([base_size/2-teeth_width/2, 0])
        if (deg <= 0) { teeth(base_height, 5); }
        else          { teeth(base_height, 5, 1); }
  }
}

module arduino() {
  pcb_thickness = 1.6;
  scale_margin = 1.1;
  difference() {
    side();
    
    
    // arduino uno dimensions:
    // http://www.wayneandlayne.com/blog/2010/12/19/nice-drawings-of-the-arduino-uno-and-mega-2560/
    // distance edge to edge, from usb-b to dc is 20.32 (0.8 in)
    // size of usb-b shield is 11.43 (0.45 in)
    // size of dc adapter is 8.89 (0.35 in)
    // therefore, distance center to center is 30.48 (1.2 in)
    
    translate([-arduino_displacement-1, 5, 0])
    // translated to the bottom right corner
    translate([base_size/2 - teeth_width, -base_height/2 + teeth_width, 0])
      translate([-38.1, pcb_thickness + 1.45 + 7.26/2, 0]) {
        // usb-b
        // http://www.usb.org/developers/docs/ecn1.pdf pg 20
        square([11.75, 11.01], center = true);
        /*
        scale(scale_margin) difference() {
          square([8.0, 7.26], center = true);
          translate([ 4, 2.16, 0]) rotate([0, 0, 45]) square(1.46 * sqrt(2));
          translate([-4, 2.16, 0]) rotate([0, 0, 45]) square(1.46 * sqrt(2));
        }
        */
        // dc hole
        // http://www.cui.com/product/resource/pj-006a-smt.pdf
        translate([29.78, 3.15 - 2.03, 0])
          scale(scale_margin) circle(6.3/2, $fs = 0.2, center = true);
      }
  }
}

arduino();
/*
for (i=[0:2]) {
  translate([-base_size-2, base_size/2 - base_height/2 - i*(base_height+2)]) side();
}
translate([base_size+2, 0]) bottom();
top();
*/