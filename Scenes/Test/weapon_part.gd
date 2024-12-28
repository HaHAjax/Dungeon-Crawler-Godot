@tool
class_name WeaponPart
extends Node3D

#@export var clear: bool:
	#get:
		#return false
	#set(value):
		#while get_child_count():
			#remove_child(get_child(0))

enum PartType {
	GRIP, ## weapon root, controls animations and type
	BLADE, # melee (sword/dagger/shield spike/bayonet)
	LIMBS, # ranged (bow/crossbow)
	GUARD, # defense (shield/crossguard/armor)
	GEM, # special abilities or bonus stats
}

@export var sockets: Array[PartType]:
	get:
		return sockets
	set(value):
		sockets = value
		var socketsNode = $Sockets
		if not socketsNode:
			return
		if socketsNode.get_child_count() != len(sockets):
			while socketsNode.get_child_count() < len(sockets):
				var marker = Socket.new(self)
				marker.name = "Socket "+str(socketsNode.get_child_count())
				socketsNode.add_child(marker)
				marker.owner = get_tree().edited_scene_root
			while socketsNode.get_child_count() > len(sockets):
				var last = socketsNode.get_child(socketsNode.get_child_count() - 1)
				socketsNode.remove_child(last)
				last.queue_free()

class Socket extends Marker3D:
	
	var _part: WeaponPart
	var _type: PartType
	
	func _init(part: WeaponPart) -> void:
		_part = part
	
	func _exit_tree() -> void:
		_part.sockets.remove_at(get_index())
	
	@export var type: PartType:
		get:
			return _part.sockets[get_index()]
		set(value):
			_part.sockets[get_index()] = value
	
	## If specified, will be joined with sockets with the same type and key
	## This allows for multiple copies of a part to appear on an item
	@export var key: String
