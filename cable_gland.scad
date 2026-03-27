use <Nut_Job.scad>;
/*
 * Metric Cable Gland Generator - M12 to M63
 * Dimensions per EN 60423 / Farnell Multicomp datasheet
 *
 * All thread pitches 1.5mm per EN 60423.
 *
 * Standard dimensions reference:
 *   Size  Thread OD  Cable Max  Body Hex  Locknut AF  Locknut H  Std Thread Len
 *   M12   12         6.5        18        15          2.8        6
 *   M16   16         10         22        19          2.8        8
 *   M20   20         12         24        23          3          10
 *   M25   25         17         29        29          3.5        10
 *   M32   32         21         34        36          4          12
 *   M40   40         28         44        45          4.5        12
 *   M50   50         35         54        55          5.5        15
 *   M63   63         42         67        70          6          18
 */

/* [Gland Selection] */
// Gland size
gland_size = "M25"; // [M12, M16, M20, M25, M32, M40, M50, M63]

// Which part to generate
gland_part = "test"; // [body:Gland body, nut:Gland nut, locknut:Locknut, test:Test pieces, all:All parts]

// Nut type
nut_type = "low_dome"; // [low_dome:Low dome (commercial style), high_dome:High dome (full hemisphere), open:Open nut (cable pass-through)]

/* [Print Tuning] */
// Thread clearance (added to nut thread bore)
thread_clearance = 0.4; // [0.0:0.1:1.0]

// Thread length override (0 = standard for gland size)
thread_length_override = 0; // [0:1:50]

// Number of claws (0 = auto)
spline_count = 0; // [0:1:16]

// Setback collar height below claws (mm) — insert rests on V-ridge here
spline_setback = 2; // [0:0.5:5]

// Wall thickness in claw and thread sections (mm)
grip_wall = 2.2; // [1.5:0.1:5.0]

/* [Advanced] */
// Step shape degrees (45 for FDM, 30 for ISO standard)
step_shape_degrees = 45; // [30:5:60]

// Resolution (higher = faster, lower = finer)
resolution = 2; // [0.5:0.5:4]


/* ========================================================
 * Dimension Lookup Tables - EN 60423
 * ======================================================== */

// Thread outer diameter
function thread_od(s) =
    s == "M12" ? 12 : s == "M16" ? 16 :
    s == "M20" ? 20 : s == "M25" ? 25 :
    s == "M32" ? 32 : s == "M40" ? 40 :
    s == "M50" ? 50 : s == "M63" ? 63 : 0;

// Thread pitch (1.5mm for all standard metric glands)
function thread_pitch(s) = 1.5;

// Maximum cable diameter (defines bore)
function cable_max(s) =
    s == "M12" ? 6.5 : s == "M16" ? 10 :
    s == "M20" ? 12  : s == "M25" ? 17 :
    s == "M32" ? 21  : s == "M40" ? 28 :
    s == "M50" ? 35  : s == "M63" ? 42 : 0;

// Body hex across flats
function body_hex_af(s) =
    s == "M12" ? 18 : s == "M16" ? 22 :
    s == "M20" ? 24 : s == "M25" ? 29 :
    s == "M32" ? 34 : s == "M40" ? 44 :
    s == "M50" ? 54 : s == "M63" ? 67 : 0;

// Locknut across flats (from Farnell datasheet d2 column)
function locknut_af(s) =
    s == "M12" ? 15 : s == "M16" ? 19 :
    s == "M20" ? 23 : s == "M25" ? 29 :
    s == "M32" ? 36 : s == "M40" ? 45 :
    s == "M50" ? 55 : s == "M63" ? 70 : 0;

// Locknut height (from Farnell datasheet m column)
function locknut_h(s) =
    s == "M12" ? 2.8 : s == "M16" ? 2.8 :
    s == "M20" ? 3   : s == "M25" ? 3.5 :
    s == "M32" ? 4   : s == "M40" ? 4.5 :
    s == "M50" ? 5.5 : s == "M63" ? 6 : 0;

// Standard thread engagement length
function thread_len(s) =
    s == "M12" ? 6  : s == "M16" ? 8 :
    s == "M20" ? 10 : s == "M25" ? 10 :
    s == "M32" ? 12 : s == "M40" ? 12 :
    s == "M50" ? 15 : s == "M63" ? 18 : 0;

