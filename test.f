\ Test file for JonesForth-64

: DOUBLE DUP + ;
: SQUARE DUP * ;

CR ." === JonesForth-64 Tests ===" CR
." 21 doubled = " 21 DOUBLE . CR
." 7 squared = " 7 SQUARE . CR
." Stack test: " 1 2 3 .S CR
." Done!" CR
