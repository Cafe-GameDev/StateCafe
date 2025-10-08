# StateCafe - Plugin Design Document (PDD)

**Versão do Documento:** 1.0
**Data:** 2025-10-07
**Autor:** Gemini (em colaboração com Bruno)

---

## 1. Visão Geral e Filosofia

### 1.1. Conceito

O **StateCafe** é um framework avançado para Godot Engine 4.x, projetado para simplificar e potencializar a criação de lógicas de comportamento complexas. Ele implementa uma arquitetura de **Máquina de Estados Paralela e em Camadas (Layered/Parallel State Machine)**, onde comportamentos são encapsulados em `Resource`s reutilizáveis.

### 1.2. Filosofia

-   **Modularidade:** Comportamentos de movimento, combate e IA são domínios separados e autocontidos, que podem ser desenvolvidos e testados de forma independente.
-   **Reutilização:** Um `StateBehavior` (ex: `StateBehaviorAIPatrol`) pode ser criado uma vez e reutilizado em múltiplos tipos de inimigos com configurações diferentes.
-   **Design Visual e Reativo:** A lógica deve ser tão visual quanto possível, e o sistema deve ser reativo a eventos, integrando-se perfeitamente ao sistema de sinais e nós do Godot.
-   **`Resource` como Objeto Ativo:** Nossos `StateBehavior`s não são meros contêineres de dados. Eles são objetos inteligentes com sua própria lógica, estado interno e capacidade de emitir sinais para comunicar suas intenções. A arquitetura reflete a filosofia de que o próprio estado é inteligente, decidindo quando transicionar e não sendo constantemente verificado por um gerente externo.

### 1.3. Política de Versão e Compatibilidade

-   **Versão Alvo:** O StateCafe tem como alvo inicial o **Godot 4.5**.
-   **Compatibilidade Futura:** O projeto será ativamente mantido para garantir compatibilidade com versões futuras do Godot 4.x.
-   **Retrocompatibilidade:** Não haverá suporte para versões anteriores ao Godot 4.5, a fim de aproveitar os recursos mais recentes da engine e manter uma base de código limpa e moderna.

---

## 2. Arquitetura Principal

O sistema é composto por três elementos centrais que trabalham em conjunto para criar um sistema de comportamento em camadas.

### 2.1. `StateComponent` (O Gerenciador de Comportamentos)

-   **Tipo:** `Node`.
-   **Função:** É o motor de execução que vive em uma cena. Ele gerencia um conjunto de `StateBehavior`s ativos **simultaneamente**, organizados em "camadas" ou "domínios" funcionais.
-   **Propriedades Chave:**
    -   `@export var initial_behaviors: Array[Dictionary]`: Define os comportamentos iniciais e seus domínios no Inspector. A estrutura de cada entrada do dicionário é `{"domain": StringName, "behavior": StateBehavior}`.
    -   `var active_behaviors: Dictionary`: Armazena os `StateBehavior`s atualmente ativos, usando o nome do domínio como chave (ex: `{"movement": res://..., "action": res://...}`).
    -   `var _is_transitioning := false`: Um flag interno para garantir transições seguras e evitar loops.
-   **Sinais Emitidos:**
    -   `signal state_changed(domain: StringName, previous: Resource, next: Resource)`: Emitido após uma transição de estado bem-sucedida em um domínio.
    -   `signal state_entered(domain: StringName, state: Resource)`: Emitido quando um estado entra em um domínio.
    -   `signal state_exited(domain: StringName, state: Resource)`: Emitido quando um estado sai de um domínio.
-   **Lógica Principal:**
    1.  **Ciclo de Vida:** Em `_process` e `_physics_process`, itera sobre todos os `active_behaviors` e executa seus respectivos métodos, permitindo comportamentos paralelos (ex: andar e atirar).
    2.  **Gerenciador de Eventos:** Atua como um "broker". Ouve sinais de nós externos (configurados via Inspector) e os propaga para **todos** os `StateBehavior`s ativos através da função `handle_event()`.
    3.  **Executor de Transição:** Ouve o sinal `transition_requested(domain: StringName, next_behavior: Resource)` emitido pelos `StateBehavior`s e executa a troca de estado de forma segura, substituindo o behavior apenas no domínio especificado.
    4.  **`is_in_state(domain: StringName, state_class: StringName) -> bool`**: Função auxiliar para verificar se um domínio está em um estado específico.

