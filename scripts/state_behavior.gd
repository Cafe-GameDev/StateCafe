@tool
extends Resource
class_name StateBehavior

# Sinal emitido para solicitar uma transição para um novo estado.
# O StateComponent ouvirá este sinal e gerenciará a transição de forma segura.
signal transition_requested(next_state: Resource)

# Chamado uma vez quando a máquina de estados entra neste estado.
# 'owner' é o nó que possui o StateComponent (ex: o Player, Inimigo, etc.).
func enter(owner: Node) -> void:
	pass

# Chamado uma vez quando a máquina de estados sai deste estado.
# Ideal para qualquer lógica de limpeza.
func exit(owner: Node) -> void:
	pass

# Chamado a cada frame do jogo. Lógica de input e transições geralmente vêm aqui.
func process(owner: Node, delta: float) -> void:
	pass

# Chamado a cada frame de física. Ideal para lógica de movimento e colisões.
func physics_process(owner: Node, delta: float) -> void:
	pass