// Grip/spline section length (non-threaded top)
function grip_len(s) =
    s == "M12" ? 8  : s == "M16" ? 8 :
    s == "M20" ? 10 : s == "M25" ? 12 :
    s == "M32" ? 14 : s == "M40" ? 14 :
    s == "M50" ? 16 : s == "M63" ? 18 : 0;

// Nut hex section height (body below dome)
// Commercial total heights: M20=17mm, M25=20mm, M32=24mm
function nut_hex_h(s) =
    s == "M12" ? 8  : s == "M16" ? 10 :
    s == "M20" ? 11 : s == "M25" ? 14 :
    s == "M32" ? 16 : s == "M40" ? 18 :
    s == "M50" ? 20 : s == "M63" ? 22 : 0;

// Dome cap height
function dome_cap_h(s) =
    s == "M12" ? 4 : s == "M16" ? 5 :
    s == "M20" ? 6 : s == "M25" ? 6 :
    s == "M32" ? 8 : s == "M40" ? 9 :
    s == "M50" ? 10 : s == "M63" ? 12 : 0;

// Auto claw count (commercial style: fewer, thicker)
function auto_splines(s) =
    s == "M12" ? 4  : s == "M16" ? 6 :
    s == "M20" ? 6  : s == "M25" ? 12 :
    s == "M32" ? 8  : s == "M40" ? 10 :
    s == "M50" ? 10 : s == "M63" ? 12 : 0;


/* ========================================================
 * Derived dimensions
 * ======================================================== */

_tod        = thread_od(gland_size);
_pitch      = thread_pitch(gland_size);
_bore       = cable_max(gland_size);
_body_hex   = body_hex_af(gland_size);
_locknut_af = locknut_af(gland_size);
_locknut_h  = locknut_h(gland_size);
_thread_len = thread_length_override > 0
                ? thread_length_override
                : thread_len(gland_size);
_grip_len   = grip_len(gland_size);
_nut_hex_h  = nut_hex_h(gland_size);
_dome_cap_h = dome_cap_h(gland_size);
_nut_bore   = _tod + thread_clearance;
_splines    = spline_count > 0 ? spline_count : auto_splines(gland_size);
_rod_length = _thread_len + _grip_len;
_slot_width = max(0.8, 1 + ((_tod - 13) / 55));
_res        = resolution;


/* ========================================================
 * Part Generation
 * ======================================================== */

print_cable_gland(gland_part);


module print_cable_gland(part)
{
    spacing = _tod * 3;

    if (part == "body")
    {
        translate([0, 0, _rod_length]) rotate([180, 0, 0])
            gland_body();
    }
    else if (part == "nut")
    {
        if (nut_type == "low_dome")
            gland_low_dome_nut();
        else if (nut_type == "high_dome")
            gland_high_dome_nut();
        else
            gland_open_nut();
    }
    else if (part == "locknut")
    {
        gland_locknut();
        translate([_locknut_af * 1.5, 0, 0])
            gland_locknut();
    }
    else if (part == "all")
    {
        // Body at centre
        translate([0, 0, _rod_length]) rotate([180, 0, 0])
            gland_body();

        // Nut to the right
        translate([spacing, 0, 0])
        {
            if (nut_type == "low_dome")
                gland_low_dome_nut();
            else if (nut_type == "high_dome")
                gland_high_dome_nut();
            else
                gland_open_nut();
        }

        // Two locknuts to the left
        translate([-spacing, 0, 0])
            gland_locknut();
        translate([-spacing - _locknut_af * 1.5, 0, 0])
            gland_locknut();
    }
    else if (part == "test")
    {
        // Short test pieces for checking thread fit
        // 5-turn threaded ring + locknut
        echo(str("Test pieces for ", gland_size,
                 " | Thread OD: ", _tod,
                 "mm | Clearance: ", thread_clearance, "mm"));

        test_len = _pitch * 5;  // 5 thread turns
        countersink = 2;

        // Short threaded ring (no grip section)
        translate([0, 0, test_len]) rotate([180, 0, 0])
        difference()
        {
            hex_screw(
                _tod, _pitch, step_shape_degrees,
                test_len, _res, countersink,
                _body_hex, 0, 0, 0
            );

            // Bore through
            cylinder(
                d = _tod - 2 * grip_wall,
                h = test_len * 3,
                center = true,
                $fn = floor(_tod * PI / _res)
            );
        }

        // Locknut alongside
        translate([_body_hex * 1.2, 0, 0])
            gland_locknut();
    }
}