### 2.2. `StateBehavior` (A Sub-Máquina / Domínio Funcional)

-   **Tipo:** `Resource`.
-   **Função:** Encapsula a lógica completa de um domínio funcional (Movimento, Combate, IA). É, na prática, uma máquina de estados autocontida que gerencia seus próprios **micro-estados** internamente (usando `Enums`, `Dictionaries`, etc.). Além disso, `StateBehavior`s podem exportar dicionários complexos para configurar detalhes específicos do estado (ex: `{"animation": "punch", "damage": 10}` para ataques, ou `{"speed": 150, "acceleration": 0.8}` para movimento). Futuramente, esses dicionários poderão ser substituídos por `Resource`s dedicados do plugin `DataCafe` para uma gestão de dados ainda mais robusta.
-   **Comunicação (Saída):**
    -   `signal transition_requested(domain: StringName, next_behavior: Resource)`: Sinal para solicitar a troca do behavior ativo dentro de um domínio específico.
    -   Pode emitir outros sinais específicos de ação (ex: `sound_requested`, `effect_spawned`).
-   **Comunicação (Entrada):**
    -   `func enter(owner: Node)`: Chamado uma vez quando o estado se torna ativo.
    -   `func exit(owner: Node)`: Chamado uma vez quando o estado deixa de ser ativo.
    -   `func process(owner: Node, delta: float)`: Chamado a cada frame do jogo.
    -   `func physics_process(owner: Node, delta: float)`: Chamado a cada frame de física.
    -   `func handle_event(owner: Node, event_name: StringName, payload: Variant)`: Método virtual que permite ao estado reagir a eventos externos.

### 2.3. `StateMachine` (O Autoload Singleton)

-   **Tipo:** `Node` (Singleton).
-   **Função:** Orquestrador de alto nível com um duplo papel.
-   **Papel 1 (Observador de Entidades):** Mantém um registro de todos os `StateComponent`s ativos na cena para depuração através do `StatePanel`.
-   **Papel 2 (Executor de Estados Globais):** Funciona como sua própria máquina de estados para gerenciar o fluxo geral do jogo (menus, níveis, pausa), utilizando `StateBehavior`s de alto nível como `GameStateScene`.
    -   **`GameStateScene`**: Um `StateBehavior` especializado para gerenciar transições entre cenas completas do jogo. Possui uma propriedade `@export var scene: PackedScene` e sua lógica `enter` lida com `change_scene_to_packed`.

---

## 3. Estrutura de Arquivos Proposta

```
addons/statecafe/
├── plugin.cfg
├── components/
│   ├── state_component.gd
│   └── state_component.tscn
├── resources/
│   ├── state_config.tres
│   └── behaviors/ # Subpasta para todos os StateBehaviors (recursos)
│       ├── state_behavior.gd
│       ├── state_behavior_idle.gd
│       ├── state_behavior_move.gd
│       ├── state_behavior_attack.gd
│       └── game_state_scene.gd
├── panel/
│   ├── state_panel.gd
│   ├── state_panel.tscn
│   └── state_modal.tscn # Para edição detalhada e criação de estados
├── scripts/
│   ├── editor_plugin.gd
│   └── state_machine.gd
└── icons/
    ├── state_behavior_icon.svg
    └── state_component_icon.svg
```

---

## 4. Catálogo de `StateBehavior`s Propostos

Este documento define uma lista de 30 `StateBehavior`s de alto nível propostos para a biblioteca do **StateCafe**. Cada item representa uma **sub-máquina de estados** completa para um domínio funcional, gerenciando seus próprios micro-estados internamente.

