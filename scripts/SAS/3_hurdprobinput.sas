
data hurd;
    infile 'ROOT/data/SAS/created/hurdprobabilities_wide.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
    informat hhidpn best32.;
    informat HHID $char6.;
    informat PN $char3.;
    informat hurd_prob_2007 best32.;
    informat hurd_prob_1999 best32.;
    informat hurd_prob_2001 best32.;
    informat hurd_prob_2003 best32.;
    informat hurd_prob_2005 best32.;
    format hhidpn best12.;
    format HHID $char6.;
    format PN $char3.; 
    format hurd_prob_2007 best12.;
    format hurd_prob_1999 best12.;
    format hurd_prob_2001 best12.;
    format hurd_prob_2003 best12.;
    format hurd_prob_2005 best12.;
    input
	hhidpn
        HHID
        PN
        hurd_prob_2007
        hurd_prob_1999
        hurd_prob_2001
        hurd_prob_2003
        hurd_prob_2005;
run;

data pred;
     merge pred (in = a) hurd;
     by hhid pn;
     if a;
run;

