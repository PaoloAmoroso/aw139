# Transponder settings

var setdigit = func( d, e ) {
  var x = getprop( d );

  if ( e ) {
    x+=1;
    if ( x>7 ) {
      x=0;
    }
  } else {
    x-=1;
    if ( x<0 ) {
      x=7;
    }
  }
  setprop( d, x );
} #setdigit()

setlistener( "systems/electrical/outputs/transponder", func {
  if ( getprop( "systems/electrical/outputs/transponder" )>0 ) {
    setprop( "instrumentation/transponder/serviceable", "true" );
    setprop( "instrumentation/transponder/inputs/serviceable", "true" );
  } else {
    setprop( "instrumentation/transponder/serviceable", "false" );
    setprop( "instrumentation/transponder/inputs/serviceable", "false" );
  }
} );
