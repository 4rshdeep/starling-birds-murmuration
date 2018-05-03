Flock flock;
PFont f;
int count;
int BOIDS = 200;

float avoidRadius = 90;
String option = "boids";
ArrayList<Boid> save;
ArrayList<Obstacle> obstacles;

float neighbourRadius;
float globalScale = .91; // size of starlings

String messageText;
int messageTimer = 0;


boolean f_ali = true;
boolean f_sep = true;
boolean f_avoid = true;
boolean f_noise = true;
boolean f_coh = true;

boolean show_frate = true;
String f_rate;


void setup() {

  fullScreen();
  flock = new Flock();
  count = 0;
  f_rate = "";

  for (int x = 100; x < width - 100; x+= 100) {
    for (int y = 100; y < height - 100; y+= 100) {
     flock.addBoid(new Boid(x + random(3), y + random(3)));
     flock.addBoid(new Boid(x + random(3), y + random(3)));
    }
  }

  f = createFont("Roboto Regular",16,true);
  textFont(f,18);

  neighbourRadius = 60;
  obstacles = new ArrayList<Obstacle>();
}

void draw() {

  background(50);
  fill(255, 200);
  if (show_frate) {
    f_rate = "Total boids: " + count + "\n" + "Framerate: " + round(frameRate) + "\n";
  }
  else {
    f_rate = "Total boids: " + count + "\n" ;
  }
  text(f_rate, 133, 60);

  flock.run();

  for (int i = 0; i < obstacles.size(); i++) {
    Obstacle current = obstacles.get(i);
    current.draw();
  }

  if (messageTimer > 0) {
    messageTimer -= 1; 
  }

  if(messageTimer > 0) {
    fill((min(30, messageTimer) / 30.0) * 255.0);
    text(messageText,111,924);
   }

}



void mousePressed() {
    // println("mouseX: "+mouseX);
    // println("mouseY: "+mouseY);
    switch (option) {
        case "boids" :
            for (int i = 0; i < 2; i++) {
                flock.addBoid(new Boid(mouseX,mouseY));
            }               
            break;        
        case "obstacles" :
            obstacles.add(new Obstacle(mouseX, mouseY));                  
    }
}

void keyPressed () {
  if (key == 'q') {
    option = "boids";
    message("Add boids");
  } else if (key == 'w') {
    option = "obstacles";
    message("Place obstacles");
    
  } else if (key == 'f') {
    option = "frate";
    show_frate = !show_frate;
    message("frate " + on(show_frate));
  } else if (key == '-') {
    message("Decreased scale");
    globalScale *= 0.8;
  } else if (key == '=') {
      message("Increased Scale");
    globalScale /= 0.8;
  } else if (key == '1') {
     f_ali = f_ali ? false : true;
     message("Turned friend allignment " + on(f_ali));
  } else if (key == '2') {
     f_sep = f_sep ? false : true;
     message("Turned crowding avoidance " + on(f_sep));
  } else if (key == '3') {
     f_avoid = f_avoid ? false : true;
     message("Turned obstacle avoidance " + on(f_avoid));
  }else if (key == '4') {
     f_coh = f_coh ? false : true;
     message("Turned cohesion " + on(f_coh));
  }else if (key == '5') {
     f_noise = f_noise ? false : true;
     message("Turned noise " + on(f_noise));
  }
}

String on(boolean in) {
  return in ? "on" : "off"; 
}

void message (String in) {
   messageText = in;
   messageTimer = (int) frameRate * 3;
}

