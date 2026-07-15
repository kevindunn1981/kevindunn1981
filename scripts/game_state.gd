extends Node
## Autoload singleton: persistent high scores + cross-reload flags.
##
## High scores are stored as an array of { "name": String, "score": int },
## sorted descending, capped at MAX_ENTRIES, saved to user://highscores.json.

const SAVE_PATH := "user://highscores.json"
const MAX_ENTRIES := 10

var high_scores: Array = []
var last_name := "PILOT"

## Set before reloading the scene so main.gd knows to skip the menu
## and start a run immediately (used by the "PLAY AGAIN" button).
var auto_start := false

func _ready() -> void:
	load_scores()

func best_score() -> int:
	return 0 if high_scores.is_empty() else int(high_scores[0]["score"])

func qualifies(score: int) -> bool:
	if score <= 0:
		return false
	if high_scores.size() < MAX_ENTRIES:
		return true
	return score > int(high_scores[-1]["score"])

## Inserts an entry and returns its 0-based rank, or -1 if it didn't place.
func add_score(player_name: String, score: int) -> int:
	var cleaned := player_name.strip_edges()
	if cleaned.is_empty():
		cleaned = "PILOT"
	last_name = cleaned
	high_scores.append({"name": cleaned, "score": score})
	high_scores.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	if high_scores.size() > MAX_ENTRIES:
		high_scores.resize(MAX_ENTRIES)
	save_scores()
	for i in high_scores.size():
		if high_scores[i]["name"] == cleaned and int(high_scores[i]["score"]) == score:
			return i
	return -1

func save_scores() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("VOIDGRAFT: could not save high scores (%s)" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify({"last_name": last_name, "scores": high_scores}))

func load_scores() -> void:
	high_scores = []
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		last_name = str(data.get("last_name", "PILOT"))
		var raw: Variant = data.get("scores", [])
		if raw is Array:
			for entry in raw:
				if entry is Dictionary and entry.has("name") and entry.has("score"):
					high_scores.append({"name": str(entry["name"]), "score": int(entry["score"])})
	high_scores.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
