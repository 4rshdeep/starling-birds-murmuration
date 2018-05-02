class Flock {
  ArrayList<Boid> boids;

  Flock() {
    boids = new ArrayList<Boid>(); 
  }

  class Parallel extends Thread {
    int start;
    int end;
    ArrayList<Boid> saved_copy;
    String id;

    Parallel(String a, int s, int e, ArrayList<Boid> co) {
        start = s;
        end = e;
        saved_copy = co;
        id = a;
    }

    public void run()
    {
        try
        {
            for (int i = start; i < end; ++i) {
                boids.get(i).run(saved_copy);
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }
  }

  void run() {
    save = new ArrayList<Boid>();

    for (Boid b : boids) {
        Boid temp = b.clone();
        save.add(temp);
    }

    // threads 
    Parallel p1 = new Parallel("t1", 0, int(count/4), save);
    Parallel p2 = new Parallel("t2", int(count/4), int(2*count/4), save);
    Parallel p3 = new Parallel("t3", int(2*count/4), int(3*count/4), save);
    Parallel p4 = new Parallel("t4", int(3*count/4), count, save);
    
    p1.start();
    p2.start();
    p3.start();
    p4.start();
    
    try {
        p1.join();
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    try {
        p2.join();
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    try {
        p3.join();
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    try {
        p4.join();
    } catch (InterruptedException e) {
        e.printStackTrace();
    }

     for (Boid b : boids) {
        b.render();
    }

  }

  void addBoid(Boid b) {
    boids.add(b);
    count += 1; 
  }
}
