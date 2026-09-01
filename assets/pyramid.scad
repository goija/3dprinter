// =====================================================================
// LICENTIE: Ontwerp en ontwikkeling: Bedrijven en overheid hebben 
// geen toestemming tot gebruik van mijn code.
// =====================================================================
// Model: LFSR-Graaf 111-Array met 13-delige Piramide
// =====================================================================

// --- Parameters ---
aantal_klokstappen = 63;
sub_ringen = 3;
knooppunten_per_ring = aantal_klokstappen / sub_ringen; // 21

radius_ring = 45;
hoogte_stap = 8;

// Klokposities voor de windstreken (uit de transitietabel)
// N: 60, O: 34, Z: 6, W: 19
klok_N = 60;
klok_O = 34;
klok_Z = 6;
klok_W = 19;

// --- Modules ---

// 1. De 13-delige Piramide (Basis / 13 Manen)
module piramide_13() {
    laag_hoogte = 3;
    basis_breedte = 50;
    
    for (i = [0 : 12]) {
        breedte = basis_breedte - (i * 3.5);
        translate([0, 0, i * laag_hoogte])
            cube([breedte, breedte, laag_hoogte], center = true);
    }
}

// 2. De 3 Ontkoppelde LFSR Sub-Ringen (21 knooppunten elk)
module lfsr_ringen() {
    // We roteren de ringen onderling met de geometrische 108 graden
    for (ring = [0 : sub_ringen - 1]) {
        rotate([0, 0, ring * 108]) {
            for (stap = [0 : knooppunten_per_ring - 1]) {
                hoek = stap * (360 / knooppunten_per_ring);
                
                // Bereken de absolute klokstap voor visualisatie-kleur/hoogte
                abs_klok = (ring * knooppunten_per_ring) + stap;
                z_hoogte = (ring * hoogte_stap) + 35; // Plaats boven de piramide
                
                translate([cos(hoek) * radius_ring, sin(hoek) * radius_ring, z_hoogte]) {
                    // Verbindende ringlijnen
                    rotate([0, 90, hoek + 90])
                        cylinder(h = (2 * 3.1415 * radius_ring)/knooppunten_per_ring, r = 0.5, center = true, $fn=12);
                    
                    // Het vertex-knooppunt (toestand)
                    sphere(r = 1.5, $fn=20);
                }
            }
        }
    }
}

// 3. De Windstreken (N, O, Z, W) als kwantumsprong-ankers
module anker_pilaar(klok_positie, label_hoogte, r_factor) {
    // Bepaal op welke ring dit anker valt (0, 1 of 2)
    ring_idx = floor(klok_positie / knooppunten_per_ring);
    lokale_stap = klok_positie % knooppunten_per_ring;
    
    // Bereken de exacte ruimtelijke positie (inclusief de 108° offset per ring)
    basis_hoek = lokale_stap * (360 / knooppunten_per_ring);
    finale_hoek = basis_hoek + (ring_idx * 108);
    z_hoogte = (ring_idx * hoogte_stap) + 35;
    
    x_pos = cos(finale_hoek) * radius_ring * r_factor;
    y_pos = sin(finale_hoek) * radius_ring * r_factor;
    
    // Teken de fysieke ankerpilaar vanuit de basis
    translate([x_pos, y_pos, z_hoogte / 2])
        cylinder(h = z_hoogte, r = 2, center = true, $fn=24);
        
    // Accentueer het scharnierpunt op de ring
    translate([x_pos, y_pos, z_hoogte])
        cube([4, 4, 4], center = true);
}

// 4. Samenstelling van het systeem
module hoofd_assemblage() {
    // Basis
    piramide_13();
    
    // De 3 LFSR banen
    lfsr_ringen();
    
    // Plaatsing van de 4 windstreken/ankers
    anker_pilaar(klok_N, 50, 1.0); // Noord
    anker_pilaar(klok_O, 50, 1.0); // Oost
    
    // Zuid ligt exact op Hotspot 1.324 (Klok 6)
    anker_pilaar(klok_Z, 50, 1.05); // Iets verdikt/verplaatst om Hotspot te markeren
    
    // West (Nucleaire Scharnier)
    anker_pilaar(klok_W, 50, 1.0); 
}

// Render
hoofd_assemblage();
