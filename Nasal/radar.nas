# ===============================================================
#                   Air and Terrain Mode Radar
#                       for ATOS System
#                     AMOROSO Paolo 06/2025
# ===============================================================
MPjoin = func(n) {
  var base = n.getValue();
  setprop("instrumentation/radar/" ~ base ~ "/radar/y-shift", 0);
  setprop("instrumentation/radar/" ~ base ~ "/radar/x-shift", 0);
  setprop("instrumentation/radar/" ~ base ~ "/radar/rotation", 0);
  setprop("instrumentation/radar/" ~ base ~ "/radar/in-range", 0);
  setprop("instrumentation/radar/" ~ base ~ "/radar/h-offset", 180);
  setprop("instrumentation/radar/" ~ base ~ "/joined", 1);
}

MPleave = func(n) {
  var base = n.getValue();
  setprop("instrumentation/radar/" ~ base ~ "/radar/in-range", 0);
  setprop("instrumentation/radar/" ~ base ~ "/joined", 0);
}

MPradarProperties = func {
  var targetList = props.globals.getNode("ai/models/").getChildren("multiplayer");
  foreach (d; props.globals.getNode("ai/models/").getChildren("aircraft")) {
    append(targetList, d);
  }

  foreach (m; targetList) {
    var name = m.getName();
    var index = m.getIndex();
    var path = "instrumentation/radar/ai/models/" ~ name ~ "[" ~ index ~ "]/";
    var sourcePath = "ai/models/" ~ name ~ "[" ~ index ~ "]/";

    if (getprop(path ~ "joined") == 1 or name == "aircraft") {
      var factor = getprop("instrumentation/radar/range-factor");
      if (factor == nil) factor = 1.0;

      var yNode = m.getNode("radar/y-shift", 0);
      var xNode = m.getNode("radar/x-shift", 0);
      var rotNode = m.getNode("radar/rotation", 0);
      var hOffNode = m.getNode("radar/h-offset", 0);
      var inRangeNode = m.getNode("radar/in-range", 0);

      var yVal = yNode != nil and yNode.getValue() != nil ? yNode.getValue() : 0;
      var xVal = xNode != nil and xNode.getValue() != nil ? xNode.getValue() : 0;
      var rotVal = rotNode != nil and rotNode.getValue() != nil ? rotNode.getValue() : 0;
      var hOffVal = hOffNode != nil and hOffNode.getValue() != nil ? hOffNode.getValue() : 0;
      var inRangeVal = inRangeNode != nil and inRangeNode.getValue() != nil ? inRangeNode.getValue() : 0;

      setprop(path ~ "radar/y-shift", yVal * factor);
      setprop(path ~ "radar/x-shift", xVal * factor);
      setprop(path ~ "radar/rotation", rotVal);
      setprop(path ~ "radar/h-offset", hOffVal);

      if (getprop("instrumentation/radar/selected") == 2) {
        var xShift = getprop(path ~ "radar/x-shift");
        if (xShift < -0.04 or xShift > 0.04) {
          setprop(path ~ "radar/in-range", 0);
        } else {
          setprop(path ~ "radar/in-range", inRangeVal);
        }
      } else {
        setprop(path ~ "radar/in-range", inRangeVal);
      }
    }
  }

  var selected = getprop("instrumentation/radar/selected");
  var range = getprop("instrumentation/radar/range");

  # Range Scaling Factor
  if (selected == 2) {
    if (range == 10) {
      setprop("instrumentation/radar/range", 20);
      setprop("instrumentation/radar/range-factor", 0.002);
    } elsif (range == 20) {
      setprop("instrumentation/radar/range-factor", 0.003246);
    } else {
      setprop("instrumentation/radar/range-factor", 0.001623);
    }
  } elsif (selected == 3 or selected == 4) {
    if (range == 40) {
      setprop("instrumentation/radar/range", 20);
      setprop("instrumentation/radar/range-factor", 0.001888);
    } elsif (range == 20) {
      setprop("instrumentation/radar/range-factor", 0.001888);
    } else {
      setprop("instrumentation/radar/range-factor", 0.003776);
    }
  }
  settimer(MPradarProperties, 0.05);
}

# =====================
#  Boresight Detecting
# =====================
locking=0;
found=-1;

