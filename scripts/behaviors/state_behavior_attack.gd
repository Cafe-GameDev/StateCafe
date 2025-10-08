@tool
extends StateBehavior
class_name StateBehaviorAttack

## O nome da animação a ser tocada pelo AnimationPlayer do owner.
@export var attack_animation_name: StringName

## A quantidade de dano que este ataque causa.
@export var damage: int = 10

## O tempo de espera (em segundos) após o ataque antes de poder fazer outra ação.
@export var attack_cooldown: float = 0.5

## O estado para o qual transicionar após o ataque ser concluído.
@export var idle_state: StateBehavior


func enter(owner: Node) -> void:
	# A lógica para iniciar o ataque viria aqui.
	# ex: owner.get_node("AnimationPlayer").play(attack_animation_name)
	# A transição para o próximo estado seria idealmente controlada pelo sinal 'animation_finished'
	# do AnimationPlayer, que então emitiria o 'transition_requested'.
	pass