| # | Nome do Resource (`class_name`) | Função Principal | Micro-Estados Internos (Exemplos) | Estrutura Sugerida |
|---|---|---|---|---|
| **MOVIMENTO (JOGADOR/NPC)** | | | | |
| 1 | `StateBehaviorGroundMove` | Gerencia todo o movimento terrestre. | `IDLE`, `WALK`, `RUN`, `CROUCH`, `SPRINT` | `Enum` |
| 2 | `StateBehaviorAerial` | Gerencia estados no ar. | `JUMP`, `FALL`, `DOUBLE_JUMP`, `WALL_JUMP` | `Enum` |
| 3 | `StateBehaviorClimbing` | Gerencia a lógica de escalar superfícies. | `LATCHED`, `CLIMB_UP`, `CLIMB_DOWN`, `LEDGE_GRAB` | `Enum` |
| 4 | `StateBehaviorSwimming` | Gerencia movimento dentro da água. | `TREAD_WATER`, `SWIM_FORWARD`, `DIVE`, `SURFACE` | `Enum` |
| 5 | `StateBehaviorVehicle` | Controla o personagem quando ele está em um veículo. | `ENTERING`, `DRIVING`, `EXITING` | `Dictionary` (para tipos de veículo) |
| 6 | `StateBehaviorPushPull` | Gerencia a lógica de empurrar/puxar objetos. | `GRABBING`, `PUSHING`, `PULLING`, `RELEASING` | `Enum` |
| **COMBATE** | | | | |
| 7 | `StateBehaviorMeleeAttack` | Gerencia sequências de ataques corpo a corpo. | `ATTACK_1`, `ATTACK_2`, `ATTACK_3` (combo), `CHARGED_ATTACK` | `Array` de `Dictionary` |
| 8 | `StateBehaviorRangedAttack` | Gerencia a lógica de ataques à distância. | `AIMING`, `CHARGING`, `FIRE`, `RELOADING` | `Enum` |
| 9 | `StateBehaviorMagic` | Gerencia o uso de habilidades mágicas. | `CASTING`, `CHANNELING`, `ON_COOLDOWN` | `Dictionary` (para magias) |
| 10 | `StateBehaviorDefense` | Gerencia ações defensivas. | `IDLE`, `BLOCKING`, `PARRY`, `DODGE_ROLL` | `Enum` |
| 11 | `StateBehaviorTargeting` | Gerencia o sistema de mira/trava em alvos. | `NO_TARGET`, `TARGET_LOCKED`, `SWITCHING_TARGET` | `Enum` |
| 12 | `StateBehaviorHitReaction` | Controla a reação do personagem ao sofrer dano. | `FLINCH`, `STUNNED`, `KNOCKBACK`, `INVINCIBLE_FRAMES` | `Enum` |
| **INTELIGÊNCIA ARTIFICIAL (IA)** | | | | |
| 13 | `StateBehaviorAIPatrol` | Define o comportamento de patrulha de uma IA. | `MOVING_TO_POINT`, `WAITING`, `SCANNING_AREA` | `Enum` + `Array` (waypoints) |
| 14 | `StateBehaviorAIChase` | Define a lógica de perseguição de um alvo. | `AGGRESSIVE`, `TACTICAL_MOVE`, `LOST_TARGET` | `Enum` |
| 15 | `StateBehaviorAIAttack` | Gerencia as decisões e padrões de ataque da IA. | `SELECT_ATTACK`, `EXECUTE_MELEE`, `EXECUTE_RANGED` | `Dictionary` |
| 16 | `StateBehaviorAIFlee` | Define o comportamento de fuga de uma ameaça. | `FLEEING`, `HIDING`, `REASSESSING` | `Enum` |
| 17 | `StateBehaviorAISeekCover` | Gerencia a busca e o uso de cobertura. | `FINDING_COVER`, `MOVING_TO_COVER`, `IN_COVER` | `Enum` |
| 18 | `StateBehaviorAISpawn` | Controla a animação e lógica de surgimento do inimigo. | `SPAWNING`, `IDLE_TRANSITION` | `Enum` |
| 19 | `StateBehaviorAIDeath` | Controla a sequência de morte e o que acontece depois. | `DYING`, `DROP_LOOT`, `FADE_OUT` | `Enum` |
| **INTERAÇÃO E JOGABILIDADE** | | | | |
| 20 | `StateBehaviorInteract` | Gerencia a interação com objetos no mundo. | `APPROACHING`, `INTERACTING`, `COOLDOWN` | `Enum` |
| 21 | `StateBehaviorDialogue` | Controla o estado do personagem durante um diálogo. | `TALKING`, `LISTENING`, `WAITING_CHOICE` | `Enum` |
| 22 | `StateBehaviorInventory` | Ativado quando o jogador abre o menu de inventário. | `OPEN`, `NAVIGATING`, `CLOSED` | `Enum` |
| **FLUXO DE JOGO (GLOBAL)** | | | | |
| 23 | `GameStateScene` | Carrega e transiciona para uma cena inteira. | `LOADING`, `ACTIVE` | `PackedScene` |
| 24 | `GameStateMenu` | Gerencia a navegação em um menu complexo. | `MAIN_SCREEN`, `OPTIONS`, `CREDITS` | `Dictionary` |
| 25 | `GameStateLoading` | Controla uma tela de carregamento assíncrono. | `LOADING_ASSETS`, `WAITING_INPUT`, `FADING_OUT` | `Enum` |
| 26 | `GameStateCutscene` | Gerencia a reprodução de uma cutscene. | `PLAYING`, `PAUSED`, `SKIPPING` | `Enum` |
| 27 | `GameStatePaused` | Controla o estado de pausa global do jogo. | `PAUSED`, `RESUMING` | `Enum` |
| **UI (INTERFACE DE USUÁRIO)** | | | | |
| 28 | `StateBehaviorUIPanel` | Gerencia os estados de um painel de UI complexo. | `OPENING`, `IDLE`, `CLOSING`, `CLOSED` | `Enum` |
| 29 | `StateBehaviorTutorial` | Controla uma sequência de eventos de um tutorial. | `SHOWING_TEXT`, `WAITING_ACTION`, `COMPLETED` | `Array` de `Dictionary` |
| 30 | `StateBehaviorItemDrag` | Gerencia o estado de arrastar um item em um inventário. | `DRAGGING`, `CAN_DROP`, `INVALID_DROP` | `Enum` |