boreSightLock = func {
  if (getprop("instrumentation/radar/selected") == 1) {
    targetList= props.globals.getNode("ai/models/").getChildren("multiplayer");

    foreach (d; props.globals.getNode("ai/models/").getChildren("aircraft")) {
      append(targetList,d);
    }

    foreach (m; targetList) {
      var string = "instrumentation/radar/ai/models/"~m.getName()~"["~m.getIndex()~"]";
      var string1 = "ai/models/"~m.getName()~"["~m.getIndex()~"]";
      if (getprop(string1~"radar/in-range")) {

        hOffset = getprop(string1~"radar/h-offset");
        vOffset = getprop(string1~"radar/v-offset");

        #really should be a cone, but is a square pyramid to avoid trigonemetry
        if(hOffset < 3 and hOffset > -3 and vOffset < 3 and vOffset > -3) {
          if (locking == 11) {
            setprop(string~"radar/boreLock",2);
            setprop("instrumentation/radar/lock",2);
            setprop("sim[0]/hud/current-color",1);
            locking -= 1;
          } elsif (locking ==1 or locking ==3 or locking ==5 or locking ==7 or locking ==9 ) {
            setprop("instrumentation/radar/lock",1);
            setprop(string1~"radar/boreLock",1);
          } else {
            setprop("instrumentation/radar/lock",0);
            setprop(string~"radar/boreLock",1);
          }

          if (found != m.getIndex()) {
            found=m.getIndex();
            locking=0;
          } else {
            locking += 1;
          }
          settimer(boreSightLock, 0.2);
          return;
        }
      }
    }
    setprop(string~"radar/boreLock",0);
    locking=0;
    setprop("sim[0]/hud/current-color",0);
  }

  locking=0;
  setprop("sim[0]/hud/current-color",0);
  found =-1;
  setprop("instrumentation/radar/lock",0);

  settimer(boreSightLock, 0.2);
}

setlistener("ai/models/model-added", MPjoin);
setlistener("ai/models/model-removed", MPleave);
settimer(MPradarProperties,1.0);
settimer(boreSightLock, 1.0);

#================================================================
#                          SLAR Mode
#================================================================

var RAD2DEG      = 57.2957795;
var DEG2RAD      = 0.016774532925;
var terrain      = "/instrumentation/radar/pixels/";
#                                                  3D radar line length in meters
var DISP_LENGTH   = 0.0856;
#                                                  fixed number of plots
var DISP_DEF      = 100;
#                                                  vertical calibration
var DEV_CALIB     = 1.5;
#                                                  radar update every 0.5s
var UPDATE_PERIOD = 0.5;
#
var FT2M          = 0.3048;
var NM2M          = 1852;
var D2R           = math.pi / 180;
#                                                  radar range 5 NM
var MAX_RANGE_M   = 5 * NM2M;
#                                                  5 NM per 100 plots
var interval_m    = MAX_RANGE_M / DISP_DEF;
var radar_scale   = DISP_LENGTH / MAX_RANGE_M;

# Function to get Elevation at latitude and longitude
var get_elevation = func (lat, lon) {

  var info = geodinfo(lat, lon);

  if (info == nil ) {
    var elev = -1;                                 # Unknown
  } elsif (info[1] == nil) {
    var elev = info[0] * 3.2808399;                # Building
  } elsif (info[1].solid == 0) {
    var elev = 0;                                  # Water
  } else {
    var elev = info[0] * 3.2808399;                # other
  }

  elev = elev * radar_scale * FT2M;

  return elev;
}
var update_radar = func {

  var poslon      = getprop("/position/longitude-deg");
  var poslat      = getprop("/position/latitude-deg");
  var heading     = getprop("/orientation/heading-magnetic-deg");

  var range       = getprop("/instrumentation/radar/range");
  var displaymode = getprop("/instrumentation/radar/display-mode");

  # First get all the points (16x16)
  for (var col = 0; col <= 98; col += 2) {

    var beam_offset_nm = (49 - col) * (range/30);
    var forward_offset_nm = range / 30;

    var base = geo.Coord.new().set_latlon(poslat, poslon);

    var lateral = base.apply_course_distance(heading - 90, beam_offset_nm * NM2M);
    var point = lateral.apply_course_distance(heading, forward_offset_nm * NM2M);

    var pointlat = point.lat();
    var pointlon = point.lon();

    var elev = get_elevation(pointlat, pointlon);

    setprop(terrain ~ "/col[" ~ col ~ "]/elevation", elev);
  }

  # Interpolate the rest of the points in each column

  for (var col = 1; col <= 97; col += 2) {
    var elevprev = getprop(terrain ~ "/col[" ~ (col - 1) ~ "]/elevation");
    var elevnext = getprop(terrain ~ "/col[" ~ (col + 1) ~ "]/elevation");
    var elev = (elevprev + elevnext) / 2;

    setprop(terrain ~ "/col[" ~ col ~ "]/elevation", elev);
  }
}

