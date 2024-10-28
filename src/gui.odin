#+vet unused shadowing using-stmt style semicolon
package main

import rl "vendor:raylib"

gui_button :: proc(
	text: string,
	position: FVec2,
	on_click: proc(),
	scale: f32 = 1,
) {
	rect := rl.Rectangle {
		position.x - 16 * scale,
		position.y - 8 * scale,
		(f32(14 * len(text)) + 32) * scale,
		48 * scale,
	}
	rl.DrawRectangleRounded(rect, 0.5, 16, rl.GRAY)
	draw_text(text, position, size = 32 * scale)
	mouse_position := rl.GetMousePosition()
	if point_in_rect(mouse_position, &rect) && rl.IsMouseButtonPressed(.LEFT) {
		on_click()
	}
}
