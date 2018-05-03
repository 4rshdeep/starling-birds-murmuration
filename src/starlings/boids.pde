class Boid {

    PVector position;
    PVector velocity;
    PVector acceleration;
    float r;
    float maxforce;
    float maxspeed;
    float angle;
    float shade;
    int time;
    float boid_power;
    ArrayList<Boid> neighbours;

    Boid(float x, float y) {
        acceleration = new PVector(0, 0);
        angle        = random(TWO_PI);
        velocity     = new PVector(cos(angle), sin(angle));
        position     = new PVector(x, y);
        r            = 2.0;
        maxspeed     = 2;
        maxforce     = 0.03;
        shade        = random(255);
        time         = int(random(10));
        neighbours   = new ArrayList<Boid>();
        boid_power   = 0.0;
    }

    Boid clone() {
        Boid b         = new Boid(position.x, position.y);
        b.position     = position.copy();
        b.velocity     = velocity.copy();
        b.acceleration = acceleration.copy();
        b.angle        = angle;
        return b;
    }
    
    float get_energy() {
      return (0.5 * mass * ( (velocity.x * velocity.x) + (velocity.y * velocity.y) ) );
    }
    
    float get_power() {
      return ( mass * ( (velocity.x * acceleration.x) + (velocity.y * acceleration.y) ) );
    }
    
    void run(ArrayList<Boid> boids) {
        // power = 0;
        time = (time+1)%5;
        if (time==0) {
            getNeighbours();
        }
        flock(boids);
        update();
        borders();
    }

    void applyForce(PVector force) {
        acceleration.add(force);
    }

    void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector obs = avoidObstacles();
    PVector noise = new PVector(random(2) - 1, random(2) -1);


    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    obs.mult(1.5);
    noise.mult(0.1);

    if (!f_ali) ali.mult(0);
    if (!f_sep) sep.mult(0);
    if (!f_avoid) obs.mult(0);
    if (!f_noise) noise.mult(0);
    if (!f_coh) coh.mult(0);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(obs);
    applyForce(noise);

    shade += getAverageColor() * 0.03;
    shade += (random(2) - 1) ;
    shade = (shade + 255) % 255;
  }

  void update() {
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    boid_power = get_power();
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
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

  float getAverageColor () {
    float total = 0;
    float count = 0;
    
    for (Boid other : neighbours) {
      if (other.shade - shade < -128) {
        total += other.shade + 255 - shade;
      } else if (other.shade - shade > 128) {
        total += other.shade - 255 - shade;
      } else {
        total += other.shade - shade; 
      }
      count++;
    }
    if (count == 0) return 0;
    return total / (float) count;
  }


  void getNeighbours () {
    ArrayList<Boid> nearby = new ArrayList<Boid>();
    for (int i =0; i < flock.boids.size(); i++) {
      Boid test = flock.boids.get(i);
      if (test == this) continue;
      if (abs(test.position.x - this.position.x) < neighbourRadius &&
        abs(test.position.y - this.position.y) < neighbourRadius) {
        nearby.add(test);
      }
    }
    neighbours = nearby;
  }

  void render() {
    noStroke();
    fill(shade, 90, 200);
    pushMatrix();
    translate(position.x, position.y);
    rotate(velocity.heading());
    beginShape();
    vertex(15 * globalScale, 0);
    vertex(-7* globalScale, 7* globalScale);
    vertex(-7* globalScale, -7* globalScale);
    endShape(CLOSE);
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  PVector avoidObstacles() {
    PVector steer = new PVector(0, 0);

    for (Obstacle other : obstacles) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < avoidRadius)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
      }
    }
    return steer;
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
