material_thickness = 3.175; // 0.25 in

// azteeg dimensions
x3_board_width = 110;
x3_board_height = 72.55;
mounthole_to_edge = 2.30;
mounthole_radius = 3.80 / 2;

slot_width = material_thickness;

border = 9;
base_width  = x3_board_width + slot_width * 2;
base_height = x3_board_height + slot_width * 2;
side_height = 28.5; // 3mm spacer + 1.5mm board + 24mm board height
bottom_spacer = 4.5; // 3mm spacer + 1.5mm of board thickness

lr_slot_height = base_height/4;
tb_slot_height = base_width/4;

$fn = 100;


module rounded_square(width, height, radius) {
  x = width - radius * 2;
  y = height - radius * 2;
  minkowski() {
    square([x, y], center = true);
    circle(radius, $fn = 100);
  }
}

module base_holes() {
  union() {
    for(x = [-1, 1]) {
      // wall slots
      translate([x * (base_width/2 - slot_width/2), 0])
        square([slot_width, lr_slot_height], center = true);
      translate([0, x * (base_height/2 - slot_width/2)])
        square([tb_slot_height, slot_width], center = true);

      // mount holes
      for (y = [-1, 1]) {
        translate([x * (x3_board_width/2  - mounthole_radius - mounthole_to_edge), 
                   y * (x3_board_height/2 - mounthole_radius - mounthole_to_edge)])
          circle(mounthole_radius);
      }
    }
  }
}

module lr_base() {
  width = x3_board_height + slot_width*2;
  height = side_height;
  difference() {
    union() {
      square([width, height], center = true);
      // wall tabs
      for (y = [-1, 1]) {
        translate([0, y * (side_height/2 + slot_width/2)])
          square([lr_slot_height, slot_width], center = true);
      }
    }
    // side wall slots
    for (x = [-1, 1]) {
      translate([x * (-width/2 + slot_width/2), 0])
        square([slot_width, side_height/3], center = true);
    }
  }
}

module tb_base() {
  width = x3_board_width;
  height = side_height;
  union() {
    square([width, height], center = true);
    // wall tabs
    for (y = [-1, 1]) {
      translate([0, y * (height/2 + slot_width/2)])
        square([tb_slot_height, slot_width], center = true);
    }
  }
  // side wall tabs
  for (x = [-1, 1]) {
    translate([x * (width/2 + slot_width/2), 0])
      square([slot_width, side_height/3], center = true);
  }
}


module top() {
  width = base_width + border;
  height = base_height + border;

  difference() {
    rounded_square(width, height, 2);
    base_holes();
    
    // translate the coords (0,0) to bottom left
    translate([-x3_board_width/2, -x3_board_height/2]) {
      // power connector holes
      translate([5.3, 43.5]) square([6.5, 17.5]);
      // hot end
      translate([4.3, 8.7]) square([5.5, 30.6]);
      translate([13.6, 22.8]) square([3.9, 14.0]);
      // aux in
      translate([9.0, 65.5]) square([7.4, 3.9]);
      // endstop min and max
      translate([25.7, 3.2]) square([24.6, 7.9]);
      // low power switch
      translate([71.5, 1]) square([12.9, 8.7]);
      // thermistor
      translate([83.9, 3.2]) square([16.8, 3.3]);
      // stepper motors
      translate([24.0, 64.7]) square([76.8, 3.9]);
      // icsp
      translate([103.5, 46.5]) square([5.4, 8.4]);
      // sd
      translate([103.5, 41.2]) square([5.4, 3.6]);
    }
  }
}

module bottom() {
  margin = border + mounthole_radius * 2;
  width = base_width + margin*2 + 15;
  height = base_height + margin*2 + 15;
  difference() {
    rounded_square(width, height, 2);
    translate([width/2 - base_width/2 - margin, 0])
      base_holes();
    for (x = [-1, 1]) for (y = [-1, 1]) {
      translate([x * (width/2 - margin/2),
                 y * (height/2 - margin/2)])
        circle(mounthole_radius);
    }
  }
}

module left_side() {
  difference() {
    lr_base();

    // set (0, 0) bottom left corner, i.e top left of the board
    translate([-x3_board_height/2, -side_height/2 + bottom_spacer]) {
    //# square([base_height, 10]);
      // power
      translate([11.0, 7.2]) square([17.8, 4.1]);
      // hot ends
      translate([32.6, 2.6]) square([30.0, 4.1]);
      translate([35.0, 13.8]) square([14.6, 5.5]);
    }

  }
}

module right_side() {
  difference() {
    lr_base();

    // set (0, 0) bottom left corner, i.e top left of the board
    translate([-x3_board_height/2, -side_height/2 + bottom_spacer]) {
      // usb
      translate([15.0, 0]) square([9.1, 5.1]);
      // micro usb
      translate([26.4, 2.1]) square([12.3, 2.3]);
      // reset button
      translate([56.6, 0.8]) square([6.5, 6.5]);
    }
  }
}

module top_side() {
  difference() {
    tb_base();

    translate([-x3_board_width/2, -side_height/2 + bottom_spacer]) {
      // end stop min
      translate([25.9, 0.5]) square([25.8, 4.0]);
      // thermistors
      translate([83.4, 0.5]) square([17.9, 4.0]);
    }
  }
}

module bottom_side() {
  difference() {
    tb_base();

    //
    translate([-x3_board_width/2, -side_height/2 + bottom_spacer]) {
      // stepper motors
      translate([7.8, 0.2]) square([78.8, 4.0]);
      // thermistors
      translate([93.3, 0.2]) square([7.0, 4.0]);
    }
  }
}

// translate([x_spacing, 0, 0])            panel(base_x, base_y, 1, 1, 1, 1, 7, 7);    // top

//top();
//translate([15, 106])  bottom();
//translate([82, 0])   rotate(90) left_side();
translate([120, 0])  rotate(90) right_side(); 
//translate([114, 105]) rotate(90) top_side();
//translate([152, 105]) rotate(90) bottom_side();

// top();
// translate([15, 110])  bottom();
// translate([88, 0])   rotate(90) left_side();
// translate([130, 0])  rotate(90) right_side(); 
// translate([118, 105]) rotate(90) top_side();
// translate([160, 105]) rotate(90) bottom_side();

//top();
//translate([15, 110])  bottom();
//translate([128, -26])    top_side();    
//translate([128, 14])   bottom_side(); 
//translate([140, 55])  left_side();
//translate([140, 98]) right_side();
//
