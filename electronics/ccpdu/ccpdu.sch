EESchema Schematic File Version 4
LIBS:ccpdu-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:Conn_01x03_Male J1
U 1 1 5C0FAA6A
P 1850 2500
F 0 "J1" H 1800 2500 50  0000 C CNN
F 1 "Conn_01x03_Male" H 1956 2687 50  0001 C CNN
F 2 "Connector_Molex:Molex_KK-254_AE-6410-03A_1x03_P2.54mm_Vertical" H 1850 2500 50  0001 C CNN
F 3 "https://www.molex.com/pdm_docs/sd/022112032_sd.pdf" H 1850 2500 50  0001 C CNN
F 4 "WM2701-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    1850 2500
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x03_Male J2
U 1 1 5C0FACFA
P 1850 2900
F 0 "J2" H 1800 2900 50  0000 C CNN
F 1 "Conn_01x03_Male" H 1956 3087 50  0001 C CNN
F 2 "Connector_Molex:Molex_KK-254_AE-6410-03A_1x03_P2.54mm_Vertical" H 1850 2900 50  0001 C CNN
F 3 "https://www.molex.com/pdm_docs/sd/022112032_sd.pdf" H 1850 2900 50  0001 C CNN
F 4 "WM2701-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    1850 2900
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x03_Male J3
U 1 1 5C0FAD96
P 1850 3300
F 0 "J3" H 1800 3300 50  0000 C CNN
F 1 "Conn_01x03_Male" H 1956 3487 50  0001 C CNN
F 2 "Connector_Molex:Molex_KK-254_AE-6410-03A_1x03_P2.54mm_Vertical" H 1850 3300 50  0001 C CNN
F 3 "https://www.molex.com/pdm_docs/sd/022112032_sd.pdf" H 1850 3300 50  0001 C CNN
F 4 "WM2701-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    1850 3300
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x03_Male J4
U 1 1 5C0FAD9C
P 1850 3700
F 0 "J4" H 1800 3700 50  0000 C CNN
F 1 "Conn_01x03_Male" H 1956 3887 50  0001 C CNN
F 2 "Connector_Molex:Molex_KK-254_AE-6410-03A_1x03_P2.54mm_Vertical" H 1850 3700 50  0001 C CNN
F 3 "https://www.molex.com/pdm_docs/sd/022112032_sd.pdf" H 1850 3700 50  0001 C CNN
F 4 "WM2701-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    1850 3700
	1    0    0    -1  
$EndComp
Text Notes 1650 2200 0    50   ~ 0
Fan Conenctors
$Comp
L power:+12V #PWR08
U 1 1 5C0FB61F
P 2050 3700
F 0 "#PWR08" H 2050 3550 50  0001 C CNN
F 1 "+12V" V 2065 3828 50  0000 L CNN
F 2 "" H 2050 3700 50  0001 C CNN
F 3 "" H 2050 3700 50  0001 C CNN
	1    2050 3700
	0    1    1    0   
$EndComp
$Comp
L power:+12V #PWR06
U 1 1 5C0FB66D
P 2050 3300
F 0 "#PWR06" H 2050 3150 50  0001 C CNN
F 1 "+12V" V 2065 3428 50  0000 L CNN
F 2 "" H 2050 3300 50  0001 C CNN
F 3 "" H 2050 3300 50  0001 C CNN
	1    2050 3300
	0    1    1    0   
$EndComp
$Comp
L power:+12V #PWR04
U 1 1 5C0FB67B
P 2050 2900
F 0 "#PWR04" H 2050 2750 50  0001 C CNN
F 1 "+12V" V 2065 3028 50  0000 L CNN
F 2 "" H 2050 2900 50  0001 C CNN
F 3 "" H 2050 2900 50  0001 C CNN
	1    2050 2900
	0    1    1    0   
$EndComp
$Comp
L power:+12V #PWR02
U 1 1 5C0FB68D
P 2050 2500
F 0 "#PWR02" H 2050 2350 50  0001 C CNN
F 1 "+12V" V 2065 2628 50  0000 L CNN
F 2 "" H 2050 2500 50  0001 C CNN
F 3 "" H 2050 2500 50  0001 C CNN
	1    2050 2500
	0    1    1    0   
