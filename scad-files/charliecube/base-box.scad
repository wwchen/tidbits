include <box.scad>

teeth_depth = 3.175;
base_size = 152.5;
base_z = 65;

led_separation = 36;
led_radius = 2.5;

arduino_displacement = 25;


module top() {
  difference() {
    panel(base_size, base_size);
    for (x=[-2.5 : 1 : 2.5]) for (y=[-2.5 : 1 : 2.5]) {
      translate([x*led_separation, y*led_separation])
        for (x=[-1,1]) for (y=[-1,1])
          translate([x*led_radius+x, y*led_radius+y]) circle(0.48, $fn=15, center=true);
    }
  }
}

module bottom() {
  m3_radius = 2.75 / 2;
  difference() {
    panel(base_size, base_size, 1, 1, 1, 1);
    
    translate([0, arduino_displacement, 0])
    // translated to bottom left corner
    translate([-base_size/2 + teeth_depth + m3_radius, -base_size/2 + teeth_depth + 3.175/2, 0]) {
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

module side() {
  panel(base_size, base_z, 1, 1, 0, 1);
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
    
    translate([-arduino_displacement, 5, 0])
    // translated to the bottom right corner
    translate([base_size/2 - teeth_depth, -base_z/2 + teeth_depth, 0])
      translate([-38.1, pcb_thickness + 1.45 + 7.26/2, 0]) {
        // usb-b
        // http://www.usb.org/developers/docs/ecn1.pdf pg 20
        scale(scale_margin) difference() {
          square([8.0, 7.26], center = true);
          translate([ 4, 2.16, 0]) rotate([0, 0, 45]) square(1.46 * sqrt(2));
          translate([-4, 2.16, 0]) rotate([0, 0, 45]) square(1.46 * sqrt(2));
        }
        // dc hole
        // http://www.cui.com/product/resource/pj-006a-smt.pdf
        translate([30.48, -0.1, 0])
          scale(scale_margin) circle(6.3/2, $fs = 0.2, center = true);
      }
  }
}

                            top();
translate([base_size+2, 0]) bottom();
for (i=[0:3])
  translate([-base_size-2, base_size/2 - base_z/2 - i*(base_z+2)]) {
    if (i==0)   arduino();
    else        side();
  }
  