/* --------------------------------------------------------
 * Gland Body (threaded rod with claw grip section)
 *
 * Commercial-style design:
 * - Thick tapered claws with narrow slots between them
 * - Claw section tapers conically (narrower at tip)
 * - Claws are wider at base, narrower at tip for flex
 * - Setback ring with V-ridge for insert seating
 * -------------------------------------------------------- */
module gland_body()
{
    countersink = 2;
    fn_val = floor(_tod * PI / _res);

    // Insert lip inset (mm per side)
    lip_inset = 1.0;

    // Grip bore diameter
    grip_bore_d = _bore + 2 * grip_wall;

    // Claw section geometry
    claw_len     = _grip_len - spline_setback;     // active claw length
    base_od      = _tod - thread_clearance;                             // OD at claw base (matches thread)
    tip_od       = base_od - base_od * 0.12;               // OD tapers ~12% at tip (conical)

    // Slot widths: narrow at base, slightly wider at tip for flex
    slot_base_w  = max(0.8, _slot_width * 0.7);
    slot_tip_w   = max(1.0, _slot_width * 1.2);

    difference()
    {
        union()
        {
            // Threaded section (no grip — we build claws separately)
            hex_screw(
                _tod, _pitch, step_shape_degrees,
                _thread_len, _res, countersink,
                _body_hex, 0,
                0,    // no non-threaded section from hex_screw
                0
            );

            // Setback ring: solid collar on top of thread
            translate([0, 0, _thread_len])
                cylinder(
                    d = base_od,
                    h = spline_setback,
                    $fn = fn_val
                );

            // Claw section: conical cylinder that we'll slot into
            translate([0, 0, _thread_len + spline_setback])
                cylinder(
                    d1 = base_od,
                    d2 = tip_od,
                    h = claw_len,
                    $fn = fn_val
                );
        }

        // Cut narrow slots to form thick claws
        if (_splines > 0)
        {
            for (i = [0 : _splines - 1])
            {
                rotate([0, 0, i * 360 / _splines])
                translate([0, 0, _thread_len + spline_setback - 0.01])
                {
                    // Tapered slot: narrow at base, wider at tip
                    hull()
                    {
                        // Base of slot (narrow)
                        translate([base_od / 4, 0, 0])
                            cube([base_od / 2, slot_base_w, 0.02], center = true);

                        // Tip of slot (wider)
                        translate([tip_od / 4, 0, claw_len + 0.02])
                            cube([tip_od / 2, slot_tip_w, 0.02], center = true);
                    }
                }
            }
        }

        // Grip bore through claw zone
        translate([0, 0, _thread_len - 0.01])
            cylinder(
                d = grip_bore_d,
                h = spline_setback + claw_len + 0.1,
                $fn = fn_val
            );

        // Setback zone bore: V-shaped lip for insert seating
        translate([0, 0, _thread_len - 0.01])
        {
            // Lower half: ramps in
            cylinder(
                d1 = grip_bore_d,
                d2 = grip_bore_d - 2 * lip_inset,
                h = spline_setback / 2,
                $fn = fn_val
            );
            // Upper half: ramps back out
            translate([0, 0, spline_setback / 2])
                cylinder(
                    d1 = grip_bore_d - 2 * lip_inset,
                    d2 = grip_bore_d,
                    h = spline_setback / 2 + 0.02,
                    $fn = fn_val
                );
        }

        // Thread section bore
        translate([0, 0, -0.1])
            cylinder(
                d = _tod - 2 * grip_wall,
                h = _thread_len + 0.2,
                $fn = fn_val
            );
    }
}


/* --------------------------------------------------------
 * Low Dome Nut - commercial style shallow spherical cap
 *
 * Interior has an aggressive compression cone from just
 * above the thread zone all the way to the dome opening.
 * This forces the splines inward onto the cable as the
 * nut is tightened, rather than letting them rest flat.
 * -------------------------------------------------------- */
module gland_low_dome_nut()
{
    dome_d  = _body_hex;
    dome_r  = dome_d / 2;
    fn_val  = floor(_nut_bore * PI / _res);
    cap_h   = _dome_cap_h;

    // Spherical cap: R = (h² + r²) / (2h)
    outer_R = (cap_h * cap_h + dome_r * dome_r) / (2 * cap_h);

    // Cable bore radius
    cable_r = _bore / 2;

    // Compression funnel: starts just above thread engagement,
    // tapers from thread bore to cable bore at dome junction
    funnel_start = _pitch * 4;   // clear of thread engagement
    funnel_top_r = cable_r + 0.3; // slight clearance at dome opening

