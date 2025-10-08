# Planejamento do StatePanel: Gerenciador Visual de Estados

Este documento detalha a visão e as funcionalidades do `StatePanel`, a interface gráfica central do plugin StateCafe. O painel servirá como uma ferramenta de duplo propósito: para visualizar e gerenciar tanto as máquinas de estado de **entidades individuais** quanto a máquina de estado **global do jogo**.

---

## 1. O Duplo Propósito do Painel

O `StatePanel` terá dois contextos de operação:

1.  **Micro-Visão (Nível de Entidade):**
    -   **Gatilho:** Quando o desenvolvedor seleciona um nó na cena que contém um `StateComponent`.
    -   **Função:** O painel exibe um editor de grafos (`GraphEdit`) mostrando a máquina de estados específica daquele nó (ex: os estados de `idle`, `move`, `attack` do Player).
    -   **Utilidade:** Permite depurar e visualizar a lógica de um personagem ou objeto em tempo real.

2.  **Macro-Visão (Nível de Jogo):**
    -   **Gatilho:** Acessado através de um seletor no próprio painel (ex: um dropdown "Contexto: Global").
    -   **Função:** O painel exibe o grafo da máquina de estados global, gerenciada pelo autoload `StateMachine`.
    -   **Utilidade:** Permite projetar e visualizar o fluxo principal do jogo (ex: `MainMenu` -> `Level_01` -> `BossFight` -> `GameOver`).

---

## 2. O Resource para Estados de Jogo: `GameStateScene`

Para gerenciar o fluxo de cenas, precisamos de um novo tipo de `StateBehavior`. Minha sugestão de nome é **`GameStateScene`**.

-   **Tipo:** `Resource`, herdando de `StateBehavior`.
-   **Propósito:** Representa um estado principal do jogo que é definido por uma cena inteira.
-   **Script:** `game_state_scene.gd`
-   **Propriedades Principais:**
    -   `@export var scene: PackedScene`: A cena a ser carregada quando este estado se tornar ativo.
-   **Lógica Principal:**
    -   A função `enter(owner: Node)` deste resource irá conter a lógica para a transição de cena:
        ```gdscript
        func enter(owner: Node) -> void:
            # O 'owner' neste caso seria o próprio autoload StateMachine.
            owner.get_tree().change_scene_to_packed(scene)
        ```

---

## 3. Funcionalidades e Layout do `StatePanel`

O painel será projetado para ser uma ferramenta visual poderosa, inspirada em Blueprints.

1.  **Seletor de Contexto (Topo do Painel):**
    -   Um `OptionButton` (dropdown) que permite ao usuário alternar entre "StateMachine Global" e o `StateComponent` atualmente selecionado na árvore de cena.

2.  **Editor de Grafos (`GraphEdit`):**
    -   A área principal do painel.
    -   Exibirá os `StateBehavior`s como nós (`GraphNode`).
    -   As conexões entre os nós representarão as transições.

3.  **Navegação e Edição Rápida:**
    -   **Botão "Inspecionar StateMachine":** Um botão que, quando clicado, seleciona o `state_machine.tscn` no FileSystem, permitindo fácil acesso.
    -   **Duplo Clique em Nós:** Ao dar um duplo clique em um nó do grafo, o Godot abrirá o script (`.gd`) ou o `Resource` (`.tres`) daquele estado para edição rápida.

4.  **Toolbox de Estados:**
    -   Uma pequena área lateral no painel que lista todos os tipos de `StateBehavior` disponíveis (ex: `StateBehaviorMove`, `StateBehaviorAttack`, `GameStateScene`).
    -   O usuário poderá arrastar esses tipos para o grafo para criar e configurar novos estados rapidamente.

5.  **Integração com o Inspector:**
    -   Ao selecionar um nó no grafo, o Inspector principal do Godot deverá exibir as propriedades do `StateBehavior` correspondente, permitindo a edição direta de `speed`, `damage`, `scene`, etc.

---

## 4. Fluxo de Uso (Exemplo de Nível de Jogo)

1.  O dev cria três `Resources` do tipo `GameStateScene`: `MainMenu.tres`, `Level1.tres`, e `GameOver.tres`.
2.  Em cada um, ele arrasta a cena correspondente (`main_menu.tscn`, etc.) para a propriedade `Scene`.
3.  No `StatePanel`, ele seleciona o contexto "StateMachine Global".
4.  Ele arrasta os três `.tres` para o grafo.
5.  Ele conecta `MainMenu` a `Level1` (a transição seria acionada por um sinal global como `start_game_pressed`).
6.  Ele conecta `Level1` a `GameOver` (a transição seria acionada por `player_died`).
7.  O `StateMachine` (autoload) é configurado para iniciar com o estado `MainMenu.tres`.

Com isso, o `StatePanel` se torna o centro de comando para toda a lógica de fluxo do jogo, de forma visual e intuitiva.
