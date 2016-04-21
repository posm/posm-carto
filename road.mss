// ---------------------------------------------------------------------

// =====================================================================
// ROAD COLORS
// =====================================================================

@caseMotorway:  #40006a;
@fillMotorway:  #903777;

@caseTrunk:     #5f016a;
@fillTrunk:     #b0569e;

@casePrimary:   #78054e;
@fillPrimary:   #b7658b;

@caseSecondary: #7e0c5e;
@fillSecondary: #db96ad;

@caseTertiary:  #5b255c;
@fillTertiary:  #ede0ed;

@caseStreet:    #6a6a6a;
@fillStreet:    #fffdff;

@path_line:     #323232;


/* Just a skeleton for context */
/*
#road, #bridge, #tunnel {
  line-color: gray;
  line-width: 3;
}
*/
#road_area[zoom>=12] {
  polygon-fill: @fillStreet;
  line-color: @caseStreet;
  line-width: 1;
}

// Roads are split across 3 layers: #road, #bridge, and #tunnel. Each
// road segment will only exist in one of the three layers. The
// #bridge layer makes use of Mapnik's group-by rendering mode;
// attachments in this layer will be grouped by layer for appropriate
// rendering of multi-level overpasses.

// The main road style is for all 3 road layers and divided into 2 main
// attachments. The 'case' attachment is 