---

## 5. Arquitetura de Interface (UI)

A interface do StateCafe é dividida em componentes modulares para uma experiência de usuário limpa e focada.

-   **`CafePanel` (O Host da Dock):** Um contêiner simples que fica na dock lateral do editor. Sua única função é abrigar os painéis dos diferentes plugins da suíte CafeEngine.

-   **`StatePanel` (O Navegador / Visualizador):** O painel principal do StateCafe, filho do `CafePanel`. Sua responsabilidade é a **visualização e navegação** da máquina de estados.
    -   **Duplo Propósito:**
        1.  **Micro-Visão (Nível de Entidade):** Exibe um editor de grafos (`GraphEdit`) para a máquina de estados de um `StateComponent` selecionado na cena.
        2.  **Macro-Visão (Nível de Jogo):** Exibe o grafo da máquina de estados global, gerenciada pelo autoload `StateMachine`.
    -   **Funcionalidades:**
        -   **Seletor de Contexto:** `OptionButton` para alternar entre "StateMachine Global" e `StateComponent`s selecionados.
        -   **Editor de Grafos (`GraphEdit`):** Área principal para exibir `StateBehavior`s como `GraphNode`s e suas transições.
        -   **Navegação e Edição Rápida:** Duplo clique em nós para abrir scripts/resources, botões para inspecionar `StateMachine`.
        -   **Toolbox de Estados:** Área lateral listando `StateBehavior`s disponíveis para arrastar e criar novos estados.
        -   **Integração com Inspector:** Selecionar um nó no grafo exibe suas propriedades no Inspector principal do Godot.

-   **`StateModal` (O Editor Pop-up):** Uma janela modal que surge para tarefas de edição detalhadas, evitando sobrecarregar o `StatePanel`. Exemplos de uso:
    -   **Editor de Transições:** Ao clicar em uma conexão no grafo, um `StateModal` abre para configurar as condições daquela transição.
    -   **Criador de Estado:** Um `StateModal` pode guiar o usuário na criação de um novo `StateBehavior` a partir de um template.

---

## 6. Plano de Desenvolvimento em Fases

### Fase 1: Fundação (MVP - Minimum Viable Product)

-   [ ] **Criar Script Base:** Implementar `state_behavior.gd` com suas funções virtuais e o sinal `transition_requested`.
-   [ ] **Criar Componente:** Implementar `state_component.gd` com a arquitetura de domínios, transições seguras (`_is_transitioning`), e sinais (`state_changed`, `state_entered`, `state_exited`).
-   [ ] **Criar Estados Essenciais:** Desenvolver `StateBehaviorIdle` e `StateBehaviorMove` (baseados no `demo01.md` e na arquitetura de sinais).
-   [ ] **Criar `GameStateScene`:** Implementar o `StateBehavior` para gerenciamento de cenas globais.
-   [ ] **Ajustar Estrutura de Pastas:** Mover `StateBehavior`s para `resources/behaviors/`.
-   **Objetivo:** Ter um sistema funcional de estados paralelos, com transições seguras e a base para estados de jogo globais.