$EndComp
NoConn ~ 2050 2600
NoConn ~ 2050 3000
NoConn ~ 2050 3400
NoConn ~ 2050 3800
$Comp
L Connector:Screw_Terminal_01x02 J9
U 1 1 5C0FC984
P 2700 1300
F 0 "J9" H 2780 1292 50  0000 L CNN
F 1 "Screw_Terminal_01x02" H 2780 1201 50  0001 L CNN
F 2 "cc:284391-2" H 2700 1300 50  0001 C CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=284391&DocType=Customer+Drawing&DocLang=English" H 2700 1300 50  0001 C CNN
F 4 "A98159-ND" H 2700 1300 50  0001 C CNN "DigikeyPN"
	1    2700 1300
	-1   0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x02 J10
U 1 1 5C0FD567
P 4650 1300
F 0 "J10" H 4730 1292 50  0000 L CNN
F 1 "Screw_Terminal_01x02" H 4730 1201 50  0001 L CNN
F 2 "cc:284391-2" H 4650 1300 50  0001 C CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=284391&DocType=Customer+Drawing&DocLang=English" H 4650 1300 50  0001 C CNN
F 4 "A98159-ND" H 4650 1300 50  0001 C CNN "DigikeyPN"
	1    4650 1300
	1    0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x02 J11
U 1 1 5C0FD765
P 4650 2000
F 0 "J11" H 4730 1992 50  0000 L CNN
F 1 "Screw_Terminal_01x02" H 4730 1901 50  0001 L CNN
F 2 "cc:284391-2" H 4650 2000 50  0001 C CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=284391&DocType=Customer+Drawing&DocLang=English" H 4650 2000 50  0001 C CNN
F 4 "A98159-ND" H 4650 2000 50  0001 C CNN "DigikeyPN"
	1    4650 2000
	1    0    0    -1  
$EndComp
Wire Wire Line
	4050 1300 4150 1300
$Comp
L Connector:Screw_Terminal_01x02 J12
U 1 1 5C0FD959
P 4650 2700
F 0 "J12" H 4730 2692 50  0000 L CNN
F 1 "Screw_Terminal_01x02" H 4730 2601 50  0001 L CNN
F 2 "cc:284391-2" H 4650 2700 50  0001 C CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=284391&DocType=Customer+Drawing&DocLang=English" H 4650 2700 50  0001 C CNN
F 4 "A98159-ND" H 4650 2700 50  0001 C CNN "DigikeyPN"
	1    4650 2700
	1    0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x02 J13
U 1 1 5C0FD966
P 4650 3400
F 0 "J13" H 4730 3392 50  0000 L CNN
F 1 "Screw_Terminal_01x02" H 4730 3301 50  0001 L CNN
F 2 "cc:284391-2" H 4650 3400 50  0001 C CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=284391&DocType=Customer+Drawing&DocLang=English" H 4650 3400 50  0001 C CNN
F 4 "A98159-ND" H 4650 3400 50  0001 C CNN "DigikeyPN"
	1    4650 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4050 2700 4150 2700
$Comp
L power:GND #PWR025
U 1 1 5C0FC66F
P 4450 1400
F 0 "#PWR025" H 4450 1150 50  0001 C CNN
F 1 "GND" H 4455 1227 50  0000 C CNN
F 2 "" H 4450 1400 50  0001 C CNN
F 3 "" H 4450 1400 50  0001 C CNN
	1    4450 1400
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR026
U 1 1 5C0FDADC
P 4450 2100
F 0 "#PWR026" H 4450 1850 50  0001 C CNN
F 1 "GND" H 4455 1927 50  0000 C CNN
F 2 "" H 4450 2100 50  0001 C CNN
F 3 "" H 4450 2100 50  0001 C CNN
	1    4450 2100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR027
U 1 1 5C0FDB1B
P 4450 2800
F 0 "#PWR027" H 4450 2550 50  0001 C CNN
F 1 "GND" H 4455 2627 50  0000 C CNN
F 2 "" H 4450 2800 50  0001 C CNN
F 3 "" H 4450 2800 50  0001 C CNN
	1    4450 2800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR028
U 1 1 5C0FDB67
P 4450 3500
F 0 "#PWR028" H 4450 3250 50  0001 C CNN
F 1 "GND" H 4455 3327 50  0000 C CNN
F 2 "" H 4450 3500 50  0001 C CNN
F 3 "" H 4450 3500 50  0001 C CNN
	1    4450 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	3650 2000 3600 2000
Wire Wire Line
	3600 2700 3650 2700
