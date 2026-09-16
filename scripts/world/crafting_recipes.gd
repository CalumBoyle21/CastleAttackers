class_name CraftingRecipes

## Static recipe list — the single place to add new craftable items.
## Add an entry here and it automatically appears in the crafting menu;
## no UI or scene changes needed. "post" and "board" are consumed
## directly by the build system (see BuildController / WallEdge).

static var ALL: Array[Dictionary] = [
	{"name": "Post", "output": "post", "output_amount": 1, "costs": {"wood": 2}},
	{"name": "Board", "output": "board", "output_amount": 1, "costs": {"wood": 2}},
]
