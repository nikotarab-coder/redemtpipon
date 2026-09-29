extends Node2D

enum Area { ABANDONED, NEW }
var area := Area.ABANDONED
var player_pos := Vector2(640, 390)
var speed := 220.0
var message := "The abandoned bunker is silent."
var objective := "Find a way deeper."
var scare_timer := 0.0
var scare_kind := 0
var flicker := 0
var keycard := false
var generator_on := false
var door_open := false
var radio_used := false
var first_step := true
var fade := 0.0

func _ready() -> void:
    randomize()
    queue_redraw()

func _process(delta: float) -> void:
    if scare_timer > 0.0:
        scare_timer -= delta
        queue_redraw()
        return

    var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    player_pos += input * speed * delta
    player_pos.x = clamp(player_pos.x, 70.0, 1210.0)
    player_pos.y = clamp(player_pos.y, 130.0, 590.0)

    if first_step and input.length() > 0.0:
        first_step = false
        message = "A light flickers somewhere behind you..."
        scare_kind = 1
        scare_timer = 0.55

    if Input.is_action_just_pressed("interact"):
        interact()

    queue_redraw()

func interact() -> void:
    if area == Area.ABANDONED:
        if player_pos.distance_to(Vector2(245, 255)) < 75:
            keycard = true
            message = "You found an old bunker access card."
            objective = "Reach the sealed security door."
        elif player_pos.distance_to(Vector2(930, 270)) < 80 and keycard and not door_open:
            door_open = true
            message = "The lock clicks. The door opens into a newer facility."
            objective = "Enter the new bunker."
        elif player_pos.distance_to(Vector2(640, 520)) < 80:
            scare_kind = 2
            scare_timer = 1.0
            message = "Something moved in the darkness."
        elif player_pos.distance_to(Vector2(1060, 470)) < 80:
            message = "A dead radio crackles for half a second."
            if not radio_used:
                radio_used = true
                scare_kind = 3
                scare_timer = 1.1
        elif door_open and player_pos.distance_to(Vector2(1150, 330)) < 100:
            area = Area.NEW
            player_pos = Vector2(150, 360)
            message = "NEW BUNKER — emergency power online."
            objective = "Restore the generator."
    else:
        if player_pos.distance_to(Vector2(330, 330)) < 85 and not generator_on:
            generator_on = true
            message = "The generator coughs to life."
            objective = "Find the control room."
            scare_kind = 4
            scare_timer = 0.8
        elif player_pos.distance_to(Vector2(820, 300)) < 85 and generator_on:
            message = "Security monitors show an empty hallway... then one frame changes."
            objective = "Get to the main exit."
            scare_kind = 5
            scare_timer = 0.75
        elif player_pos.distance_to(Vector2(1080, 430)) < 90 and generator_on:
            message = "The new bunker exit unlocks."
            objective = "The first area is complete."
            scare_kind = 6
            scare_timer = 0.7
        else:
            message = "The new bunker hums with distant machinery."

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("090d13"))
    draw_rect(Rect2(0, 0, 1280, 92), Color("141c28"))
    draw_string(ThemeDB.fallback_font, Vector2(34, 54), "REDEMPTION", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("e9f1ff"))
    draw_string(ThemeDB.fallback_font, Vector2(1000, 50), "ABANDONED BUNKER" if area == Area.ABANDONED else "NEW BUNKER", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("9fb6d9"))

    draw_rect(Rect2(45, 125, 1190, 480), Color("151b22"))
    draw_rect(Rect2(65, 145, 1150, 440), Color("10151b"))

    if area == Area.ABANDONED:
        draw_abandoned()
    else:
        draw_new()

    draw_circle(player_pos, 17, Color("e6c887"))
    draw_circle(player_pos + Vector2(0, -4), 11, Color("f5dda7"))

    draw_rect(Rect2(30, 620, 1220, 75), Color("080b10"))
    draw_string(ThemeDB.fallback_font, Vector2(50, 648), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("e9f1ff"))
    draw_string(ThemeDB.fallback_font, Vector2(50, 678), "OBJECTIVE: " + objective, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("8fa5c2"))
    draw_string(ThemeDB.fallback_font, Vector2(900, 678), "WASD / Arrows: move   E / Enter: interact", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("70859f"))

    if scare_timer > 0.0:
        draw_scare()

