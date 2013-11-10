// side view     http://i.imgur.com/SebDrlT.jpg
// side view     http://i.imgur.com/KTkSMzJ.jpg
// diagonal view http://i.imgur.com/Glkl5wg.jpg
// measurements  http://i.imgur.com/4EWnrBd.jpg

width = 3.2;
height = 0.9;
c1 = 0.6;
c2 = 0.525;

cube([width - c1 - c2, 0.65, height], center = true);
translate([-width/2 + c1, 0, 0]) {
  //cylinder(r = c1, h = height, center = true, $fn = 100);
  for(i = [-height/4 + height/8 : height/4 : height/2 - height/8])
    translate([0, 0, i])
      cylinder(r2 = c1, r1 = c1 - 0.1, h = height/4, center = true, $fn = 100);
  translate([0, 0, -height/4 - height/8]) {
    cylinder(r = c1 - 0.1, h = height/4, center = true, $fn = 100);
    rotate_extrude($fn = 100)
      translate([c1 - height/8, 0, 0])
        circle(r = height/8, $fn = 100);
  }
}
translate([width/2 - c2, 0, 0])
  cylinder(r = c2, h = height, center = true, $fn = 100);
