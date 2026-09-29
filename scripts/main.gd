extends Node2D

var player_pos := Vector2(640, 390)
var speed := 260.0
var message := "The Sea of Memory"

func _ready() -> void:
    queue_redraw()

func _process(delta: float) -> void:
    var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    player_pos += input * speed * delta
    player_pos.x = clamp(player_pos.x, 40.0, 1240.0)
    player_pos.y = clamp(player_pos.y, 120.0, 680.0)
    if Input.is_action_just_pressed("ui_accept"):
        message = "Frowny stands in the Sunken City."
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("101827"))
    draw_rect(Rect2(0, 0, 1280, 90), Color("18263d"))
    draw_string(ThemeDB.fallback_font, Vector2(36, 54), "REDEMPTION", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("e9f1ff"))
    draw_string(ThemeDB.fallback_font, Vector2(1040, 50), "SEA OF MEMORY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("9fb6d9"))
    for x in range(0, 1280, 64):
        draw_line(Vector2(x, 90), Vector2(x, 720), Color("17253a"), 1)
    for y in range(90, 720, 64):
        draw_line(Vector2(0, y), Vector2(1280, y), Color("17253a"), 1)
    draw_circle(Vector2(640, 380), 110, Color("243c5a"))
    draw_circle(Vector2(640, 380), 48, Color("304e70"))
    draw_circle(player_pos, 18, Color("f1d18a"))
    draw_circle(player_pos + Vector2(0, -5), 12, Color("f7e0a8"))
    draw_rect(Rect2(30, 635, 1220, 55), Color("0b111c"))
    draw_string(ThemeDB.fallback_font, Vector2(50, 670), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e9f1ff"))
    draw_string(ThemeDB.fallback_font, Vector2(50, 705), "Arrow keys / WASD: move   Enter: interact", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("7f95b5"))