###  Main loop ###
var radar_loop = func {
  update_radar();
  settimer(radar_loop, UPDATE_PERIOD);
}

# Initialisation
var RADAR_init = func {
  print("Ground Radar updated");
  radar_loop();
}

RADAR_init();

#================================================================
#              FORWARD LOOKING TERRAIN RADAR Mode
#================================================================

print("*** FORWARD LOOKING TERRAIN RADAR INIT ***");

var FL_DEG2RAD  = 0.01745329252;
var FL_TERRAIN  = "/instrumentation/terrain-map/pixels/";

var FL_MAX_ROW      = 30;
var FL_MAX_COL      = 30;
var FL_RAY_STEPS    = 6;        
var FL_MAX_RANGE_NM = 10;
var FL_FT_PER_NM    = 6076;

var FL_row        = 0;
var FL_active     = 0;   

var FL_get_elevation = func(lat, lon) {
    var info = geodinfo(lat, lon);
    if (info == nil) return -1;
    if (info[1] == nil) return info[0] * 3.2808399; 
    if (info[1].solid == 0) return 0;
    return info[0] * 3.2808399;
}

var FL_update = func {

    if (getprop("/instrumentation/terrain-map/forward-looking") != 1)
        return;

    var lat     = getprop("/position/latitude-deg");
    var lon     = getprop("/position/longitude-deg");
    var heading = getprop("/orientation/heading-magnetic-deg");
    var pitch   = getprop("/orientation/pitch-deg");
    var alt_ft  = getprop("/position/altitude-ft");

    var range_nm = getprop("/instrumentation/terrain-map/range");
    if (range_nm == nil) range_nm = FL_MAX_RANGE_NM;

    var antenna_tilt = getprop("/instrumentation/terrain-map/tilt-deg");
    if (antenna_tilt == nil) antenna_tilt = 0;

    var row = FL_row;
    var dist_nm_row = (row + 1) * (range_nm / (FL_MAX_ROW + 1));

    for (var col = 0; col <= FL_MAX_COL; col += 2) {

        var lateral_nm = (col - FL_MAX_COL/2) * (range_nm / FL_MAX_COL);

        var base_lat = lat + (lateral_nm * math.cos(FL_DEG2RAD * (heading + 90)) / 60);
        var base_lon = lon + (lateral_nm * math.sin(FL_DEG2RAD * (heading + 90)) / 60);

        var hit = -1;

        for (var s = 1; s <= FL_RAY_STEPS; s += 1) {

            var frac    = s / FL_RAY_STEPS;
            var dist_nm = dist_nm_row * frac;
            var dist_ft = dist_nm * FL_FT_PER_NM;
            var total_tilt = pitch + antenna_tilt;
            var ray_alt = alt_ft + math.tan(FL_DEG2RAD * total_tilt) * dist_ft;
            
            var testlat = base_lat + (dist_nm * math.cos(FL_DEG2RAD * heading) / 60);
            var testlon = base_lon + (dist_nm * math.sin(FL_DEG2RAD * heading) / 60);

            var terr = FL_get_elevation(testlat, testlon);

            if (terr >= ray_alt and terr >= 0) {
                hit = terr;
                break;
            }
        }

        setprop(FL_TERRAIN ~ "row[" ~ row ~ "]/col[" ~ col ~ "]/elevation-ft", hit);
    }

    for (var col = 1; col < FL_MAX_COL; col += 2) {
        var a = getprop(FL_TERRAIN ~ "row[" ~ row ~ "]/col[" ~ (col-1) ~ "]/elevation-ft");
        var b = getprop(FL_TERRAIN ~ "row[" ~ row ~ "]/col[" ~ (col+1) ~ "]/elevation-ft");
        setprop(FL_TERRAIN ~ "row[" ~ row ~ "]/col[" ~ col ~ "]/elevation-ft", (a + b) / 2);
    }

    FL_row += 1;
    if (FL_row > FL_MAX_ROW) FL_row = 0;
}

