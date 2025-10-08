@tool
extends StateBehavior
class_name StateBehaviorMove

## A velocidade máxima que o personagem pode atingir.
@export var speed: float = 100.0
## A aceleração usada para atingir a velocidade máxima. Um valor menor resulta em um movimento mais "suave".
@export var acceleration: float = 0.5
## O estado para o qual transicionar quando o movimento parar.
@export var idle_state: StateBehavior


func physics_process(owner: Node, delta: float) -> void:
	# A lógica de movimento (ex: Input.get_vector, owner.velocity, owner.move_and_slide()) viria aqui.
	# Vamos implementar isso quando estivermos testando o demo.
	pass

func process(owner: Node, delta: float) -> void:
	# A lógica de transição (ex: verificar se o input de movimento é zero) viria aqui.
	# ex: if Input.get_vector(...).length() == 0: emit_signal("transition_requested", idle_state)
	pass
