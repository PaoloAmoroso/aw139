var adjust_volume = func() {
  setprop( "sim/sound/volume", getprop( "controls/switches/c6533/volume" )/100 );
} #adjust_volume()

setlistener( "controls/switches/c6533/volume", func{ adjust_volume() } );
