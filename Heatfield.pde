class Heatfield {
  PVector pos;

  Heatfield() {
    pos = randPos();
  }

  void render() {
    fill(255, 127, 0, 145);
    noStroke();
    ellipse(pos.x, pos.y, 150, 150);
  }

  PVector randPos() {
    int r = floor(random(1, 1));
    switch(r) {
    case 0:
      return new PVector(random(width/4, width / 2), height/2);
    case 1:
      return new PVector(random(width/4, width / 2), 100);
    case 2:
      return new PVector(random(width/4, width / 2), height - 100);
    default:
      return new PVector(random(width/4, width / 2), height - 100);
    }
  }
}
