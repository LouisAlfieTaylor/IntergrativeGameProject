extends Node

# Translations are registered with TranslationServer two ways:
# 1. project.godot's [internationalization] locale/translations entry — this
#    auto-loads the .translation files and is what works in EXPORTED builds
#    (the CSV itself isn't bundled because FileAccess.open is a string path
#    the export scanner can't follow).
# 2. CSV parsing below — only runs in dev when the CSV is present, useful
#    when iterating on text without re-importing in the editor.
#
# At startup we discover the available locales from whichever source returned
# something, so the language toggle works in both dev and export.

const CSV_PATH := "res://assets/translations/translations.csv"

signal language_changed(locale: String)

var _locales: Array[String] = []

func _ready() -> void:
	_load_translations_from_csv()
	if _locales.is_empty():
		# Export build — CSV not bundled. Fall back to whatever the engine
		# already loaded via project.godot's [internationalization] section.
		for loc in TranslationServer.get_loaded_locales():
			if not _locales.has(loc):
				_locales.append(loc)

func _load_translations_from_csv() -> void:
	if not FileAccess.file_exists(CSV_PATH):
		return  # No CSV (likely an export build) — leave to the fallback
	var f := FileAccess.open(CSV_PATH, FileAccess.READ)
	if f == null:
		return
	var header := f.get_csv_line()
	if header.size() < 2:
		f.close()
		return
	for i in range(1, header.size()):
		_locales.append(header[i])
	var translations: Array[Translation] = []
	for loc in _locales:
		var t := Translation.new()
		t.locale = loc
		translations.append(t)
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() < 2 or row[0].is_empty():
			continue
		var key := row[0]
		for i in range(1, min(row.size(), _locales.size() + 1)):
			translations[i - 1].add_message(key, row[i])
	for t in translations:
		TranslationServer.add_translation(t)
	f.close()

func get_locales() -> Array[String]:
	return _locales.duplicate()

func set_locale(loc: String) -> void:
	if loc in _locales:
		TranslationServer.set_locale(loc)
		language_changed.emit(loc)

func get_locale() -> String:
	return TranslationServer.get_locale()

func toggle_locale() -> void:
	if _locales.is_empty():
		return
	var idx := _locales.find(get_locale())
	idx = (idx + 1) % _locales.size()
	set_locale(_locales[idx])
