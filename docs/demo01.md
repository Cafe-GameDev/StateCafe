# StateCafe - Demo 01: Máquina de Estados (Idle/Move)

Este documento descreve o primeiro caso de uso para o plugin **StateCafe**: criar uma máquina de estados simples para um personagem 2D que pode alternar entre os estados "Parado" (Idle) and "Movendo-se" (Move).

## Objetivo

Construir um `CharacterBody2D` que:
1.  Começa no estado `Idle`.
2.  Quando as teclas de movimento são pressionadas, transiciona para o estado `Move`.
3.  No estado `Move`, o personagem se move.
4.  Quando as teclas de movimento são soltas, transiciona de volta para o estado `Idle`.

## Componentes Necessários (Fase 1)

1.  **`StateBehavior.gd`**: A classe base para todos os `Resource` de estado.
2.  **`StateComponent.tscn`**: O nó que executa a máquina de estados.
3.  **`Player.tscn`**: Uma cena de personagem básica (`CharacterBody2D`).

---

## Passo 1: Criar os `StateBehavior` Resources

Primeiro, criamos os `Resources` que definirão cada comportamento.

### A. Estado `Idle` (Parado)

1.  **Criar o Script:** Crie um novo script `IdleState.gd` que herda de `StateBehavior`.

    ```gdscript
    # IdleState.gd
    @tool
    extends StateBehavior
    class_name IdleState

    # Exportamos uma referência para o próximo estado (Move) para que possamos transicionar.
    @export var move_state: StateBehavior

    # A função enter não faz nada neste caso.
    func enter(owner: Node) -> void:
        super.enter(owner)
        # Poderíamos tocar uma animação de "idle" aqui.
        # owner.get_node("AnimationPlayer").play("idle")

    # Verificamos a cada frame se devemos transicionar.
    func process(owner: Node, delta: float) -> Resource:
        # Se qualquer tecla de movimento for pressionada, pedimos a transição para o move_state.
        if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").length() > 0:
            return move_state
        # Se não, continuamos no estado atual.
        return null
    ```

2.  **Criar o Resource:** No FileSystem, clique com o botão direito -> `Create Resource...` -> selecione `StateBehavior`. Salve como `PlayerIdle.tres`. No Inspector, anexe o script `IdleState.gd` a ele.

### B. Estado `Move` (Movendo-se)

1.  **Criar o Script:** Crie um novo script `MoveState.gd`.

    ```gdscript
    # MoveState.gd
    @tool
    extends StateBehavior
    class_name MoveState

    # Exportamos uma referência para o estado Idle para a transição de volta.
    @export var idle_state: StateBehavior
    @export var speed: float = 100.0

    # A cada frame de física, aplicamos o movimento.
    func physics_process(owner: Node, delta: float) -> Resource:
        var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
        owner.velocity = direction * speed
        owner.move_and_slide()
        return null # Não transiciona na física.

    # A cada frame, verificamos se devemos parar.
    func process(owner: Node, delta: float) -> Resource:
        # Se as teclas de movimento foram soltas, transicionamos de volta para o idle_state.
        if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").length() == 0:
            return idle_state
        return null
    ```

2.  **Criar o Resource:** Crie outro `Resource` do tipo `StateBehavior`, salve como `PlayerMove.tres`, e anexe o script `MoveState.gd`.

### C. Conectar os Resources

1.  Selecione `PlayerIdle.tres`. No Inspector, arraste `PlayerMove.tres` para a propriedade `Move State`.
2.  Selecione `PlayerMove.tres`. No Inspector, arraste `PlayerIdle.tres` para a propriedade `Idle State`.

---

## Passo 2: Configurar a Cena do Player

1.  Crie uma cena `Player.tscn` com um `CharacterBody2D` como raiz.
2.  Adicione um `Sprite2D` e um `CollisionShape2D` como filhos.
3.  **Adicione o `StateComponent`:** Instancie `StateComponent.tscn` como um filho do nó raiz `Player`.
4.  **Definir Estado Inicial:** Selecione o `StateComponent` na árvore de cena. No Inspector, arraste o resource `PlayerIdle.tres` para a propriedade `Initial State`.

A estrutura da cena do Player deve ser:

```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
└── StateComponent (o nosso nó)
```

---

## Passo 3: Executar e Testar

Rode a cena. O personagem deve:
- Permanecer parado (`IdleState`).
- Começar a se mover quando você pressionar as teclas direcionais (`MoveState`).
- Parar de se mover e voltar ao estado `Idle` quando você soltar as teclas.

Este ciclo de `enter`, `process`/`physics_process`, e `exit` é o coração do **StateCafe**.