Wire Wire Line
	3600 3400 3650 3400
$Comp
L Switch:SW_SPST SW1
U 1 1 5C128DFD
P 3850 1300
F 0 "SW1" H 3850 1535 50  0000 C CNN
F 1 "SW_SPST" H 3850 1444 50  0000 C CNN
F 2 "cc:RS-448-0747" H 3850 1300 50  0001 C CNN
F 3 "https://docs-emea.rs-online.com/webdocs/1585/0900766b8158554d.pdf" H 3850 1300 50  0001 C CNN
	1    3850 1300
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW2
U 1 1 5C12A438
P 3850 2000
F 0 "SW2" H 3850 2235 50  0000 C CNN
F 1 "SW_SPST" H 3850 2144 50  0000 C CNN
F 2 "cc:RS-448-0747" H 3850 2000 50  0001 C CNN
F 3 "https://docs-emea.rs-online.com/webdocs/1585/0900766b8158554d.pdf" H 3850 2000 50  0001 C CNN
	1    3850 2000
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW3
U 1 1 5C12A488
P 3850 2700
F 0 "SW3" H 3850 2935 50  0000 C CNN
F 1 "SW_SPST" H 3850 2844 50  0000 C CNN
F 2 "cc:RS-448-0747" H 3850 2700 50  0001 C CNN
F 3 "https://docs-emea.rs-online.com/webdocs/1585/0900766b8158554d.pdf" H 3850 2700 50  0001 C CNN
	1    3850 2700
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW4
U 1 1 5C12A4D8
P 3850 3400
F 0 "SW4" H 3850 3635 50  0000 C CNN
F 1 "SW_SPST" H 3850 3544 50  0000 C CNN
F 2 "cc:RS-448-0747" H 3850 3400 50  0001 C CNN
F 3 "https://docs-emea.rs-online.com/webdocs/1585/0900766b8158554d.pdf" H 3850 3400 50  0001 C CNN
	1    3850 3400
	1    0    0    -1  
$EndComp
$Comp
L Device:CP1 C5
U 1 1 5C12B9C9
P 4150 3600
F 0 "C5" V 3898 3600 50  0000 C CNN
F 1 "CP1" V 3989 3600 50  0000 C CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 4150 3600 50  0001 C CNN
F 3 "http://nichicon-us.com/english/products/pdfs/e-uvy.pdf" H 4150 3600 50  0001 C CNN
F 4 "493-12902-1-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    4150 3600
	1    0    0    -1  
$EndComp
$Comp
L Device:CP1 C4
U 1 1 5C12BC1C
P 4150 2900
F 0 "C4" V 3898 2900 50  0000 C CNN
F 1 "CP1" V 3989 2900 50  0000 C CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 4150 2900 50  0001 C CNN
F 3 "http://nichicon-us.com/english/products/pdfs/e-uvy.pdf" H 4150 2900 50  0001 C CNN
F 4 "493-12902-1-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    4150 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:CP1 C3
U 1 1 5C12BD2B
P 4150 2200
F 0 "C3" V 3898 2200 50  0000 C CNN
F 1 "CP1" V 3989 2200 50  0000 C CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 4150 2200 50  0001 C CNN
F 3 "http://nichicon-us.com/english/products/pdfs/e-uvy.pdf" H 4150 2200 50  0001 C CNN
F 4 "493-12902-1-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    4150 2200
	1    0    0    -1  
$EndComp
$Comp
L Device:CP1 C2
U 1 1 5C12C8D3
P 4150 1500
F 0 "C2" H 4265 1546 50  0000 L CNN
F 1 "CP1" H 4265 1455 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 4150 1500 50  0001 C CNN
F 3 "http://nichicon-us.com/english/products/pdfs/e-uvy.pdf" H 4150 1500 50  0001 C CNN
F 4 "493-12902-1-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    4150 1500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR021
U 1 1 5C12E7A7
P 4150 1650
F 0 "#PWR021" H 4150 1400 50  0001 C CNN
F 1 "GND" V 4155 1522 50  0000 R CNN
F 2 "" H 4150 1650 50  0001 C CNN
F 3 "" H 4150 1650 50  0001 C CNN
	1    4150 1650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR022