#road, #bridge, #tunnel {
  ::case[zoom>=3] {
    [type='motorway'][zoom>=5] {
      line-join:round;
      line-color: @caseMotorway;
      #road { line-cap: round; }
      #tunnel { line-dasharray:3,2; }
      line-width:0.75;
      [zoom<=8] { line-opacity: 0.5; }
      [zoom>=6]  { line-width:1.25; }
      [zoom>=7]  { line-width:2; }
      [zoom>=8] { line-width:3; }
      [zoom>=10]  { line-width:4; }
      [zoom>=13] { line-width:4.5;  }
      [zoom>=14] { line-width:6.5; }
      [zoom>=15] { line-width:8.5; }
      [zoom>=16] { line-width:11; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:12; }
      [zoom>=19] { line-width:24; }
      [zoom>=20] { line-width:48; }
      [zoom>=21] { line-width:96; }
      [zoom>=22] { line-width:192; }
    }
    [type='motorway_link'][zoom>=13] {
      line-join:round;
      line-color: @caseMotorway;
      #road { line-cap: round; }
      #tunnel { line-dasharray:3,2; }
      [zoom>=13] { line-width:1; }
      [zoom>=14] { line-width:3; }
      [zoom>=15] { line-width:5; }
      [zoom>=16] { line-width:6.5; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:8; }
      [zoom>=19] { line-width:16; }
      [zoom>=20] { line-width:32; }
      [zoom>=21] { line-width:64; }
      [zoom>=22] { line-width:128; }
    }
    [type='trunk'] {
      line-join:round;
      line-color: @caseTrunk;
      #road { line-cap: round; }
      #tunnel { line-dasharray:3,2; }
      [zoom<=10] { line-opacity: 0.5; }
      [zoom>=6] { line-width:0.5; }
      [zoom>=7] { line-width:0.8; }
      [zoom>=10] { line-width:3.4; }
      [zoom>=13] { line-width:6.5; }
      [zoom>=14] { line-width:8; }
      [zoom>=15] { line-width:9; }
      [zoom>=16] { line-width:12; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:13; }
      [zoom>=19] { line-width:26; }
      [zoom>=20] { line-width:52; }
      [zoom>=21] { line-width:104; }
      [zoom>=22] { line-width:208; }
    }
    [type='trunk_link'][zoom>=13] {
      line-join:round;
      line-color: @caseTrunk;
      #road { line-cap: round; }
      #tunnel { line-dasharray:3,2; }
      [zoom>=10] { line-width:0.8; }
      [zoom>=13] { line-width:3.4; }
      [zoom>=14] { line-width:6.5; }
      [zoom>=15] { line-width:8; }
      [zoom>=16] { line-width:9; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:10; }
      [zoom>=19] { line-width:20; }
      [zoom>=20] { line-width:40; }
      [zoom>=21] { line-width:80; }
      [zoom>=22] { line-width:160; }
    }
    [type='primary'],
    [type='primary_link']{
      line-join:round;
      line-color: @casePrimary;
      #road { line-cap: round; }
      #tunnel { line-dasharray:3,2; }
      [zoom<=8] { line-opacity: 0.5; }
      [zoom>=6] { line-width:0.2; }
      [zoom>=7] { line-width:0.4; }
      [zoom>=8] { line-width:1.5; }
      [zoom>=10] { line-width:2.4; }
      [zoom>=13] { line-width:4.5; }
      [zoom>=14] { line-width:5.5; }
      [zoom>=15] { line-width:6.5; }
      [zoom>=16] { line-width:8.5; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:10; }
      [zoom>=19] { line-width:20; }
      [zoom>=20] { line-width:40; }
      [zoom>=21] { line-width:80; }
      [zoom>=22] { line-width:160; }
    }
    [type='secondary'],
    [type='secondary_link']{
      line-join:round;
      line-color: @caseSecondary;
      line-width:1;
      #road { line-cap: round; }
      #tunnel { line-dasharray:3,2; }
      [zoom<=13] { line-opacity: 0.5; }
      [zoom>=13] { line-width:2.5; }
      [zoom>=14] { line-width:4; }
      [zoom>=15] { line-width:5; }
      [zoom>=16] { line-width:7.5; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:9; }
      [zoom>=19] { line-width:18; }
      [zoom>=20] { line-width:36; }
      [zoom>=21] { line-width:72; }
      [zoom>=22] { line-width:144; }
    }
    [type='tertiary'],
    [type='tertiary_link']{
      line-join:round;
      line-color: @caseTertiary;
      line-width:1;
      #road { line-cap: round; }
      #tunnel { line-dasharray:3,2; }
      [zoom<=13] { line-opacity: 0.5; }
      [zoom>=13] { line-width:2.3; }
      [zoom>=14] { line-width:3.8; }
      [zoom>=15] { line-width:4.8; }
      [zoom>=16] { line-width:6.8; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:8; }
      [zoom>=19] { line-width:16; }
      [zoom>=20] { line-width:32; }
      [zoom>=21] { line-width:64; }
      [zoom>=22] { line-width:128; }
    }
    [type='unclassified'],[type='residential'],[type='living_street'][zoom>=10] {
      line-join:round;
      #road { line-cap: round; }
      #tunnel { line-dasharray:3,2; }
      line-color: @caseStreet;
      [zoom<=13] { line-opacity: 0.5; }
      [zoom>=10] { line-width:0.5; }
      [zoom>=14] { line-width:3; }
      [zoom>=15] { line-width:3.5; }
      [zoom>=16] { line-width:5.5; }

      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:7; }
      [zoom>=19] { line-width:14; }
      [zoom>=20] { line-width:28; }
      [zoom>=21] { line-width:56; }
      [zoom>=22] { line-width:112; }
    }
    [type='service'][zoom>=10],
    [type='pedestrian'][zoom>=12],
    [type='track'][zoom>=10] {
      #tunnel { line-opacity: 0.2; }
      line-color: @caseStreet;
      [zoom<=13] { line-opacity: 0.5; }
      [zoom>=10] { line-width:0.2; }
      [zoom>=14] { line-width:2.8; }
      [zoom>=15] { line-width:3.3; }
      [zoom>=16] { line-width:5.3; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=18] { line-width:6; }
      [zoom>=19] { line-width:12; }
      [zoom>=20] { line-width:24; }
      [zoom>=21] { line-width:48; }
      [zoom>=22] { line-width:96; }
      [type='track'] { 
        line-dasharray: 11,3; 
        line-join: miter; 
        line-cap: butt; }
    }
    [type='steps'][zoom>=14] {
      line-color: @path_line;
      line-opacity: 0.7;
      line-dasharray: 1.5, 0.5;
      line-width: 1.4;
      [zoom>=15] { line-width: 1.9; line-dasharray: 2, 0.75; }
      [zoom>=16] { line-width: 2.5; line-dasharray: 3, 1; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=19] { line-width:4; }
      [zoom>=20] { line-width:8; }
      [zoom>=21] { line-width:16; }
      [zoom>=22] { line-width:32; }
    }
    [type='footway'][zoom>=14],
    [type='cycleway'][zoom>=14],
    [type='path'][zoom>=14] {
      line-color: @path_line;
      line-opacity: 0.7;
      line-dasharray: 6, 1.5;
      line-width: 0.75;
      [zoom>=15] { line-width: 0.9; line-dasharray: 7, 2.5; }
      [zoom>=16] { line-width: 1.4; line-dasharray: 8, 3; }
      // begin simulated real-world sizes (z18 ~= 0.6 m / px)
      [zoom>=19] { line-width:4; line-dasharray: 16, 4; }
      [zoom>=20] { line-width:8; line-dasharray: 32, 8; }
      [zoom>=21] { line-width:16; line-dasharray: 64, 16; }
      [zoom>=22] { line-width:32; line-dasharray: 128, 32; }
    }
  }
  ::fill[zoom>=6] {
    [type='motorway'][zoom>=8] {
      line-join:round;
      #road, #bridge { line-cap:round; }
      line-color:@fillMotorway;
      #tunnel { line-color:lighten(@fillMotorway,4); }
      [zoom>=8] { line-width:1.5; }
      [zoom>=10] { line-width:2; }
      [zoom>=13] { line-width:2.5; }
      [zoom>=14] { line-width:3.5; }
      [zoom>=15] { line-width:5; }
      [zoom>=16] { line-width:7; }
      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:9; }
      [zoom>=19] { line-width:21; }
      [zoom>=20] { line-width:45; }
      [zoom>=21] { line-width:93; }
      [zoom>=22] { line-width:189; }
    }
    [type='motorway_link'][zoom>=14] {
      line-join:round;
      #road, #bridge { line-cap: round; }
      line-color: @fillMotorway;
      //[zoom<=14] { line-color: darken(@motorway, 10); }
      #tunnel {  line-color:lighten(@fillMotorway, 4); }
      [zoom>=14] { line-width:1.5; }
      [zoom>=15] { line-width:3; }
      [zoom>=16] { line-width:4.5; }
      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:5; }
      [zoom>=19] { line-width:13; }
      [zoom>=20] { line-width:29; }
      [zoom>=21] { line-width:61; }
      [zoom>=22] { line-width:125; }
    }
    [type='trunk'] {
      line-join:round;
      line-color: @fillTrunk;
      //[zoom<=14] { line-color: darken(@main, 10); }
      line-width: 0;
      [zoom>=10] { line-width:1.5; }
      [zoom>=13] { line-width:4.0; }
      [zoom>=14] { line-width:5.0; }
      [zoom>=15] { line-width:6.0; }
      [zoom>=16] { line-width:9.0; }
      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:10; }
      [zoom>=19] { line-width:23; }
      [zoom>=20] { line-width:49; }
      [zoom>=21] { line-width:101; }
      [zoom>=22] { line-width:205; }
      #road, #bridge { line-cap: round; }
      #tunnel { line-color:lighten(@fillTrunk,4); }
    }
    [type='trunk_link'][zoom>=13] {
      line-join:round;
      line-color: @fillTrunk;
      //[zoom<=14] { line-color: darken(@main, 10); }
      line-width: 0;
      [zoom>=13] { line-width:2.5; }
      [zoom>=14] { line-width:4.0; }
      [zoom>=15] { line-width:5.0; }
      [zoom>=16] { line-width:6.0; }
      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:7; }
      [zoom>=19] { line-width:17; }
      [zoom>=20] { line-width:37; }
      [zoom>=21] { line-width:77; }
      [zoom>=22] { line-width:157; }
      #road, #bridge { line-cap: round; }
      #tunnel { line-color:lighten(@fillTrunk,4); }
    }
    [type='primary'][zoom>=8],
    [type='primary_link'][zoom>=8] {
      line-join:round;
      line-color:@fillPrimary;
      line-width: 0;
      [zoom>=8] { line-width:0.3; }
      [zoom>=10] { line-width:0.8; }
      [zoom>=12] { line-width:1.2; }
      [zoom>=13] { line-width:2.75; }
      [zoom>=14] { line-width:3.7; }
      [zoom>=15] { line-width:4.2; }
      [zoom>=16] { line-width:5.5; }
      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:7; }
      [zoom>=19] { line-width:17; }
      [zoom>=20] { line-width:37; }
      [zoom>=21] { line-width:77; }
      [zoom>=22] { line-width:157; }
      #road, #bridge { line-cap: round; }
      #tunnel { line-color:lighten(@fillPrimary, 10); }
    }
    [type='secondary'],
    [type='secondary_link']{
      line-join:round;
      #road, #bridge { line-cap: round; }
      line-color:@fillSecondary;
      line-width:0;
      #tunnel { line-color:lighten(@fillSecondary,4); }
      [zoom>=13] { line-width:1.5; }
      [zoom>=14] { line-width:2.5; }
      [zoom>=15] { line-width:3.5; }
      [zoom>=16] { line-width:5.0; }
      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:6; }
      [zoom>=19] { line-width:15; }
      [zoom>=20] { line-width:33; }
      [zoom>=21] { line-width:69; }
      [zoom>=22] { line-width:141; }
    }
    [type='tertiary'],
    [type='tertiary_link']{
      line-join:round;
      #road, #bridge { line-cap: round; }
      line-color:@fillTertiary;
      line-width:0;
      #tunnel { line-color:lighten(@fillTertiary,4); }
      [zoom>=13] { line-width:1.3; }
      [zoom>=14] { line-width:2.3; }
      [zoom>=15] { line-width:3.3; }
      [zoom>=16] { line-width:4.8; }
      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:5; }
      [zoom>=19] { line-width:13; }
      [zoom>=20] { line-width:29; }
      [zoom>=21] { line-width:61; }
      [zoom>=22] { line-width:125; }
    }
    [type='unclassified'],[type='residential'],[type='living_street'][zoom>=14] {
      line-join:round;
      line-color:@fillStreet;
      line-width:0;
      #road, #bridge { line-cap: round; }
      [zoom>=14] { line-width:1.8;  }
      [zoom>=15] { line-width:2;  }
      [zoom>=16] { line-width:3.5; }

      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:4; }
      [zoom>=19] { line-width:11; }
      [zoom>=20] { line-width:25; }
      [zoom>=21] { line-width:53; }
      [zoom>=22] { line-width:109; }
    }
    [type='service'][zoom>=14],
    [type='pedestrian'][zoom>=12],
    [type='track'][zoom>=14] {
      line-color:@fillStreet;
      line-width:0;
      [zoom>=14] { line-width:1.5;  }
      [zoom>=15] { line-width:1.7;  }
      [zoom>=16] { line-width:3.2; }
      // begin simulated real-world sizes (subtract 3px from casing)
      [zoom>=18] { line-width:3.2; }
      [zoom>=19] { line-width:9; }
      [zoom>=20] { line-width:21; }
      [zoom>=21] { line-width:45; }
      [zoom>=22] { line-width:93; }
      [type='track'] { 
        line-dasharray: 11,3; 
        line-join: miter; 
        line-cap: butt; }
    }
  }
}

#railway {
  line-width: 0.9;
  line-color: #444;
  line-opacity: 0.6;
  // Hatching
  h/line-width: 2.5;
  h/line-color: #444;
  h/line-dasharray: 1,7;
  h/line-opacity: 0.6;
  [tunnel='yes'] {
    line-dasharray: 2,2;
    h/line-width: 2;
  }
  [zoom>=16] {
    line-width: 1.5;
    line-color: #444;
    // Hatching
    h/line-width: 8;
    h/line-color: #444;
    h/line-dasharray: 1,15;
    [tunnel='yes'] {
      line-dasharray: 4,4;
      h/line-width: 6;
    }
  }
}