var FL_loop = func {
    FL_update();
    settimer(FL_loop, 0.02);
}

var FL_syncLoop = func {
    FL_syncTerrainMap();
    settimer(FL_syncLoop, 0.3);
}

setlistener("sim/signals/fdm-initialized", func {
    print("Forward Looking Terrain Radar READY");
    FL_loop();
    FL_syncLoop();
});

#================================================================
#                 MAGNETIC ANOMALY DETECTOR Mode
#================================================================

var MAD_PATH = "/instrumentation/mad/pixels/";
var MAD_SIZE = 100;
var MAD_RATE = 0.1;

var MAD_RANGE_LAT = 0.01;   # 1.1 km
var MAD_RANGE_LON = 0.01;
var MAD_RANGE_ALT = 3000;   # in ft, with AGL

for (var i = 0; i < MAD_SIZE; i += 1) {
    setprop(MAD_PATH ~ "col[" ~ i ~ "]/elevation", 0);
}

var MAD_getTargets = func {

    var root = props.globals.getNode("ai/models/");
    var targetList = [];

    if (root == nil) return targetList;

    foreach (var t; root.getChildren("aircraft")) {
        append(targetList, t);
    }

    foreach (var t; root.getChildren("multiplayer")) {
        append(targetList, t);
    }

    foreach (var t; root.getChildren("carrier")) {
        append(targetList, t);
    }

    return targetList;
}

var MAD_update = func {

    var lat = getprop("/position/latitude-deg");
    var lon = getprop("/position/longitude-deg");
    var alt_agl = getprop("/position/altitude-agl-ft");
    if (alt_agl == nil) alt_agl = 0;

    if (alt_agl > MAD_RANGE_ALT) {

    for (var i = 0; i < MAD_SIZE; i += 1) {
        setprop(MAD_PATH ~ "col[" ~ i ~ "]/elevation", 0);
    }

    return;
    }

    var heading = getprop("/orientation/heading-magnetic-deg") * 0.01745329252;

    var targets = MAD_getTargets();

    for (var i = 0; i < MAD_SIZE; i += 1) {
        setprop(MAD_PATH ~ "col[" ~ i ~ "]/elevation", 0);
    }

    foreach (var m; targets) {

        var name  = m.getName();
        var index = m.getIndex();

        var base = "ai/models/" ~ name ~ "[" ~ index ~ "]/";

        var tlat = getprop(base ~ "position/latitude-deg");
        var tlon = getprop(base ~ "position/longitude-deg");
        var talt = getprop(base ~ "position/altitude-ft");

        if (tlat == nil or tlon == nil) continue;
        if (talt == nil) talt = 0;

        var dlat = tlat - lat;
        var dlon = tlon - lon;

        var scale = math.cos(lat * 0.01745329252);
        if (scale < 0.01) scale = 0.01;

        var x = -( (dlon * scale) * math.cos(heading)
                 + (dlat)         * math.sin(heading) );

        var y = -(dlon * scale) * math.sin(heading)
               + (dlat)         * math.cos(heading);

        var alt = getprop("/position/altitude-ft");
        var dalt = alt - talt;

        if (math.abs(x) < MAD_RANGE_LON and
            math.abs(y) < MAD_RANGE_LAT and
            math.abs(dalt) < MAD_RANGE_ALT) {

            var pos = int((x / MAD_RANGE_LON + 0.5) * MAD_SIZE);

            if (pos < 0) pos = 0;
            if (pos >= MAD_SIZE) pos = MAD_SIZE - 1;

            var dist = math.sqrt(x*x + y*y);

            var norm = 1 - (dist / MAD_RANGE_LAT);
            if (norm < 0) norm = 0;

            var strength = norm * 0.09 + rand() * 0.02;

            setprop(MAD_PATH ~ "col[" ~ pos ~ "]/elevation", strength);
        }
    }

    for (var i = 0; i < MAD_SIZE; i += 5) {
        var noise = (rand() - 0.5) * 0.01;
        setprop(MAD_PATH ~ "col[" ~ i ~ "]/elevation",
            getprop(MAD_PATH ~ "col[" ~ i ~ "]/elevation") + noise
        );
    }
}

var MAD_loop = func {
    MAD_update();
    settimer(MAD_loop, MAD_RATE);
}

MAD_loop();

