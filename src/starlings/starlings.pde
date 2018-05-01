Flock flock;
PFont f;
int count;
int BOIDS = 200;

void setup() {
  
  fullScreen();
  flock = new Flock();
  for (int i = 0; i < BOIDS; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
  f = createFont("Roboto Regular",16,true);
  textFont(f,18);
  count = BOIDS;

}

void draw() {
  background(50);
  fill(255, 200);
  text(count,1757,50);
  flock.run();
}

void mousePressed() {
  for (int i = 0; i < 20; i++) {
    flock.addBoid(new Boid(mouseX,mouseY));
  }
}

class Flock {
  ArrayList<Boid> boids;

  Flock() {
    boids = new ArrayList<Boid>(); 
  }

  //  This is for multithreading some errors are there
  // class Parallel extends Thread {
  //   int start;
  //   int end;
  //   ArrayList<Boid> saved_copy;
  //   String id;

  //   Parallel(String a, int s, int e, ArrayList<Boid> co) {
  //       start = s;
  //       end = e;
  //       saved_copy = co;
  //       id = a;
  //   }

  //   public void run()
  //   {
  //       try
  //       {
  //           for (int i = start; i < end; ++i) {
  //               println("thread: "+ id + " i: " + i);
  //               boids.get(i).run(saved_copy);
  //           }
  //       }
  //       catch (Exception e)
  //       {
  //           println("start: "+start);
  //           println("end: "+end);
  //           e.printStackTrace();
  //       }
  //   }
  // }

  void run() {
    for (Boid b : boids) {
        b.run(boids);
    }
    // ArrayList<Boid> save = new ArrayList<Boid>(boids);
    // for (Boid b : boids) {
    //     Boid temp = b.clone();
    //     save.add(temp);
    // }
    
    // Parallel p1 = new Parallel("t1", 0, 250, save);
    // Parallel p2 = new Parallel("t2", 250, 500, save);
    // Parallel p3 = new Parallel("t3", 500, 750, save);
    // Parallel p4 = new Parallel("t4", 750, 1000, save);
    
    // p1.start();
    // p2.start();
    // p3.start();
    // p4.start();

    // try {
    //     p1.join();
    // } catch (InterruptedException e) {
    //     e.printStackTrace();
    // }
    // try {
    //     p2.join();
    // } catch (InterruptedException e) {
    //     e.printStackTrace();
    // }
    // try {
    //     p3.join();
    // } catch (InterruptedException e) {
    //     e.printStackTrace();
    // }
    // try {
    //     p4.join();
    // } catch (InterruptedException e) {
    //     e.printStackTrace();
    // }
  }

  void addBoid(Boid b) {
    boids.add(b);
    count += 1; 
  }
}


class Boid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;
  float maxspeed;
  float angle;

    Boid(float x, float y) {
    acceleration = new PVector(0, 0);
    angle        = random(TWO_PI);
    velocity     = new PVector(cos(angle), sin(angle));
    position     = new PVector(x, y);
    r            = 2.0;
    maxspeed     = 2;
    maxforce     = 0.03;
  }

  Boid clone() {
    Boid b         = new Boid(position.x, position.y);
    b.position     = position.copy();
    b.velocity     = velocity.copy();
    b.acceleration = acceleration.copy();
    b.angle        = angle;
    return b;
  }
  

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion

    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    
    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(-r, r*2);
    vertex(0, -r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }

  
}
