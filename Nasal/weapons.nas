######################################################################
###                                                                ###
###                Guns fire only if view is done                  ###
###                                                                ###
### BARANGER Emmanuel aka Helijah 04/10/2024                      ###   Adapted by AMOROSO Paolo    24/10/2024
######################################################################

fire_MG = func {
  var CurrentView = getprop("sim/current-view/view-number-raw");
  if ( CurrentView == 0 ) {
    setprop("controls/armament/trigger", 1);
  } elsif ( CurrentView == 101 ) {
    setprop("controls/armament/trigger1", 1);
  } elsif ( CurrentView == 102 ) {
    setprop("controls/armament/trigger2", 1);
    }
  }
}

stop_MG = func {
  setprop("controls/armament/trigger", 0);
  setprop("controls/armament/trigger1", 0);
  setprop("controls/armament/trigger2", 0);
}
