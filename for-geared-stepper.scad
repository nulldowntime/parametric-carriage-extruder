include <util.scad>
include <config.scad>

idler_shaft_support   = 4;

filament_opening = filament_diam + 1;

plate_thickness = motor_shoulder_height;
plate_thickness = 4;
filament_pos_x  = (hobbed_effective_diam/2+filament_compressed_diam/2)*left;
filament_pos_y  = 0;
idler_nut_pos_z = motor_shoulder_height + extrusion_height + idler_nut_thickness/2;
idler_pos_x     = filament_pos_x - (filament_compressed_diam/2+idler_bearing_outer/2);
idler_pos_z     = idler_nut_pos_z + idler_nut_thickness/2 + idler_shaft_support + idler_bearing_height/2;
filament_pos_z  = idler_pos_z;

hinge_space_width = 1.5;
hinge_space_pos_x = filament_pos_x - filament_opening/2 - extrusion_width*2 - hinge_space_width/2;
hinge_pos_y       = - motor_hole_spacing/2;

hotend_pos_y      = -motor_hole_spacing/2-motor_screw_head_diam/2;

idler_screw_pos_y = motor_side/2-wall_thickness-m3_nut_diam/2;
idler_screw_pos_z = filament_pos_z - filament_opening/2 - extrusion_height - m3_diam/2;
idler_washer_thickness = 1;

echo("Idler screw length at least ", idler_shaft_support*2 + 1 + idler_bearing_height + 3);

groove_mount_wings = true;
groove_mount_wings = false;
groove_mount_wings_hole_spacing = 50;
groove_mount_wings_hole_diam    = 4.1;
groove_mount_wings_nut_diam     = 4.1;
groove_mount_wings_thickness    = 8;
groove_mount_wings_thickness    = (motor_side-motor_shoulder_diam)/2;

bowden_nut_diam      = 11;
bowden_nut_thickness = 5;
bowden_tubing_diam   = 6; // 0.25inch threaded diam

OUTPUT_NONE         = 0;
OUTPUT_GROOVE_MOUNT = 1;
OUTPUT_BOWDEN       = 2;
output              = OUTPUT_NONE;
output              = OUTPUT_BOWDEN;
output              = OUTPUT_GROOVE_MOUNT;

geared_stepper_mount_diam      = 36;
geared_stepper_mount_height    = 26;
geared_stepper_shoulder_diam   = 22;
geared_stepper_shoulder_height = 2;
geared_stepper_screw_spacing   = 28;
geared_stepper_screw_diam      = 3;
geared_stepper_shaft_diam      = 8;
geared_stepper_shaft_len       = 20;
geared_stepper_body_side       = 42;
geared_stepper_body_len        = 34;

module geared_stepper_motor() {
  module body() {
    translate([0,0,-geared_stepper_mount_height/2]) {
      hole(geared_stepper_mount_diam,    geared_stepper_mount_height,    resolution);
    }
    hole(geared_stepper_shoulder_diam, geared_stepper_shoulder_height*2, resolution);
    hole(geared_stepper_shaft_diam,geared_stepper_shaft_len*2);

    translate([0,0,-geared_stepper_mount_height-geared_stepper_body_len/2]) {
      cube([geared_stepper_body_side,geared_stepper_body_side,geared_stepper_body_len],center=true);
    }
  }

