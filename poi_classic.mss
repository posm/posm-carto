// =====================================================================
// POINTS OF INTEREST
// =====================================================================

#poi_label {
  [zoom>=18] {
    ::icon[maki!=""] {
      marker-fill:#000;
      marker-line-width: 0;
      [zoom<19] {
        marker-file:url('img/maki/[maki]-18.svg');
        marker-width: 15; 
      }
      [zoom>=19] {
        marker-file:url('img/maki/[maki]-24.svg');
        marker-width: 20;
        marker-ignore-placement: true;
      }
    }
    ::label[name!=""] {
      text-name: [name];
      text-face-name: @sans_italic;
      text-size: 10;
      text-fill: #000;
      text-halo-radius: 1.2;
      text-wrap-width: 26;
      [maki!=""] {
        text-dy: 8;
      }
    }
  }
}

#null_island {
  marker-file: url('img/buoy.svg');
  marker-line-color: #d33f49;
  marker-width: 64;
}