U 1 1 5C12E831
P 4150 2350
F 0 "#PWR022" H 4150 2100 50  0001 C CNN
F 1 "GND" V 4155 2222 50  0000 R CNN
F 2 "" H 4150 2350 50  0001 C CNN
F 3 "" H 4150 2350 50  0001 C CNN
	1    4150 2350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR023
U 1 1 5C12E8F9
P 4150 3050
F 0 "#PWR023" H 4150 2800 50  0001 C CNN
F 1 "GND" V 4155 2922 50  0000 R CNN
F 2 "" H 4150 3050 50  0001 C CNN
F 3 "" H 4150 3050 50  0001 C CNN
	1    4150 3050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR024
U 1 1 5C12E938
P 4150 3750
F 0 "#PWR024" H 4150 3500 50  0001 C CNN
F 1 "GND" V 4155 3622 50  0000 R CNN
F 2 "" H 4150 3750 50  0001 C CNN
F 3 "" H 4150 3750 50  0001 C CNN
	1    4150 3750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR019
U 1 1 5C12E992
P 2900 1400
F 0 "#PWR019" H 2900 1150 50  0001 C CNN
F 1 "GND" H 2905 1227 50  0000 C CNN
F 2 "" H 2900 1400 50  0001 C CNN
F 3 "" H 2900 1400 50  0001 C CNN
	1    2900 1400
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4050 3400 4150 3400
Wire Wire Line
	4150 1350 4150 1300
Connection ~ 4150 1300
Wire Wire Line
	4150 1300 4450 1300
Wire Wire Line
	4150 2050 4150 2000
Connection ~ 4150 2000
Wire Wire Line
	4150 2000 4050 2000
Wire Wire Line
	4150 2000 4450 2000
Wire Wire Line
	4150 2750 4150 2700
Connection ~ 4150 2700
Wire Wire Line
	4150 2700 4450 2700
Wire Wire Line
	2900 1300 3250 1300
Wire Wire Line
	3600 1300 3600 2000
Connection ~ 3600 1300
Wire Wire Line
	3600 1300 3650 1300
Connection ~ 3600 2000
Wire Wire Line
	3600 2000 3600 2700
Connection ~ 3600 2700
Wire Wire Line
	3600 2700 3600 3400
Wire Wire Line
	4150 3450 4150 3400
Connection ~ 4150 3400
Wire Wire Line
	4150 3400 4450 3400
$Comp
L Device:CP1 C1
U 1 1 5C143BC8
P 3250 1500
F 0 "C1" H 3365 1546 50  0000 L CNN
F 1 "CP1" H 3365 1455 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 3250 1500 50  0001 C CNN
F 3 "http://nichicon-us.com/english/products/pdfs/e-uvy.pdf" H 3250 1500 50  0001 C CNN
F 4 "493-12902-1-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    3250 1500
	1    0    0    -1  
$EndComp
Wire Wire Line
	3250 1350 3250 1300
Connection ~ 3250 1300
Wire Wire Line
	3250 1300 3600 1300
$Comp
L power:GND #PWR020
U 1 1 5C1445D4
P 3250 1650
F 0 "#PWR020" H 3250 1400 50  0001 C CNN
F 1 "GND" H 3255 1477 50  0000 C CNN
F 2 "" H 3250 1650 50  0001 C CNN
F 3 "" H 3250 1650 50  0001 C CNN
	1    3250 1650
	1    0    0    -1  
$EndComp
$Comp
L power:+12V #PWR013
U 1 1 5C18FD7B
P 2050 4850
F 0 "#PWR013" H 2050 4700 50  0001 C CNN
F 1 "+12V" V 2065 4978 50  0000 L CNN
F 2 "" H 2050 4850 50  0001 C CNN
F 3 "" H 2050 4850 50  0001 C CNN
	1    2050 4850
	0    1    1    0   
$EndComp
$Comp
L power:+12V #PWR016
U 1 1 5C190B4F
P 2050 5450
F 0 "#PWR016" H 2050 5300 50  0001 C CNN
F 1 "+12V" V 2065 5578 50  0000 L CNN
F 2 "" H 2050 5450 50  0001 C CNN
F 3 "" H 2050 5450 50  0001 C CNN
	1    2050 5450
	0    1    1    0   
