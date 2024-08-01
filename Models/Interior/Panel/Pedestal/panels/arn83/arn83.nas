# ADF settings

var updateadfdisplay = func() {
  var f = getprop( "instrumentation/adf/frequencies/selected-khz" );
  var b = getprop( "instrumentation/adf/frequencies/freqbandselect" );
  var pos = b==0 ? (f-190)*30 : b==1 ? (f-400)*14 : (f-850)*7;
  setprop( "instrumentation/adf/frequencies/freqpos", pos );
} #updateadfdisplay()


var adjustadffreq = func() {
  var f = getprop( "instrumentation/adf/frequencies/selected-khz" );
  var b = getprop( "instrumentation/adf/frequencies/freqbandselect" );

  if ( b==0 ) {
    if ( arg[0]==1 ) {
      if ( f>190 ) {
        f-=1;
      }
    } else {
      if ( f<400 ) {
        f+=1;
      }
    }
  } else if( b==2 ) {
    if ( arg[0]==1 ) {
      if ( f>850 ) {
        f-=1;
      }
    } else {
      if ( f<1750 ) {
        f+=1;
      }
    }
  } else { #b==1
    if ( arg[0]==1 ) {
      if ( f>400 ) {
        f-=1;
      }
    } else {
      if ( f<850 ) {
        f+=1;
      }
    }
  }

  setprop( "instrumentation/adf/frequencies/selected-khz", f );
  updateadfdisplay();
} #adjustadffreq()

var adjustadfband = func() {
  var b = getprop( "instrumentation/adf/frequencies/freqbandselect" );
  var f = getprop( "instrumentation/adf/frequencies/selected-khz" );

  if ( arg[0]==0 ) { #increase
    if ( b<2 ) {
      b+=1;
    } else {
      return
    }
  } else {           #decrease
    if ( b>0 ) {
      b-=1;
    } else {
      return;
    }
  }

  if ( f==190 ) {
    f = 400;
  } else if( f==400 ) {
    f = b==0 ? 190 : 850;
  } else if( f==850 ) {
    f = b==1 ? 400 : 1750;
  } else if( f==1750 ){
    f = 850;
  } else if( f<400 )  {
    f = (f/210*450)-7.14286;
  } else if( f>850 )  {
    f = (f/2)-25;
  } else              {
    f = b==0 ? (f/450*210)+3.33333 : (f*2)+50;
  }

  setprop( "instrumentation/adf/frequencies/freqbandselect", b );
  setprop( "instrumentation/adf/frequencies/selected-khz", f );

  updateadfdisplay();
} #adjustadfband()

var updateadfband = func() {
  var f = getprop( "instrumentation/adf/frequencies/selected-khz" );
  var b = getprop( "instrumentation/adf/frequencies/freqbandselect" );
  var bnew = f<=400 and b==0 ? 0 : f>=850 and b==2 ? 2 : 1;
  setprop( "instrumentation/adf/frequencies/freqbandselect", bnew );
  updateadfdisplay();
} #updateadfband()

var adjust_volume = func() {
  setprop( "instrumentation/adf/volume-norm", getprop( "controls/switches/arn83/gain" )/10 );
} # adjust_volume()

var switch_pwr_btn = func() {
  var x =  getprop( "systems/electrical/outputs/adf" )==0 ? "false" : "true";
  setprop( "instrumentation/adf/serviceable", x );
  setprop( "instrumentation/adf/power-btn", x );
} #switch_pwr_btn()

setlistener( "instrumentation/adf/frequencies/selected-khz", func{ updateadfband() } );
setlistener( "systems/electrical/outputs/adf", func{ switch_pwr_btn() } );
setlistener( "controls/switches/arn83/gain", func{ adjust_volume() } );
