class Obstacle {
 PVector pos;
 float size;
 
 Obstacle(float he) {
   pos = new PVector(random(width / 2, width - width / 3), he);
   //size = new PVector(random(width / 4, width - width / 4), height - height / 4);
   size = 500;
 }
 
 
 void update() {
   
 }
 
 void render() {
   noStroke();
   fill(1);
   ellipse(pos.x, pos.y, size, size / 4);
 }
}
