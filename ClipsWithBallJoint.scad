// variable definitions
//#####################

// distance of clips to each other = Ka
Ka= 27 ;

// clip height = Kh         
Kh= 15 ;

//inner clip diameter = Kd
Kd= 20 ;

//width of clip tips = Ktip
Ktip = 2 ;

//radius of clip edge smoothing
Ksr = 2 ;

// clip scale factor = Sf     ( 1.01 = 101% / 0.99 = 99% )
Sf= 1.0 ;

// area of the inner sphere touching the print bed = Fi
// Default = 40 mm² ; increase if there a adhesion problems
Fi= 40 ;
// 
// radius of inner sphere = Ri
Ri= 9.5 ;

// make the inner joint sphere hollow
// nonhollow sphere prints and renders faster
Rh= false;

// radius of outer sphere = Ra
Ra= 13 ; 

// gap between spheres =Sk
Sk= 0.4;

// tolerance of calculation ($fn) = F
// reduce this below 50 for faster rendering while developing
F= 90 ;

// flail radius
Rs= 5.5 ;
// angle of allowed horizontal deviation =Wh
Wh= 0 ;

// angle of rotation to the left (upside down) = Wu
Wu= 90 ;

// angle of possible upward rotation (upside down) = Wo
Wo= 0 ;

//calculatoin of h in a sphere section to get the position of the 0 plane
Ne=-Ri+(Ri+sqrt((Ri*Ri)-(Fi/3.1415)));


//clip generation module
module clip (h=15,d=20, tipW=2, es=2 ) {
  // h =  clip height
  // d =  inner clip diameter
  // tipW = width of clip tips 
  // es = clip edge smoothing

  //square
  function sq (x) =  x*x ;

  //circle intersection x
  function xIntersect (R,r,d) = ( sq(d) - sq(r) + sq(R) ) / (2*d) ;

  //circle intersection y
  function yIntersect (R,r,d) = (1/d) * sqrt( (-d+r-R) * (-d-r+R) * (-d+r+R) * (d+r+R))/2 ;

  // outer clip diameter
  D = d + 2 ;

  //move to position
  translate ([d/2,0,h/2])
    //smooth edges
    minkowski () {
      //basic clip shape
      difference () {
        $fn=F;
        //translate outer shape  upwards to compensate for smoothing
        translate ([0,0, es/2 ])
          // clips basic outer shape
          union () {
            //outer cylinder
            cylinder (d=D , h=h, center=true) ;

            //calculate intersection of outer and inner clip radius
            x=yIntersect(D/2, d/2, 2) ;
            y=xIntersect(D/2, d/2, 2) ;
            //create thicker tips at intersections
            for ( i = [-1:2:1] ) { 
              translate ([y,x*i,0])
                cylinder (d=1.5, h=h, center=true);
            }
          }
        // inner clip diameter (will be removed)
        translate ([2,0,1])
          cylinder (d=d, h=h+2, center=true) ;
      }
      //sphere for minkowski edge smoothing
      sphere ($fn=F/5 , d=es ) ;
    }
}

//position both clips
for (i=[0:1]) {
  rotate ([0,0,180*i])
    translate([Ka/2,0,-Ne])
    scale ([Sf,Sf,Kh/13])
    clip(h=Kh , d=Kd, tipW=Ktip , es=Ksr) ;
}

//inner sphere
difference() {
  //sphere with flail (to the right)
  union(){ 
    //sphere   
    color ("blue")    
      translate([0,0,0])
      sphere (r=Ri, $fn=F);
    //flail
    color ("pink")
      rotate ([0,90,0])
      cylinder(r=Rs,h=Ra,$fn=F);    
  }
  //subtraction
  union(){
    //lower cutoff
    translate([-100,-100,-(50+Ne)])   
      cube ([200,200,50]) ;
    //hollow within sphere
    if (Rh)
    sphere (r=Ri-(Ra-Ri-Sk), $fn=F/2);
  }
}

//outer sphere
difference(){
  //moulding
  color ("green")   
    translate([0,0,0])
    sphere (r=Ra, $fn=F);

  union(){ 
    //hollow within
    translate([0,0,0])
      sphere (r=Ri+Sk, $fn=F);    
    //lower cutoff
    translate([-100,-100,-(50+Ne)])   
      cube ([200,200,50]) ; 


    //cutout for flail
    //
    //lower cutout
    hull(){
      //middle flail + slit
      rotate ([0,90,0])
        cylinder(r=Rs+Sk,h=Ra*2,$fn=F);     
      //flail to the front
      rotate ([0,90,-(Wh/2)])
        cylinder(r=Rs,h=Ra*2,$fn=F);
      //flail to the back
      rotate ([0,90,(Wh/2)])
        cylinder(r=Rs,h=Ra*2,$fn=F);
      //flail to the front and down
      rotate ([0,90-Wu,-(Wh/2)])
        cylinder(r=Rs,h=Ra*2,$fn=F);
      //flail to the back and down
      rotate ([0,90-Wu,(Wh/2)])
        cylinder(r=Rs,h=Ra*2,$fn=F);   
      //flail to the front and up
      rotate ([0,90+Wo,-(Wh/2)])
        cylinder(r=Rs,h=Ra*2,$fn=F);
      //flail to the back and up
      rotate ([0,90+Wo,(Wh/2)])
        cylinder(r=Rs,h=Ra*2,$fn=F);    
    }        
  }    
}

//connection to clips
// left side to outer sphere
hull(){
  //base at clip
  translate([-(Ka/2)-0.05,-6,-Ne])   
    cube ([0.1,12,Kh]) ; 
  //base at sphere
  rotate ([0,-90,0])
    translate([0,0,Ri+Sk])
    cylinder(r=Rs,h=(Ka/2)-Ri,$fn=F);        
}

//right side to flail
hull(){
  //base at clip
  translate([(Ka/2)+0.05,-6,-Ne])   
    cube ([0.9,12,Kh]) ;
  //base at flail
  rotate ([0,90,0])
    translate([0,0,Ra-(Sk*3)])
    cylinder(r=Rs,h=0.05,$fn=F);        
}
echo ("                   It takes a very long time to render         ");
echo ("                        get a cup of tea                     ");
