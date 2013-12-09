// side view     http://i.imgur.com/SebDrlT.jpg
// side view     http://i.imgur.com/KTkSMzJ.jpg
// diagonal view http://i.imgur.com/Glkl5wg.jpg
// measurements  http://i.imgur.com/4EWnrBd.jpg

width = 32;
height = 10;
rod_width = 6.5;
attaching_head_radius = 7;
attaching_head_min_radius = 6.2;
groove_depth = 0.8;
connector_head_radius = 5.75;

teeth_count = 4;
attaching_head_radius_step = ( attaching_head_radius - attaching_head_min_radius ) / teeth_count;

module main() {
  cube([width - attaching_head_radius - connector_head_radius, rod_width, height], center = true);
  translate([width/2 - connector_head_radius, 0, 0])
    cylinder(r = connector_head_radius, h = height, center = true, $fn = 100);
  
  translate([-width/2 + attaching_head_radius, 0, 0])
    for(i = [0 : teeth_count - 1]) {
      assign (radius      = attaching_head_radius - attaching_head_radius_step * i,
              z_translate = (height/2 - height/(teeth_count*2)) - (height/teeth_count) * i) {
        translate([0, 0, z_translate])
          cylinder(r2 = radius, r1 = radius - groove_depth, h = height/teeth_count, center = true, $fn = 100);
      }
    }
  
  /*
  intersection() {
    cylinder(r = attaching_head_radius, h = height/4, center = true, $fn = 100);
    rotate_extrude($fn = 100)
      translate([attaching_head_radius - height/8, 0, 0])
        circle(r = height/7, $fn = 100);
  }
  */
}

translate([0, 0, height/2])
  main();
