# UHF Comm settings

var updateuhfdisplay = func() {
  var f = getprop( "instrumentation/comm[1]/frequencies/selected-mhz" );
  var freqstr = sprintf( "%6.2f", f );
  var freqarr = split( ".", freqstr );

  if ( f<100.0 ) {
    freqstr = "0"~freqstr;
  } else if( f<10.0 ) {
    freqstr = "00"~freqstr;
  }

  setprop( "controls/switches/arc51bx/freq_tk", substr( freqarr[1], 1, 1 ) );
  setprop( "controls/switches/arc51bx/freq_kk", substr( freqarr[1], 0, 1 ) );
  setprop( "controls/switches/arc51bx/freq_m",  substr( freqarr[0], 2, 1 ) );
  setprop( "controls/switches/arc51bx/freq_tm", substr( freqarr[0], 1, 1 ) );
  setprop( "controls/switches/arc51bx/freq_km", substr( freqarr[0], 0, 1 ) );
} #updateuhfdisplay()

var adjustuhffreq = func( x ) {
  var f = getprop( "instrumentation/comm[1]/frequencies/selected-mhz" );

  if ( x+f>=100.0 and x+f<=399.99 ) {
    setprop( "instrumentation/comm[1]/frequencies/selected-mhz", f+x );
    updateuhfdisplay();
  }
} #adjustuhffreq()

var adjust_volume = func() {
  setprop( "instrumentation/comm[1]/volume", getprop( "controls/switches/arc51bx/volume" )/100 );
} #adjust_volume()

var switch_pwr_btn = func() {
  setprop( "instrumentation/comm[1]/serviceable", getprop( "systems/electrical/outputs/uhf_comm" )==0 ? "false" : "true" );
} #switch_pwr_btn()

updateuhfdisplay();
setlistener( "instrumentation/comm[1]/frequencies/selected-mhz", func{ updateuhfdisplay() } );
setlistener( "systems/electrical/outputs/uhf_comm", func{ switch_pwr_btn() } );
setlistener( "controls/switches/arc51bx/volume", func{ adjust_volume() } );
