extends Area2D

func _on_body_entered(body: Node2D):
	print("Collision detected between:", self.name, "and", body.name)

func _on_area_entered(area: Area2D):
	print("Collision detected between:", self.name, "and", area.name)