### Fase 2: Integração como Plugin Godot e Melhorias no Inspector

-   [ ] **Criar `plugin.cfg`:** Definir o plugin para o Godot.
-   [ ] **Implementar `editor_plugin.gd`:**
    -   Registrar `StateBehavior` e `StateComponent` como tipos customizados com ícones próprios.
    -   Adicionar uma opção no menu `Create Resource` para facilitar a criação de `StateBehavior`s.
    -   Configurar Autoload para `StateMachine`.
-   [ ] **Inspector Aprimorado (Nível 1):** Utilizar `_get_property_list()` nos `StateBehavior`s para organizar propriedades em categorias (`logic/`, `transitions/`).
-   **Objetivo:** Transformar o sistema em um plugin fácil de instalar e usar, com melhor clareza no Inspector.

### Fase 3: Expansão da Biblioteca de Estados e Controles Customizados

-   [ ] **Desenvolver `StateBehaviorAttack`:** Criar um estado de ataque que use `AnimationPlayer` e sinais.
-   [ ] **Desenvolver `StateBehaviorJump`:** Criar um estado de pulo que lide com gravidade e detecção de chão.
-   [ ] **Desenvolver outros `StateBehavior`s:** Implementar mais estados do catálogo (`behaviors_plan01.md`) para cobrir domínios comuns.
-   [ ] **Controles Customizados no Inspector (Nível 2):** Implementar `EditorInspectorPlugin` para adicionar botões de atalho, validações visuais e previews no Inspector para `StateBehavior`s.
-   **Objetivo:** Oferecer uma biblioteca robusta de estados e uma experiência de edição mais interativa.

### Fase 4: Painel de UI e Ferramentas de Depuração

-   [ ] **Criar `state_panel.tscn` e `state_panel.gd`:** Desenvolver a UI principal do plugin, que será docada no editor.
-   [ ] **Implementar `StateModal`:** Criar a cena `state_modal.tscn` para pop-ups de edição.
-   [ ] **Funcionalidades do Painel:**
    -   Visualizar a máquina de estados do `StateComponent` selecionado (Micro-Visão).
    -   Visualizar a máquina de estados global (`StateMachine`) (Macro-Visão).
    -   Mostrar o estado ativo em tempo real durante a execução do jogo.
    -   Botões de atalho para criar novos `StateBehavior` resources.
-   **Objetivo:** Fornecer feedback visual e ferramentas que acelerem o desenvolvimento e a depuração de máquinas de estado.

### Fase 5: Documentação e Exemplos

-   [ ] **Documentar o Código:** Adicionar comentários claros em todas as classes e funções principais.
-   [ ] **Criar Documentação Externa:** Escrever guias no formato Markdown na pasta `docs/` do plugin.
-   [ ] **Criar um Projeto Demo Completo:** Montar um pequeno jogo ou cena de exemplo que utilize diversos estados e funcionalidades do StateCafe.
-   **Objetivo:** Garantir que o plugin seja acessível e fácil de aprender para novos usuários.

---

## 7. Considerações Futuras (Pós-MVP)

-   **Editor de Grafos Visual (Nível 3):** Uma ferramenta de `GraphEdit` para conectar visualmente os estados e suas transições, gerando os `resources` automaticamente.
-   **Máquinas de Estado Hierárquicas (Sub-states):** Permitir que um estado contenha sua própria máquina de estados interna (ex: o estado `ON_GROUND` pode ter sub-estados como `idle`, `run`, `attack`).
-   **Recurso de Transição:** Criar um `StateTransition.tres` para encapsular a lógica de quando uma transição deve ocorrer, em vez de colocar essa lógica dentro do `process` de cada estado.
-   **FSM Serializer:** Exportar/importar uma FSM inteira (como `.tres`).
-   **Behavior Templates:** Menu no editor para criar automaticamente um novo script herdando de `StateBehavior`.
-   **Live Hot-Reload:** Recarregar estados modificados sem reiniciar o jogo (útil para debugging de IA).
