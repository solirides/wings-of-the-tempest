extends Resource
class_name MonumentEffect

@export var path_to_stat:String = ""
# reference to a stat
@export var stat_to_modify:Stat
@export var modifiers:Array[StatModifier] = []