func draw_abandoned() -> void:
    # Rooms and corridors
    draw_rect(Rect2(90, 175, 330, 180), Color("1b2228"))
    draw_rect(Rect2(470, 175, 300, 180), Color("181f25"))
    draw_rect(Rect2(820, 175, 330, 180), Color("1a2025"))
    draw_rect(Rect2(90, 390, 1060, 155), Color("171d23"))
    draw_line(Vector2(420, 265), Vector2(470, 265), Color("39434d"), 8)
    draw_line(Vector2(770, 265), Vector2(820, 265), Color("39434d"), 8)

    draw_string(ThemeDB.fallback_font, Vector2(120, 205), "STORAGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("71808d"))
    draw_string(ThemeDB.fallback_font, Vector2(500, 205), "SLEEPING WING", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("71808d"))
    draw_string(ThemeDB.fallback_font, Vector2(850, 205), "SECURITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("71808d"))

    # props
    draw_rect(Rect2(190, 235, 110, 70), Color("252e36"))
    draw_rect(Rect2(335, 230, 55, 90), Color("202830"))
    draw_circle(Vector2(245, 255), 9, Color("d1b66e"))
    draw_rect(Rect2(590, 235, 90, 42), Color("252e36"))
    draw_rect(Rect2(930, 225, 110, 95), Color("222a31"))
    draw_rect(Rect2(1070, 235, 45, 65), Color("26313a"))
    draw_circle(Vector2(1060, 470), 15, Color("31404b"))
    draw_circle(Vector2(640, 520), 22, Color("0a0d10"))

    if door_open:
        draw_rect(Rect2(1110, 280, 55, 115), Color("0a0c0e"))
        draw_string(ThemeDB.fallback_font, Vector2(1050, 425), "OPEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("9bbf9b"))
    else:
        draw_rect(Rect2(1110, 280, 55, 115), Color("343d44"))
        draw_string(ThemeDB.fallback_font, Vector2(1040, 425), "SEALED", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b08f8f"))

func draw_new() -> void:
    draw_rect(Rect2(90, 175, 300, 160), Color("1d2930"))
    draw_rect(Rect2(430, 175, 350, 160), Color("1c272e"))
    draw_rect(Rect2(820, 175, 330, 160), Color("1d2930"))
    draw_rect(Rect2(90, 370, 1060, 180), Color("19242a"))

    draw_string(ThemeDB.fallback_font, Vector2(120, 205), "GENERATOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("7ea0a7"))
    draw_string(ThemeDB.fallback_font, Vector2(465, 205), "CONTROL ROOM", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("7ea0a7"))
    draw_string(ThemeDB.fallback_font, Vector2(850, 205), "EXIT SECURITY", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("7ea0a7"))

    draw_rect(Rect2(270, 250, 90, 50), Color("34474d"))
    draw_circle(Vector2(330, 330), 26, Color("28383e"))
    draw_rect(Rect2(550, 245, 100, 65), Color("293a40"))
    draw_rect(Rect2(870, 240, 130, 75), Color("2c3d43"))
    draw_circle(Vector2(820, 300), 16, Color("6a9696"))
    draw_rect(Rect2(1030, 420, 65, 95), Color("304148"))

    if generator_on:
        draw_circle(Vector2(330, 330), 12, Color("b6d3a8"))
        draw_string(ThemeDB.fallback_font, Vector2(245, 365), "POWER ONLINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("9fbfa7"))

func draw_scare() -> void:
    var strength := clamp(scare_timer * 2.0, 0.0, 1.0)
    if scare_kind == 1:
        draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.04, 0.65 * strength))
        draw_circle(Vector2(640, 300), 55, Color(0.75, 0.78, 0.80, 0.22 * strength))
        draw_string(ThemeDB.fallback_font, Vector2(500, 405), "DON'T LOOK BACK", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(0.85, 0.88, 0.9, strength))
    elif scare_kind == 2:
        draw_rect(Rect2(0, 0, 1280, 720), Color(0.01, 0.01, 0.015, 0.78 * strength))
        draw_circle(Vector2(640, 315), 95, Color(0.06, 0.07, 0.08, strength))
        draw_circle(Vector2(610, 300), 8, Color(0.8, 0.8, 0.72, strength))
        draw_circle(Vector2(670, 300), 8, Color(0.8, 0.8, 0.72, strength))
    elif scare_kind == 3:
        draw_rect(Rect2(0, 0, 1280, 720), Color(0.5, 0.55, 0.58, 0.12 * strength))
        draw_string(ThemeDB.fallback_font, Vector2(475, 335), "SIGNAL LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("d6dde0"))
    elif scare_kind == 4:
        draw_rect(Rect2(0, 0, 1280, 720), Color(0.85, 0.88, 0.82, 0.14 * strength))
        draw_string(ThemeDB.fallback_font, Vector2(530, 350), "POWER RESTORED", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("dce6df"))
    elif scare_kind == 5:
        draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.025, 0.03, 0.75 * strength))
        draw_rect(Rect2(830, 210, 100, 160), Color(0.06, 0.08, 0.09, strength))
        draw_circle(Vector2(855, 255), 7, Color("b8c0bd", strength))
        draw_circle(Vector2(905, 255), 7, Color("b8c0bd", strength))
    elif scare_kind == 6:
        draw_rect(Rect2(0, 0, 1280, 720), Color(0.8, 0.85, 0.9, 0.18 * strength))
        draw_string(ThemeDB.fallback_font, Vector2(490, 350), "AREA COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("e8edf2", strength))
