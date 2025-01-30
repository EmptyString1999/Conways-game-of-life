package main

import rl "vendor:raylib"
import "core:fmt"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 100
CELL_SIZE :: 10
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
TICK_RATE :: 0.05

Vec2i :: [2]int

tick_timer: f32 = TICK_RATE
running: bool
grid: [GRID_WIDTH][GRID_WIDTH]bool

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow( WINDOW_SIZE, WINDOW_SIZE, "conways")

    init_grid()

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        camera := rl.Camera2D{
            zoom = f32(WINDOW_SIZE) / CANVAS_SIZE,
        }
        rl.BeginMode2D(camera)

        get_input()

        draw_grid()

        tick_timer -= rl.GetFrameTime()

        if tick_timer <= 0 {
            tick_timer = TICK_RATE + tick_timer
            gen_next_grid()
        }

        fps := rl.GetFPS()
        fps_text := fmt.ctprint("FPS: ", fps)
        rl.DrawText(fps_text, CANVAS_SIZE / 2, 20, 20, rl.GREEN)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

get_input :: proc() {
    if rl.IsKeyPressed(.SPACE) {
        init_grid()
    }
    if rl.IsKeyPressed(.ESCAPE) {
        rl.CloseWindow()
    }
}

init_grid :: proc() {
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            grid[x][y] = rl.GetRandomValue(0, 1) == 1
        }
    }
}

draw_grid :: proc() {
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if grid[x][y] {
                rl.DrawRectangle(i32(x) * CELL_SIZE, i32(y) * CELL_SIZE, CELL_SIZE, CELL_SIZE, rl.WHITE)
            }
        }
    }
}

get_random_color :: proc() -> rl.Color {
    a,b,c := u8(rl.GetRandomValue(0, 255)), u8(rl.GetRandomValue(0, 255)), u8(rl.GetRandomValue(0, 255))
    return rl.Color({a,b,c,255})
}

gen_next_grid :: proc() {
    next_grid: [GRID_WIDTH][GRID_WIDTH]bool

    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {

            surrounding_cells := get_surrounding_cells(x, y)
            
            if grid[x][y] { // populated cells
                if lonley(surrounding_cells) {
                    next_grid[x][y] = false
                } else if crowded(surrounding_cells) {
                    next_grid[x][y] = false
                } else if satisfied(surrounding_cells) {
                    next_grid[x][y] = true
                } 
            } else { // empty cells
                if born(surrounding_cells) {
                    next_grid[x][y] = true
                }
            }
        }
    }

    grid = next_grid
}

get_surrounding_cells :: proc(x: int, y: int) -> int {
    count := 0 
    for dx in -1..=1 {
        for dy in -1..=1 {
            if dx == 0 && dy == 0 {
                continue
            }
            nx := x + dx
            ny := y + dy
            if nx >= 0 && nx < len(grid) && ny >= 0 && ny < len(grid[0]) {
                if grid[nx][ny] {
                    count += 1
                }
            }
        }
    }
    return count
}

lonley :: proc(count: int) -> bool {
    return count <= 1
}

crowded :: proc(count: int) -> bool {
    return count >= 4
}

satisfied :: proc(count: int) -> bool {
    return count == 2 || count == 3
}

born :: proc(count: int) -> bool {
    return count == 3
}