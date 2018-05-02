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
    
    // Parallel p1 = new Parallel("t1", 0, int(count/8), save);
    // Parallel p2 = new Parallel("t2", int(count/8),   int(2*count/8), save);
    // Parallel p3 = new Parallel("t3", int(2*count/8), int(3*count/8), save);
    // Parallel p4 = new Parallel("t4", int(3*count/8), int(4*count/8), save);
    // Parallel p5 = new Parallel("t5", int(4*count/8), int(5*count/8), save);
    // Parallel p6 = new Parallel("t6", int(5*count/8), int(6*count/8), save);
    // Parallel p7 = new Parallel("t7", int(6*count/8), int(7*count/8), save);
    // Parallel p8 = new Parallel("t8", int(7*count/8), count, save);
    
    p1.start();
    p2.start();
    p3.start();
    p4.start();
    // p5.start();
    // p6.start();
    // p7.start();
    // p8.start();
    
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
    // try {
    //     p5.join();
    // } catch (InterruptedException e) {
    //     e.printStackTrace();
    // }try {
    //     p6.join();
    // } catch (InterruptedException e) {
    //     e.printStackTrace();
    // }try {
    //     p7.join();
    // } catch (InterruptedException e) {
    //     e.printStackTrace();
    // }try {
    //     p8.join();
    // } catch (InterruptedException e) {
    //     e.printStackTrace();
    // }

     for (Boid b : boids) {
        b.render();
    }

  }

  void addBoid(Boid b) {
    boids.add(b);
    count += 1; 
  }
}
