# VHF Comm settings

var inc_freq = func() {
  var f = getprop( "instrumentation/comm/frequencies/selected-mhz" );
  if ( f<149.975 ) {
    setprop( "instrumentation/comm/frequencies/selected-mhz", f+0.025 );
    setprop( "controls/switches/arc134/freq_khz", getprop( "controls/switches/arc134/freq_khz" )+1 );
    update_khz();
  }
} #inc_freq()

var dec_freq = func() {
  var f = getprop( "instrumentation/comm/frequencies/selected-mhz" );
  if ( f>116.0 ) {
    setprop( "instrumentation/comm/frequencies/selected-mhz", f-0.025 );
    setprop( "controls/switches/arc134/freq_khz", getprop( "controls/switches/arc134/freq_khz" )-1 );
    update_khz();
  }
} #dec_freq()

var adjustvhffreq = func( x ) {
  var fnew = getprop( "instrumentation/comm/frequencies/selected-mhz" )+x;

  if ( fnew>115.975 and fnew<150.0 ) {
    setprop( "instrumentation/comm/frequencies/selected-mhz", fnew );
    setprop( "controls/switches/arc134/freq_mhz", getprop( "controls/switches/arc134/freq_mhz" )+x );
  }
} #adjustvhffreq()

var update_khz = func() {
  setprop( "instrumentation/comm/frequencies/selected-khz", getprop( "instrumentation/comm/frequencies/selected-mhz" )*1000 );
} #update_khz()

var adjust_volume = func() {
  setprop( "instrumentation/comm/volume", getprop( "controls/switches/arc134/vol" ) / 100 );
} #adjust_volume()

var switch_pwr_btn = func() {
  setprop( "instrumentation/comm/serviceable", getprop( "systems/electrical/outputs/vhf_comm" )==0 ? "false" : "true" );
} #switch_pwr_btn()

update_khz();
setlistener( "instrumentation/comm/frequencies/selected-mhz", func{ update_khz() } );
setlistener( "systems/electrical/outputs/vhf_comm", func{ switch_pwr_btn() } );
setlistener( "controls/switches/arc134/vol", func{ adjust_volume() } );

#######################
##    ARC134 Nr.2    ##
#######################
var inc_freq_2 = func() {
  var f = getprop( "instrumentation/comm[1]/frequencies/selected-mhz" );
  if ( f<149.975 ) {
    setprop( "instrumentation/comm[1]/frequencies/selected-mhz", f+0.025 );
    setprop( "controls/switches/arc134_2/freq_khz", getprop( "controls/switches/arc134_2/freq_khz" )+1 );
    update_khz();
  }
} #inc_freq()

var dec_freq_2 = func() {
  var f = getprop( "instrumentation/comm[1]/frequencies/selected-mhz" );
  if ( f>116.0 ) {
    setprop( "instrumentation/comm[1]/frequencies/selected-mhz", f-0.025 );
    setprop( "controls/switches/arc134_2/freq_khz", getprop( "controls/switches/arc134_2/freq_khz" )-1 );
    update_khz();
  }
} #dec_freq()

var adjustvhffreq_2 = func( x ) {
  var fnew = getprop( "instrumentation/comm[1]/frequencies/selected-mhz" )+x;

  if( fnew>115.975 and fnew<150.0 ){
    setprop( "instrumentation/comm[1]/frequencies/selected-mhz", fnew );
    setprop( "controls/switches/arc134_2/freq_mhz", getprop( "controls/switches/arc134_2/freq_mhz" )+x );
  }
} #adjustvhffreq()

var update_khz_2 = func() {
  setprop( "instrumentation/comm[1]/frequencies/selected-khz", getprop( "instrumentation/comm[1]/frequencies/selected-mhz" )*1000 );
} #update_khz()

var adjust_volume_2 = func() {
  setprop( "instrumentation/comm[1]/volume", getprop( "controls/switches/arc134_2/vol" ) / 100 );
} #adjust_volume()

var switch_pwr_btn_2 = func() {
  setprop( "instrumentation/comm[1]/serviceable", getprop( "systems/electrical/outputs/vhf_comm_2" )==0 ? "false" : "true" );
} #switch_pwr_btn()

update_khz_2();
setlistener( "instrumentation/comm[1]/frequencies/selected-mhz", func{ update_khz_2() } );
setlistener( "systems/electrical/outputs/vhf_comm_2", func{ switch_pwr_btn_2() } );
setlistener( "controls/switches/arc134_2/vol", func{ adjust_volume_2() } );
