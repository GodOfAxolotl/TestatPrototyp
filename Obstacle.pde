class Obstacle {
 PVector pos;
 float size;
 
 Obstacle(float he) {
   pos = new PVector(random(width / 2, width - width / 3), he + random(-25, 25));
   size = random(width / 6, width / 3);
 }
 
 
 void update() {
   
 }
 
 void render() {
   noStroke();
   fill(1);
   rectMode(CENTER);
   rect(pos.x, pos.y, size, size / 3);
   rectMode(CORNER);
 }
}
