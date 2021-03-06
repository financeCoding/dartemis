part of darteroids;

class CirleRenderingSystem extends EntityProcessingSystem {

  CanvasRenderingContext2D context2d;

  ComponentMapper<Position> positionMapper;
  ComponentMapper<CircularBody> bodyMapper;
  ComponentMapper<Status> statusMapper;

  CirleRenderingSystem(this.context2d) : super(Aspect.getAspectForAllOf(new Position.hack().runtimeType, [new CircularBody.hack().runtimeType]));

  void initialize() {
    positionMapper = new ComponentMapper<Position>(new Position.hack().runtimeType, world);
    bodyMapper = new ComponentMapper<CircularBody>(new CircularBody.hack().runtimeType, world);
    statusMapper = new ComponentMapper<Status>(new Status.hack().runtimeType, world);
  }

  void processEntity(Entity entity) {
    Position pos = positionMapper.get(entity);
    CircularBody body = bodyMapper.get(entity);
    Status status = statusMapper.getSafe(entity);

    context2d.save();

    try {
      context2d.lineWidth = 0.5;
      context2d.fillStyle = body.color;
      context2d.strokeStyle = body.color;
      if (null != status && status.invisible) {
        if (status.invisiblityTimer % 600 < 300) {
          context2d.globalAlpha = 0.4;
        }
      }

      drawCirle(pos, body);

      if (pos.x + body.radius > MAXWIDTH) {
        drawCirle(pos, body, offsetX : -MAXWIDTH);
      } else if (pos.x - body.radius < 0) {
        drawCirle(pos, body, offsetX : MAXWIDTH);
      }
      if (pos.y + body.radius > MAXHEIGHT) {
        drawCirle(pos, body, offsetY : -MAXHEIGHT);
      } else if (pos.y - body.radius < 0) {
        drawCirle(pos, body, offsetY : MAXHEIGHT);
      }


      context2d.stroke();
    } finally {
      context2d.restore();
    }
  }

  void drawCirle(Position pos, CircularBody body, {int offsetX : 0, int offsetY : 0}) {
    context2d.beginPath();

    context2d.arc(pos.x + offsetX, pos.y + offsetY, body.radius, 0, PI * 2, false);

    context2d.closePath();
    context2d.fill();
  }
}

class BackgroundRenderSystem extends VoidEntitySystem {
  CanvasRenderingContext2D context2d;

  BackgroundRenderSystem(this.context2d);

  void processSystem() {
    context2d.save();
    try {
      context2d.fillStyle = "black";

      context2d.beginPath();
      context2d.rect(0, 0, MAXWIDTH, MAXHEIGHT + HUDHEIGHT);
      context2d.closePath();

      context2d.fill();
    } finally {
      context2d.restore();
    }
  }
}

class HudRenderSystem extends VoidEntitySystem {
  CanvasRenderingContext2D context2d;
  TagManager tagManager;
  ComponentMapper<Status> statusMapper;

  HudRenderSystem(this.context2d);

  void initialize() {
    tagManager = world.getManager(new TagManager().runtimeType);
    statusMapper = new ComponentMapper<Status>(new Status.hack().runtimeType, world);
  }

  void processSystem() {
    context2d.save();
    try {
      context2d.fillStyle = "#555";

      context2d.beginPath();
      context2d.rect(0, MAXHEIGHT, MAXWIDTH, MAXHEIGHT + HUDHEIGHT);
      context2d.closePath();

      context2d.fill();

      Entity player = tagManager.getEntity(TAG_PLAYER);
      Status status = statusMapper.get(player);

      context2d.fillStyle = PLAYER_COLOR;
      for (int i = 0; i < status.lifes; i++) {

        context2d.beginPath();
        context2d.arc(50 + i * 50, MAXHEIGHT + HUDHEIGHT~/2, 15, 0, PI * 2, false);
        context2d.closePath();

        context2d.fill();
      }

    } finally {
      context2d.restore();
    }
  }
}