class Projectile {
  PVector pos;
  PVector vel;
  float radius = 10;

  Projectile(float x, float y, float vx, float vy, float dx, float dy) {
    pos = new PVector(x, y);
    PVector dir = new PVector(x,y);
    dir.normalize();
    vel = new PVector(dx, dy).add(vx, vy);
  }

  void update() {
    pos.add(vel);
  }

  void anzeigen() {
    fill(255, 0, 0);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
  }
}
