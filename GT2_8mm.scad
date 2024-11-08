// v2 works for linear
tooth_height = 8;
tooth_width = 0.78;
tooth_spacing = 1.2;


//v1
//tooth_width = 1.38;
//tooth_spacing = 1.4;

tooth_depth=0.76;

length=25.4*1.5; //1.5inches

$fn=60;
// This is merely a test-bed for the cylinder, but if you so choose, you can create a
// variable length linear GT2 timing "pulley"
module linear(height, length) {
    
    //translate([0,0,-0.2]) #cube([tooth_depth+20,tooth_depth,tooth_depth]);
    union() {
        difference() {
            translate([0,0,0])
            cube([length,8,3]);
            
            up=0;
            
            rotate([90,0,0]) {
                translate([0,0,-8.5]) {      
                    for (i = [ 0 : (tooth_spacing+tooth_width) : length ]) {
                        // decrease the height of the tooth_spacing by 0.1
                        translate([i,0,0.1]) cylinder(d=tooth_spacing, h=height+3);
                    }
                }
            }
        }
        rotate([90,0,0]) {
            // translate the tooth to the side, and additionally bring it down 0.2 mm
            translate([-0.2,0.2,-8]) {
                for (i = [ tooth_spacing : tooth_width+tooth_spacing : length ]) {
                    translate([i,0,0]) #cylinder(d=tooth_width, h=height);
                }
            }
        }
    }
}

module cylinder_with_teeth(radius, height, tooth_spacing, tooth_width) {
    // calculate the number of radians the tooth_spacing+tooth_width value is
    // by calculating the fraction of the circumference that distance is,
    // then calculating the % of 360 radians that we need to traverse in order
    // to get to that value.

    C = 2*PI*radius;
    P = (tooth_spacing+tooth_width)/C;
    increment = P*360;
            
    P2 = tooth_spacing/C;
    rad_offset = P2*360;
            
    echo("rad_offset =", rad_offset, "degrees");
    echo("increment =", increment, "degrees");
    echo("P =", P, "%");
    echo("P2 =", P2, "%");

    union() {
        difference() {
            // Main cylinder body
            translate([0, 0, 0]) cylinder(d=2*radius, h=height);
            
            // Cutting teeth around the circumference tooth_width in diameter
            for (angle = [0 : increment : 360]) {
                rotate([0, 0, angle]) { // Rotate each tooth around the cylinder's central axis
                    translate([radius-0.1, 0, 0]) // Move outward to cylinder surface
                        cylinder(d=tooth_spacing, h=height); // Tooth cylinder
                }
            }
        }

        // create the teeth at the edge - 0.2mm
        
        angle_delta = (0.2/C)*360;
        
        for (angle = [rad_offset : increment : 360]) {
            echo(angle);
            rotate([0, 0, angle-angle_delta]) { // Rotate each tooth around the cylinder's central axis
                translate([radius-0.2, 0, 0]) // Move outward to cylinder surface - 0.2mm
                    #cylinder(d=tooth_width, h=height); // Tooth cylinder
            }
        }
    }
}

module GT2_8mm(teeth) {
    C = teeth * (tooth_spacing + tooth_width);
    R = C / (2*PI);
    echo("Circumference = ", C, "Radius = ", R);

    tooth_width = 0.78;
    tooth_spacing = 1.2;
    
    union() {
        cylinder_with_teeth(R, 8, tooth_spacing, tooth_width);
        
        translate([0,0,-1.5]) cylinder(d=R*2+2,h=1.5);
    }
}

union() {
    GT2_8mm(22);
    translate([0,0,8])
        GT2_8mm(10);
}

//linear(8, 44);