# =======================
# Multiplayer Quirks - PAOLO AMOROSO
# =======================
MPjoin = func(n) {
  #print(n.getValue(), " added");
  setprop("instrumentation/radar",n.getValue(),"radar/y-shift",0);
  setprop("instrumentation/radar",n.getValue(),"radar/x-shift",0);
  setprop("instrumentation/radar",n.getValue(),"radar/rotation",0);
  setprop("instrumentation/radar",n.getValue(),"radar/in-range",0);
  setprop("instrumentation/radar",n.getValue(),"radar/h-offset",180);
  setprop("instrumentation/radar",n.getValue(),"joined",1);
}

MPleave= func(n) {
  #print(n.getValue(), " removed");
  setprop("instrumentation/radar",n.getValue(),"radar/in-range",0);
  setprop("instrumentation/radar",n.getValue(),"joined",0);
}

#need to copy the properties so that we never try to access a non-existent property in XML
MPradarProperties = func {
  targetList= props.globals.getNode("ai/models/").getChildren("multiplayer");

  foreach (d; props.globals.getNode("ai/models/").getChildren("aircraft")) {
    append(targetList,d);
  }

  foreach (m; targetList) {
    var string = "instrumentation/radar/ai/models/"~m.getName()~"["~m.getIndex()~"]/";
    if (getprop(string,"joined")==1 or m.getName()=="aircraft") {
      factor = getprop("instrumentation/radar/range-factor");
      setprop(string,"radar/y-shift",m.getNode("radar/y-shift").getValue() * factor);
      setprop(string,"radar/x-shift",m.getNode("radar/x-shift").getValue() * factor);
      setprop(string,"radar/rotation",m.getNode("radar/rotation").getValue());
      setprop(string,"radar/h-offset",m.getNode("radar/h-offset").getValue());

      if (getprop("instrumentation/radar/selected")==2){
        if (getprop(string~"radar/x-shift") < -0.04 or
          getprop(string~"radar/x-shift") > 0.04) {
          setprop(string,"radar/in-range",0);
        } else {
          setprop(string,"radar/in-range",m.getNode("radar/in-range").getValue());
        }
      } else {
        setprop(string,"radar/in-range",m.getNode("radar/in-range").getValue());
      }
    }
  }

  # this is a good place to deal with the range scaling factors
  if (getprop("instrumentation/radar/selected")==2) {
    if (getprop("instrumentation/radar/range")==10) {
      setprop("instrumentation/radar/range",20);
      setprop("instrumentation/radar/range-factor",0.002);
    } elsif (getprop("instrumentation/radar/range")==20) {
      setprop("instrumentation/radar/range-factor",0.003246);
    } else { #40
      setprop("instrumentation/radar/range-factor",0.001623);
    }
  } elsif (getprop("instrumentation/radar/selected")==3 or getprop("instrumentation/radar/selected")==4) {
    if (getprop("instrumentation/radar/range")==40) {
      setprop("instrumentation/radar/range",20);
      setprop("instrumentation/radar/range-factor",0.001888);
    } elsif (getprop("instrumentation/radar/range")==20) {
      setprop("instrumentation/radar/range-factor",0.001888);
    } else { #10
      setprop("instrumentation/radar/range-factor",0.003776);
    }
  }
  settimer(MPradarProperties,0.05);
}

