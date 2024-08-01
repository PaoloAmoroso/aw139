# NAV Comm settings

var inc_freq = func() {
  var f = getprop( "instrumentation/nav/frequencies/selected-mhz" );
  if ( f<129.95 ) {
    setprop( "instrumentation/nav/frequencies/selected-mhz", f+0.05 );
    setprop( "controls/switches/arn82/right", getprop( "controls/switches/arn82/right" )+1 );
    update_khz();
  }
} #inc_freq()

var dec_freq = func() {
  var f = getprop( "instrumentation/nav/frequencies/selected-mhz" );
  if ( f>=108.05 ) {
    setprop( "instrumentation/nav/frequencies/selected-mhz", f-0.05 );
    setprop( "controls/switches/arn82/right", getprop( "controls/switches/arn82/right" )-1 );
    update_khz();
  }
} #dec_freq()

var update_khz = func() {
  setprop( "instrumentation/nav/frequencies/selected-khz", getprop( "instrumentation/nav/frequencies/selected-mhz" )*100 );
} #update_khz()

var adjustnavfreq = func( x ) {
  var fnew = getprop( "instrumentation/nav/frequencies/selected-mhz" )+x;

  if ( fnew>107.95 and fnew<129.05 ) {
    setprop( "instrumentation/nav/frequencies/selected-mhz", fnew );
    setprop( "controls/switches/arn82/left", getprop( "controls/switches/arn82/left" )+x );
  }
} #adjustnavfreq()

var adjust_volume = func() {
  setprop( "instrumentation/nav/volume", getprop( "controls/switches/arn82/vol" )/10 );
} #adjust_volume()


var switch_pwr_btn = func() {
  setprop( "instrumentation/nav/serviceable", getprop( "systems/electrical/outputs/nav" )==0 ? "false" : "true" );
} #switch_pwr_btn()

update_khz();
setlistener( "instrumentation/nav/frequencies/selected-mhz", func{ update_khz() } );
setlistener( "controls/switches/arn82/vol", func{ adjust_volume() } );
setlistener( "systems/electrical/outputs/nav_comm", func{ switch_pwr_btn() } );
setlistener( "instrumentation/nav/frequencies/selected-khz",

func{ setprop( "instrumentation/nav/frequencies/selected-mhz", getprop( "instrumentation/nav/frequencies/selected-khz" )/100 ) } );