  module holes() {
    for(r=[0,1,2,3]) {
      rotate([0,0,45+r*90]) {
        translate([geared_stepper_screw_spacing/2,0,0]) {
          hole(geared_stepper_screw_diam,100);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}


module geared_direct_drive() {
  body_wall_thickness       = geared_stepper_screw_diam/2 + extrusion_width*6;
  body_diam                 = geared_stepper_screw_spacing + body_wall_thickness*2;
  height                    = geared_stepper_shaft_len;
  idler_bolt_head_thickness = 3;

  hobbed_outer   = 12.7;
  hobbed_opening = hobbed_outer + 1;
  hobbed_diam    = 11.4;
  hobbed_height  = 13.1;

  idler_pos_x    = hobbed_diam/2 + filament_diam + idler_bearing_outer/2;
  idler_pos_z    = height - idler_bearing_height/2 - 1;

  idler_screw_diam      = 3.1;
  idler_screw_pos_y     = body_diam/2 + idler_screw_diam/2 + 1;
  idler_screw_pos_z     = height/2;
  idler_screw_body_diam = 9;
  idler_screw_body_len  = idler_pos_x + idler_bearing_outer/2-1;

  filament_x     = hobbed_diam/2 + filament_diam/2;
  filament_z     = idler_pos_z;

  idler_hinge_thickness = 2;
  idler_gap_width       = 2;
  idler_gap_x           = filament_x + filament_diam/2 + extrusion_width*2 + idler_gap_width/2;

  motor_rotation = 45;

  rotate([0,0,motor_rotation]) {
    //% geared_stepper_motor();
  }

  translate([idler_pos_x,0,idler_pos_z]) {
    % hole(idler_bearing_outer, idler_bearing_height, resolution);
  }

  translate([0,0,height-hobbed_height/2+0.05]) {
    % hole(hobbed_outer,hobbed_height,resolution);
  }

  module body() {
    rounded_diam = body_diam/2 - hobbed_opening/2;
    intersection() {
      translate([0,0,height/2]) {
        hull() {
          hole(body_diam,height, resolution);

          translate([idler_pos_x,0,0]) {
            hole(idler_bearing_outer-2, height, resolution);
          }

          translate([idler_pos_x,geared_stepper_screw_spacing/2,0]) {
            hole(body_wall_thickness*2,height,resolution);
          }
          translate([idler_gap_x,-geared_stepper_screw_spacing/2,0]) {
            hole(body_wall_thickness*2,height,resolution);
          }
        }
      }

      union() {
        cube([100,100,(height-hobbed_height+1)*2],center=true);
        translate([50,0,0]) {
          cube([100,100,height*3],center=true);
        }
      }
    }

    for(y=[front,rear]) {
      translate([0,(body_diam/2-rounded_diam/2)*y,height/2]) {
        hole(rounded_diam,height,resolution);
      }
    }
    hull() {
      translate([idler_screw_body_len/2,idler_screw_pos_y,idler_screw_pos_z]) {
        rotate([0,90,0]) {
          hole(idler_screw_body_diam,idler_screw_body_len,resolution);
        }
      }
      for(x=[idler_pos_x,body_wall_thickness]) {
        translate([x,geared_stepper_screw_spacing/2*y,height/2]) {
          hole(body_wall_thickness*2,height,resolution);
        }
      }
      translate([idler_pos_x,0,height/2]) {
        hole(idler_bearing_outer-2, height, resolution);
      }
    }
  }

  module holes() {
    for(r=[1,2,3]) {
      rotate([0,0,r*90]) {
        translate([geared_stepper_screw_spacing/2,0,0]) {
          hole(geared_stepper_screw_diam,50);
        }
      }
    }

    // overhang the shoulder and main opening
    hull() {
      hole(geared_stepper_shoulder_diam,geared_stepper_shoulder_height*2,resolution);
      hole(hobbed_opening,(idler_pos_z-idler_bearing_height-1)*2,resolution);
    }
    hole(hobbed_opening,50,resolution);

    idler_holes();

    // filament path
    translate([filament_x,0,filament_z]) {
      rotate([90,0,0]) {
        % hole(filament_diam,60);
        hole(filament_diam+0.5,60,8);
      }
    }

    // idler gap
    translate([0,0,idler_pos_z]) {
      cube([100,12,idler_bearing_height+3],center=true);
    }

    // idler screw
    for(y=[0,-1]) {
      translate([0,idler_screw_pos_y+y,idler_screw_pos_z]) {
        translate([idler_screw_body_len,0,0]) {
          rotate([0,90,0]) {
            hole(idler_screw_diam,100,6);
            hole(m3_nut_diam,3,6);
          }
        }
        translate([-10,0,0]) {
          rotate([0,90,0]) {
            hole(6,20,8);
          }
        }
      }
    }

    translate([0,0,height/2]) {
      hull() {
        translate([idler_gap_x,hobbed_diam/2,0]) {
          hole(idler_gap_width,height+1);
        }
        translate([idler_gap_x,-body_diam/2+idler_hinge_thickness+idler_gap_width/2,0]) {
          hole(idler_gap_width,height+1);
        }
      }
    }
    translate([0,0,height/2+extrusion_height]) {
      hull() {
        translate([idler_gap_x,hobbed_diam/2,0]) {
          hole(idler_gap_width,height);
        }
        translate([idler_pos_x,idler_screw_pos_y+idler_screw_body_diam/2,0]) {
          hole(idler_gap_width,height);
        }
      }
    }
  }

  module idler_holes() {
    translate([idler_pos_x,0,0]) {
      hole(idler_bearing_inner, height*3, 12);
      hole(idler_nut_diam,idler_bolt_head_thickness*2,6);

      translate([0,0,idler_pos_z]) {
        hole(idler_bearing_outer+2,idler_bearing_height+3,resolution);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module direct_drive() {
  rounded_radius = motor_side/2 - motor_hole_spacing/2;
  block_height = idler_pos_z + idler_bearing_height/2 + idler_washer_thickness + idler_shaft_support;
  block_height = idler_pos_z + idler_bearing_height/2 + .5;
  block_height = filament_pos_z + filament_opening/2 + 1;

  hotend_rounded_corner_radius = 3;
  hotend_rounded_corner_pos_x  = filament_pos_x+hotend_diam/2;
  hotend_rounded_corner_pos_y  = hotend_pos_y-hotend_clamped_height+hotend_rounded_corner_radius+hotend_clearance;
  module body() {
    hull() {
      translate([0,0,plate_thickness/2]) {
        rounded_square(motor_side,motor_diam,plate_thickness);
      }
      if (!groove_mount_wings) {
        translate([hotend_rounded_corner_pos_x,hotend_rounded_corner_pos_y,plate_thickness/2]) {
          hole(hotend_rounded_corner_radius*2,plate_thickness,resolution);
        }
      }
    }

    // main block
    hull() {
      for(y=[motor_side/2-hotend_rounded_corner_radius,hotend_rounded_corner_pos_y]) {
        for (x=[(motor_side/2-hotend_rounded_corner_radius)*left,hotend_rounded_corner_pos_x]) {
          translate([x,y,block_height/2]) {
            hole(hotend_rounded_corner_radius*2,block_height,resolution);
          }
        }
      }
    }

    if (groove_mount_wings) {
      hull() {
        for(side=[left,right]) {
          // groove mount is flush with bottom of extruder, but motor is cantilevered
          //for(y=[hotend_rounded_corner_pos_y-hotend_rounded_corner_radius+groove_mount_thickness/2]) {
          // groove mount is flush with face of motor, so no overhang, but extruder extends into carriage hole
          for(y=[-motor_side/2+groove_mount_wings_thickness/2]) {
            translate([filament_pos_x+(groove_mount_wings_hole_spacing/2+groove_mount_wings_nut_diam)*side,y,block_height/2]) {
              cube([hotend_rounded_corner_radius*2,groove_mount_wings_thickness,block_height],center=true);
            }
          }
        }
      }
    }

    if (output == OUTPUT_BOWDEN) {
      translate([filament_pos_x,hotend_rounded_corner_pos_y-hotend_rounded_corner_radius/2,filament_pos_z]) {
        rotate([90,0,0]) {
          hole(bowden_tubing_diam+6,hotend_rounded_corner_radius,8);
        }
      }
    }
  }

  module holes() {
    tensioner_wiggle = .4;
    translate([0,idler_screw_pos_y,idler_screw_pos_z]) {
      for(side=[front,rear]) {
        // tensioner screw
        translate([0,tensioner_wiggle/2*side,0]) {
          rotate([0,90,0]) {
            hole(m3_diam,motor_side*2,8);
          }
        }
        // tensioner captive nut
        translate([-motor_side/2,tensioner_wiggle/2*side,0]) {
          rotate([0,90,0]) {
            hole(m3_nut_diam,10,6);
          }
        }
      }
    }

    if (groove_mount_wings) {
      for(side=[left,right]) {
        translate([filament_pos_x+groove_mount_wings_hole_spacing/2*side,-motor_side/2,block_height/2]) {
          rotate([90,0,0]) {
            hole(4.1,30,8);
          }
        }
      }
    }

    // motor mount holes
    for(side=[top,bottom]) {
      translate([motor_hole_spacing/2,motor_hole_spacing/2*side,0]) {
        hole(m3_diam_vertical,motor_len,8);
      }
    }
    translate([-motor_hole_spacing/2,-motor_hole_spacing/2,0]) {
      hole(m3_diam_vertical+.2,motor_len,resolution);
    }

    // motor shoulder + slack
    mount_shoulder_width = motor_shoulder_diam/2+abs(hinge_space_pos_x)+1;
    intersection() {
      hull() {
        hole(motor_shoulder_diam+0.5,plate_thickness*2+0.05,resolution);
        hole(2,(plate_thickness+motor_shoulder_diam/2+2)*2,resolution);
      }
      translate([motor_shoulder_diam/2-mount_shoulder_width/2+1,0,0]) {
        cube([mount_shoulder_width,motor_shoulder_diam+1,motor_len],center=true);
      }
    }

    // idler arm motor shoulder clearance
    intersection() {
      translate([-0.5,0,0]) {
        hull() {
          hole(motor_shoulder_diam+0.5,motor_shoulder_height*2,resolution);
          hole(2,(motor_shoulder_height+motor_shoulder_diam/2)*2,resolution);
        }
      }
      translate([hinge_space_pos_x-motor_side/2,0,0]) {
        cube([motor_side+0.05,motor_side+0.05,motor_len],center=true);
      }
    }

    // pulley clearance
    hole(hobbed_pulley_diam+2,motor_len,resolution);
    pulley_clearance = hobbed_pulley_diam+3;
    hull() {
      translate([hinge_space_pos_x,0,0]) {
        cube([1,pulley_clearance,motor_len],center=true);
      }

      translate([rounded_radius,0,0]) {
        cube([1,pulley_clearance,motor_len],center=true);
      }
    }
    // hobbed pulley access
    translate([motor_side*.2,0,plate_thickness+motor_len/2]) {
      hole(motor_shoulder_diam,motor_len,8);
    }

    // hinge space between idler and hobbed pulley
    hull() {
      translate([hinge_space_pos_x,hinge_pos_y+hinge_space_width/2,0]) {
        hole(hinge_space_width,motor_len,resolution);

        translate([0,motor_side,0]) {
          cube([hinge_space_width,1,motor_len],center=true);
        }
      }
    }

    // hinge space between idler and motor mount screw
    translate([hinge_space_pos_x-hinge_space_width/2-3,hinge_pos_y+0.5,0]) {
      hull() {
        hole(1,motor_len,resolution);

        translate([-(motor_screw_head_diam/2-m3_diam_vertical/2),motor_screw_head_diam/2,0]) {
          hole(1,motor_len,resolution);
        }
      }

      hull() {
        translate([-(motor_screw_head_diam/2-m3_diam_vertical/2),motor_screw_head_diam/2,0]) {
          hole(1,motor_len,resolution);

          translate([-motor_side,0,0]) {
            cube([hinge_space_width,1,motor_len],center=true);
          }
        }
      }
    }

    translate([idler_pos_x,0,0]) {
      // idler shaft
      hole(idler_bearing_inner,motor_len,resolution);

      // idler bearing
      translate([0,0,idler_pos_z]) {
        hole(idler_bearing_outer+1.5,idler_bearing_height+idler_washer_thickness*2,resolution);
      }

      // captive idler nut/bolt
      hull() {
        translate([0,0,idler_nut_pos_z]) {
          hole(idler_nut_diam,idler_nut_thickness,6);

          translate([0,0,-motor_len/2]) {
            hole(idler_nut_diam,idler_nut_thickness,6);
          }
        }
      }
    }

    bevel_dist = extrusion_height*3;
    translate([idler_pos_x,0,0]) {
      // created a bevel in case the first few layers are melted into a flange
      hull() {
        hole(idler_nut_diam,motor_shoulder_height,6);
        hole(idler_nut_diam+bevel_dist*2,0.05,36);
      }
    }

    // filament path
    translate([filament_pos_x,0,filament_pos_z]) {
      rotate([90,0,0]) {
        hole(filament_opening,70,8);
      }
    }

    // hotend void
    hotend_res = resolution*2;
    above_height = hotend_height_above_groove+hotend_clearance*2;
    if (output == OUTPUT_GROOVE_MOUNT) {
      translate([filament_pos_x,hotend_pos_y,filament_pos_z]) {
        rotate([-90,0,0]) {
          translate([0,0,-hotend_clamped_height]) {
            hole(hotend_groove_diam+hotend_clearance,hotend_clamped_height*2,hotend_res);
            translate([0,-hotend_diam/2,0]) {
              cube([hotend_groove_diam,hotend_diam,hotend_clamped_height*2],center=true);
            }
          }

          translate([0,0,-above_height/2+hotend_clearance]) {
            hole(hotend_diam+hotend_clearance,above_height,hotend_res);
            translate([0,-hotend_diam/2,0]) {
              cube([hotend_diam,hotend_diam,above_height],center=true);
            }

            // zip tie restraint
            zip_tie_hole(hotend_diam + hotend_rounded_corner_radius*2);
          }

          translate([0,0,-hotend_clamped_height-10+hotend_clearance]) {
            hole(hotend_diam+hotend_clearance,20,hotend_res);
            translate([0,-hotend_diam/2,0]) {
              cube([hotend_diam,hotend_diam,20],center=true);
            }
          }
        }
      }
    }

    if (output == OUTPUT_BOWDEN) {
      translate([filament_pos_x,hotend_rounded_corner_pos_y,filament_pos_z]) {
        rotate([90,0,0]) {
          hole(bowden_tubing_diam,hotend_rounded_corner_radius+bowden_nut_thickness,8);
        }

        translate([0,bowden_nut_thickness/2,0]) {
          rotate([90,0,0]) {
            hole(bowden_nut_diam,bowden_nut_thickness,6);
          }
        }
      }
    }
  }

  module bridges() {
    translate([hinge_space_pos_x-hinge_space_width/2-idler_nut_diam/2-1,0,idler_nut_pos_z+idler_nut_thickness/2+extrusion_height]) {
      cube([idler_nut_diam+2,idler_nut_diam+3,extrusion_height*2],center=true);
    }
  }

  % motor();
  % translate([0,0,filament_pos_z]) {
    rotate([0,180,0]) {
      hobbed_pulley();
    }
  }
  % translate([filament_pos_x,0,filament_pos_z]) {
    rotate([90,0,0]) {
      hole(filament_diam,50,16);
    }
  }
  % translate([idler_pos_x,0,idler_pos_z]) {
    hole(idler_bearing_outer,idler_bearing_height,32);
  }

  difference() {
    body();
    holes();
  }
  bridges();
}

geared_direct_drive();
//direct_drive();
//assembly();