# ===================
# Boresight Detecting
# ===================
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

	# Multiplayer TCAS
	
	for (var n = 0; n < 30; n += 1) {
	
		if (getprop("ai/models/multiplayer[" ~ n ~ "]/valid") and (getprop("ai/models/multiplayer[" ~ n ~ "]/callsign") != nil)) {
		
			var mp_lat = getprop("ai/models/multiplayer[" ~ n ~ "]/position/latitude-deg");
			var mp_lon = getprop("ai/models/multiplayer[" ~ n ~ "]/position/longitude-deg");
			var x_dist = (mp_lon - pos_lon) * 60;
			var y_dist = (mp_lat - pos_lat) * 60;
			
			var distance =  math.sqrt((x_dist*x_dist) + (y_dist*y_dist));
			
			setprop("instrumentation/radar/mp[" ~ n ~ "]/distance-nm", distance);
			
			setprop("instrumentation/radar/mp[" ~ n ~ "]/bearing-defl",Deflection((57.2957795 * math.atan2(x_dist, y_dist)), 60));

			setprop("instrumentation/radar/mp[" ~ n ~ "]/bearing-deg" ,(57.2957795 * math.atan2(x_dist, y_dist)));
			
			var vsfps = getprop("ai/models/multiplayer[" ~ n ~ "]/velocities/vertical-speed-fps");
			
			var altitudediff = getprop("ai/models/multiplayer[" ~ n ~ "]/position/altitude-ft") - altitude;
			
			## The new NDs only use planar calculations
			
			setprop("instrumentation/radar/mp[" ~ n ~ "]/xoffset", (mp_lon - pos_lon) * 60 / range);
			setprop("instrumentation/radar/mp[" ~ n ~ "]/yoffset", (mp_lat - pos_lat) * 60 / range);
			
			setprop("instrumentation/radar/mp[" ~ n ~ "]/callsign", getprop("ai/models/multiplayer[" ~ n ~ "]/callsign"));
			
			setprop("instrumentation/radar/mp[" ~ n ~ "]/altitude-ft", getprop("ai/models/multiplayer[" ~ n ~ "]/position/altitude-ft"));
			
			setprop("instrumentation/radar/mp[" ~ n ~ "]/tas-kt", getprop("ai/models/multiplayer[" ~ n ~ "]/velocities/true-airspeed-kt"));
			
			
			if (vsfps < -8)
				setprop("instrumentation/radar/mp[" ~ n ~ "]/phase", "descend");
			elsif (vsfps >= 8)
				setprop("instrumentation/radar/mp[" ~ n ~ "]/phase", "climb");
			else
				setprop("instrumentation/radar/mp[" ~ n ~ "]/phase", "level");
				
			if ((distance <= 3) and (altitudediff <= 1000))
				setprop("instrumentation/radar/mp[" ~ n ~ "]/color", "red");
			elsif ((distance <= 5) and (altitudediff <= 2000))
				setprop("instrumentation/radar/mp[" ~ n ~ "]/color", "orange");
			elsif ((distance <= 10) and (altitudediff <= 3000))
				setprop("instrumentation/radar/mp[" ~ n ~ "]/color", "yellow");
			else
				setprop("instrumentation/radar/mp[" ~ n ~ "]/color", "cyan");
			
			if (distance <= 32)
				setprop("/instrumentation/radar/mp[" ~ n ~ "]/show-half", 1);
			else
				setprop("/instrumentation/radar/mp[" ~ n ~ "]/show-half", 0);
				
			if ((math.abs((mp_lon - pos_lon) * 60) <= range) and (mp_lat - pos_lat <= range) and (pos_lat - mp_lat >= (range * -0.8)))
				setprop("/instrumentation/radar/mp[" ~ n ~ "]/show", 1);
			else
				setprop("/instrumentation/radar/mp[" ~ n ~ "]/show", 0);
				
		} else
			setprop("/instrumentation/radar/mp[" ~ n ~ "]/show", 0);
	
	}
	
	# AI TCAS
	
	for (var n = 0; n < 30; n += 1) {
	
		if (getprop("ai/models/aircraft[" ~ n ~ "]/valid") and (getprop("ai/models/aircraft[" ~ n ~ "]/callsign") != nil)) {
		
			var ai_lat = getprop("ai/models/aircraft[" ~ n ~ "]/position/latitude-deg");
			var ai_lon = getprop("ai/models/aircraft[" ~ n ~ "]/position/longitude-deg");
			
			var x_dist = (ai_lon - pos_lon) * 60;
			var y_dist = (ai_lat - pos_lat) * 60;
			
			var distance =  math.sqrt((x_dist*x_dist) + (y_dist*y_dist));
			
			setprop("instrumentation/radar/ai[" ~ n ~ "]/distance-nm", distance);
			
			var vsfps = getprop("ai/models/aircraft[" ~ n ~ "]/velocities/vertical-speed-fps");
			
			setprop("instrumentation/radar/ai[" ~ n ~ "]/bearing-defl",Deflection((57.2957795 * math.atan2(x_dist, y_dist)), 60));

			setprop("instrumentation/radar/ai[" ~ n ~ "]/bearing-deg" ,(57.2957795 * math.atan2(x_dist, y_dist)));
			
			var altitudediff = getprop("ai/models/aircraft[" ~ n ~ "]/position/altitude-ft") - altitude;
			
			## The new NDs only use planar calculations
			
			setprop("instrumentation/radar/ai[" ~ n ~ "]/xoffset", x_dist / range);
			setprop("instrumentation/radar/ai[" ~ n ~ "]/yoffset", y_dist / range);
			
			if (vsfps < -8)
				setprop("instrumentation/radar/ai[" ~ n ~ "]/phase", "descend");
			elsif (vsfps >= 8)
				setprop("instrumentation/radar/ai[" ~ n ~ "]/phase", "climb");
			else
				setprop("instrumentation/radar/ai[" ~ n ~ "]/phase", "level");
				
			if ((distance <= 3) and (altitudediff <= 1000))
				setprop("instrumentation/radar/ai[" ~ n ~ "]/color", "red");
			elsif ((distance <= 5) and (altitudediff <= 2000))
				setprop("instrumentation/radar/ai[" ~ n ~ "]/color", "orange");
			elsif ((distance <= 10) and (altitudediff <= 3000))
				setprop("instrumentation/radar/ai[" ~ n ~ "]/color", "yellow");
			else
				setprop("instrumentation/radar/ai[" ~ n ~ "]/color", "cyan");
				
			if ((math.abs((ai_lon - pos_lon) * 60) <= range) and (ai_lat - pos_lat <= range) and (pos_lat - ai_lat >= (range * -0.8)))
				setprop("/instrumentation/radar/ai[" ~ n ~ "]/show", 1);
			else
				setprop("/instrumentation/radar/ai[" ~ n ~ "]/show", 0);
				
			if (distance <= 32)
				setprop("/instrumentation/radar/ai[" ~ n ~ "]/show-half", 1);
			else
				setprop("/instrumentation/radar/ai[" ~ n ~ "]/show-half", 0);
				
			setprop("instrumentation/radar/ai[" ~ n ~ "]/callsign", getprop("ai/models/aircraft[" ~ n ~ "]/callsign"));
			
			setprop("instrumentation/radar/ai[" ~ n ~ "]/altitude-ft", getprop("ai/models/aircraft[" ~ n ~ "]/position/altitude-ft"));
			
			setprop("instrumentation/radar/ai[" ~ n ~ "]/tas-kt", getprop("ai/models/aircraft[" ~ n ~ "]/velocities/true-airspeed-kt"));
				
		} else
			setprop("/instrumentation/radar/ai[" ~ n ~ "]/show", 0);
	
	}
	
    },
        reset : func {
            me.loopid += 1;
            me._loop_(me.loopid);
        },
        _loop_ : func(id) {
            id == me.loopid or return;
            me.update();
            settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
        }

    }

setlistener("ai/models/model-added", MPjoin);
setlistener("ai/models/model-removed", MPleave);
settimer(MPradarProperties,1.0);
settimer(boreSightLock, 1.0);
