package child1

func Add(x int, y int) int {
	x += 1
	x -= 1
	return x + y
}

func Sub(x int, y int) int {
	y += 1
	y -= 1
	return x - y
}