    difference()
    {
        union()
        {
            hex_nut(
                dome_d, _nut_hex_h, _pitch,
                step_shape_degrees, _nut_bore, _res
            );

            // Spherical cap dome
            translate([0, 0, _nut_hex_h])
            intersection()
            {
                translate([0, 0, cap_h - outer_R])
                    sphere(r = outer_R, $fn = fn_val);
                cylinder(r = dome_r, h = cap_h + 0.1, $fn = fn_val);
            }
        }

        // Compression funnel through hex body
        // Thread bore zone (bottom)
        translate([0, 0, -0.1])
            cylinder(
                r = _nut_bore / 2,
                h = funnel_start + 0.1,
                $fn = fn_val
            );

        // Funnel zone: tapers from thread bore to cable bore
        translate([0, 0, funnel_start])
            cylinder(
                r1 = _nut_bore / 2,
                r2 = funnel_top_r,
                h = _nut_hex_h - funnel_start + 0.01,
                $fn = fn_val
            );

        // Cable bore through dome cap
        translate([0, 0, _nut_hex_h - 0.01])
            cylinder(
                r = funnel_top_r,
                h = cap_h + 0.2,
                $fn = fn_val
            );
    }
}


/* --------------------------------------------------------
 * High Dome Nut - full hemisphere dome
 *
 * Same compression funnel as low dome, with a taller
 * hemispherical cap trimmed at 70% height.
 * -------------------------------------------------------- */
module gland_high_dome_nut()
{
    dome_d  = _body_hex;
    dome_r  = dome_d / 2;
    fn_val  = floor(_nut_bore * PI / _res);

    cable_r = _bore / 2;

    funnel_start = _pitch * 4;
    funnel_top_r = cable_r + 0.3;

    difference()
    {
        union()
        {
            hex_nut(
                dome_d, _nut_hex_h, _pitch,
                step_shape_degrees, _nut_bore, _res
            );

            // Full hemisphere dome
            translate([0, 0, _nut_hex_h])
            hull()
            {
                sphere(r = dome_r, $fn = fn_val);
                cylinder(r = dome_r, h = 0.001, $fn = fn_val);
            }
        }

        // Compression funnel
        translate([0, 0, -0.1])
            cylinder(
                r = _nut_bore / 2,
                h = funnel_start + 0.1,
                $fn = fn_val
            );

        translate([0, 0, funnel_start])
            cylinder(
                r1 = _nut_bore / 2,
                r2 = funnel_top_r,
                h = _nut_hex_h - funnel_start + 0.01,
                $fn = fn_val
            );

        // Trim top of dome
        translate([0, 0, _nut_hex_h + dome_r * 0.7])
            cylinder(r = dome_r, h = dome_r, $fn = fn_val);

        // Cable bore through dome
        translate([0, 0, _nut_hex_h - 0.01])
            cylinder(r = funnel_top_r, h = dome_r, $fn = fn_val);
    }
}


/* --------------------------------------------------------
 * Open Nut - straight hex nut with cable pass-through
 *
 * Same hex dimensions as the dome nut but with a plain
 * flat top and a slight inner chamfer for cable entry.
 * -------------------------------------------------------- */
module gland_open_nut()
{
    fn_val = floor(_nut_bore * PI / _res);

    difference()
    {
        // Hex nut with thread
        hex_nut(
            _body_hex, _nut_hex_h, _pitch,
            step_shape_degrees, _nut_bore, _res
        );

        // Widen the cable bore to match gland bore
        // (hex_nut already has a threaded bore; enlarge top section)
        translate([0, 0, -0.1])
            cylinder(
                r = _bore / 2,
                h = _nut_hex_h + 0.2,
                $fn = fn_val
            );

        // Entry chamfer on top
        translate([0, 0, _nut_hex_h - 1])
            cylinder(
                r1 = _bore / 2,
                r2 = _bore / 2 + 1.5,
                h = 1.1,
                $fn = fn_val
            );

        // Entry chamfer on bottom
        translate([0, 0, -0.1])
            cylinder(
                r1 = _bore / 2 + 1.5,
                r2 = _bore / 2,
                h = 1.1,
                $fn = fn_val
            );
    }
}


/* --------------------------------------------------------
 * Locknut (plain hex nut)
 * -------------------------------------------------------- */
module gland_locknut()
{
    hex_nut(
        _locknut_af, _locknut_h, _pitch,
        step_shape_degrees, _nut_bore, _res
    );
}