$EndComp
$Comp
L Connector:Conn_01x03_Male J5
U 1 1 5C191361
P 1850 4100
F 0 "J5" H 1800 4100 50  0000 C CNN
F 1 "Conn_01x03_Male" H 1956 4287 50  0001 C CNN
F 2 "Connector_Molex:Molex_KK-254_AE-6410-03A_1x03_P2.54mm_Vertical" H 1850 4100 50  0001 C CNN
F 3 "https://www.molex.com/pdm_docs/sd/022112032_sd.pdf" H 1850 4100 50  0001 C CNN
F 4 "WM2701-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    1850 4100
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x03_Male J6
U 1 1 5C191367
P 1850 4500
F 0 "J6" H 1800 4500 50  0000 C CNN
F 1 "Conn_01x03_Male" H 1956 4687 50  0001 C CNN
F 2 "Connector_Molex:Molex_KK-254_AE-6410-03A_1x03_P2.54mm_Vertical" H 1850 4500 50  0001 C CNN
F 3 "https://www.molex.com/pdm_docs/sd/022112032_sd.pdf" H 1850 4500 50  0001 C CNN
F 4 "WM2701-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    1850 4500
	1    0    0    -1  
$EndComp
$Comp
L power:+12V #PWR012
U 1 1 5C191379
P 2050 4500
F 0 "#PWR012" H 2050 4350 50  0001 C CNN
F 1 "+12V" V 2065 4628 50  0000 L CNN
F 2 "" H 2050 4500 50  0001 C CNN
F 3 "" H 2050 4500 50  0001 C CNN
	1    2050 4500
	0    1    1    0   
$EndComp
$Comp
L power:+12V #PWR010
U 1 1 5C19137F
P 2050 4100
F 0 "#PWR010" H 2050 3950 50  0001 C CNN
F 1 "+12V" V 2065 4228 50  0000 L CNN
F 2 "" H 2050 4100 50  0001 C CNN
F 3 "" H 2050 4100 50  0001 C CNN
	1    2050 4100
	0    1    1    0   
$EndComp
NoConn ~ 2050 4200
NoConn ~ 2050 4600
$Comp
L Device:CP1 C6
U 1 1 5C192CD5
P 2900 5300
F 0 "C6" H 3015 5346 50  0000 L CNN
F 1 "CP1" H 3015 5255 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 2900 5300 50  0001 C CNN
F 3 "http://nichicon-us.com/english/products/pdfs/e-uvy.pdf" H 2900 5300 50  0001 C CNN
F 4 "493-12902-1-ND" H 0   0   50  0001 C CNN "DigikeyPN"
	1    2900 5300
	1    0    0    -1  
$EndComp
$Comp
L power:+12V #PWR029
U 1 1 5C192E5F
P 2900 5150
F 0 "#PWR029" H 2900 5000 50  0001 C CNN
F 1 "+12V" H 2915 5323 50  0000 C CNN
F 2 "" H 2900 5150 50  0001 C CNN
F 3 "" H 2900 5150 50  0001 C CNN
	1    2900 5150
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_01x02 J8
U 1 1 5C40755D
P 1850 5450
F 0 "J8" H 1770 5667 50  0000 C CNN
F 1 "Conn_01x02" H 1770 5576 50  0000 C CNN
F 2 "cc:HTLCONN_01x02" H 1850 5450 50  0001 C CNN
F 3 "~" H 1850 5450 50  0001 C CNN
	1    1850 5450
	-1   0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x02 J7
U 1 1 5C504BA2
P 1850 4850
F 0 "J7" H 1930 4842 50  0000 L CNN
F 1 "Screw_Terminal_01x02" H 1930 4751 50  0001 L CNN
F 2 "cc:284391-2" H 1850 4850 50  0001 C CNN
F 3 "https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocNm=284391&DocType=Customer+Drawing&DocLang=English" H 1850 4850 50  0001 C CNN
F 4 "A98159-ND" H 1850 4850 50  0001 C CNN "DigikeyPN"
	1    1850 4850
	-1   0    0    -1  
$EndComp
Text Label 2050 2400 0    50   ~ 0
FGND
Text Label 2050 2800 0    50   ~ 0
FGND
Text Label 2050 3200 0    50   ~ 0
FGND
Text Label 2050 3600 0    50   ~ 0
FGND
Text Label 2050 4000 0    50   ~ 0
FGND
Text Label 2050 4400 0    50   ~ 0
FGND
Text Label 2050 4950 0    50   ~ 0
FGND
Text Label 2050 5550 0    50   ~ 0
FGND
Text Label 2900 5450 3    50   ~ 0
FGND
$EndSCHEMATC
