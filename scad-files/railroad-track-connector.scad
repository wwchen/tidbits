// side view     http://i.imgur.com/SebDrlT.jpg
// side view     http://i.imgur.com/KTkSMzJ.jpg
// diagonal view http://i.imgur.com/Glkl5wg.jpg
// measurements  http://i.imgur.com/4EWnrBd.jpg

width = 32;
height = 9;
c1 = 6;
c1_step = 0.25;
c2 = 5.25;

cube([width - c1 - c2, 6.5, height], center = true);
translate([width/2 - c2, 0, 0])
  cylinder(r = c2, h = height, center = true, $fn = 100);

translate([-width/2 + c1, 0, 0])
  for(info = [[c1 - c1_step * 0, (height/2 - height/8) - (height/4) * 0],
              [c1 - c1_step * 1, (height/2 - height/8) - (height/4) * 1],
              [c1 - c1_step * 2, (height/2 - height/8) - (height/4) * 2],
              [c1 - c1_step * 3, (height/2 - height/8) - (height/4) * 3]]) {
    translate([0, 0, info[1]])
      cylinder(r2 = info[0], r1 = info[0] - 0.5, h = height/4, center = true, $fn = 100);
  }

      /*
      intersection() {
        cylinder(r = c1, h = height/4, center = true, $fn = 100);
        rotate_extrude($fn = 100)
          translate([c1 - height/8, 0, 0])
            circle(r = height/7, $fn = 100);
      }
      */
