# Plano de Desenvolvimento: StateCafe

Este documento detalha o plano de desenvolvimento para o plugin **StateCafe**, um sistema para democratizar a criação e gerenciamento de Máquinas de Estado Finito (FSM) no Godot Engine.

---

## 1. Visão Geral e Filosofia

-   **Objetivo Principal:** Simplificar o processo de criação de lógicas de estado complexas para personagens e outros objetos de jogo, tornando-o mais visual, modular e reutilizável.
-   **Filosofia Central:** Utilizar `Resource` para definir comportamentos (estados). Isso permite que os desenvolvedores criem, configurem e reutilizem estados através do Inspector do Godot, em vez de escrever código monolítico.

---

## 2. Arquitetura dos Componentes

O sistema será composto por três tipos principais de elementos:

1.  **`StateBehavior` (Resource):**
    -   **Descrição:** A classe base para todos os estados. É um `Resource` que contém a lógica de um estado específico.
    -   **Script:** `state_behavior.gd`
    -   **Interface (Funções Virtuais):**
        -   `enter(owner: Node)`: Executada quando o estado se torna ativo.
        -   `exit(owner: Node)`: Executada quando o estado deixa de ser ativo.
        -   `process(owner: Node, delta: float) -> Resource`: Executada a cada frame. Retorna um novo `StateBehavior` para transicionar, ou `null` para permanecer.
        -   `physics_process(owner: Node, delta: float) -> Resource`: Executada a cada frame de física.

2.  **`StateComponent` (Node):**
    -   **Descrição:** O "motor" da máquina de estados. É um nó que deve ser adicionado como filho do objeto que será controlado (o `owner`).
    -   **Cena/Script:** `state_component.tscn` / `state_component.gd`
    -   **Funcionalidades:**
        -   Gerencia o `current_state`.
        -   Possui uma propriedade `@export var initial_state: StateBehavior` para definir o estado inicial no editor.
        -   Chama as funções `enter`, `exit`, `process` e `physics_process` do estado ativo, passando o `owner` (seu nó pai) como parâmetro.
        -   Gerencia as transições de estado de forma segura.

3.  **`StateMachine` (Autoload/Singleton):**
    -   **Descrição:** Um nó global para gerenciar funcionalidades de alto nível.
    -   **Script:** `state_machine.gd`
    -   **Funcionalidades Planejadas:**
        -   Registro de todas as máquinas de estado ativas para depuração.
        -   Funções globais como `pause_all_state_machines()`.
        -   (Futuro) Gerenciamento de estados globais do jogo (ex: `GAME_PAUSED`, `IN_CUTSCENE`).

---

## 3. Estrutura de Arquivos Proposta

```
addons/statecafe/
├── plugin.cfg
├── components/
│   ├── state_component.gd
│   └── state_component.tscn
├── resources/
│   └── state_config.tres
├── panel/
│   ├── state_panel.gd
│   └── state_panel.tscn
├── scripts/
│   ├── editor_plugin.gd
│   ├── state_machine.gd
│   ├── state_behavior.gd
│   └── behaviors/ # Subpasta para exemplos de estados
│       ├── state_behavior_idle.gd
│       ├── state_behavior_move.gd
│       └── state_behavior_attack.gd
└── icons/
    ├── state_behavior_icon.svg
    └── state_component_icon.svg
```

---

## 4. Plano de Desenvolvimento em Fases

### Fase 1: Fundação (MVP - Minimum Viable Product)

-   [ ] **Criar Script Base:** Implementar `state_behavior.gd` com suas funções virtuais.
-   [ ] **Criar Componente:** Implementar `state_component.gd` e sua cena `.tscn`.
-   [ ] **Criar Estados de Teste:** Desenvolver `StateBehaviorIdle` e `StateBehaviorMove` como prova de conceito.
-   [ ] **Criar Demo Inicial:** Construir a cena de teste descrita em `demo01.md` para validar a funcionalidade principal.
-   **Objetivo:** Ter um personagem que se move e para, controlado 100% pelos `StateBehavior` resources.

### Fase 2: Integração como Plugin Godot

-   [ ] **Criar `plugin.cfg`:** Definir o plugin para o Godot.
-   [ ] **Implementar `editor_plugin.gd`:**
    -   Registrar `StateBehavior` e `StateComponent` como tipos customizados com ícones próprios.
    -   Adicionar uma opção no menu `Create Resource` para facilitar a criação de `StateBehavior`s.
-   [ ] **Configurar Autoload:** Adicionar o `StateMachine` à lista de singletons do projeto via script.
-   **Objetivo:** Transformar o sistema em um plugin fácil de instalar e usar, com boa integração ao editor.

### Fase 3: Expansão da Biblioteca de Estados

-   [ ] **Desenvolver `StateBehaviorAttack`:** Criar um estado de ataque que use `AnimationPlayer` e sinais.
-   [ ] **Desenvolver `StateBehaviorJump`:** Criar um estado de pulo que lide com gravidade e detecção de chão.
-   [ ] **Desenvolver `StateBehaviorMovie`:** Para controle de cutscenes simples.
-   **Objetivo:** Oferecer uma biblioteca de estados comuns e bem documentados que sirvam como base para os usuários.

### Fase 4: Painel de UI e Ferramentas de Depuração

-   [ ] **Criar `state_panel.tscn` e `state_panel.gd`:** Desenvolver a UI principal do plugin, que será docada no editor.
-   [ ] **Funcionalidades do Painel:**
    -   Visualizar a máquina de estados do `StateComponent` selecionado.
    -   Mostrar o estado ativo em tempo real durante a execução do jogo.
    -   Botões de atalho para criar novos `StateBehavior` resources.
-   **Objetivo:** Fornecer feedback visual e ferramentas que acelerem o desenvolvimento e a depuração de máquinas de estado.

### Fase 5: Documentação e Exemplos

-   [ ] **Documentar o Código:** Adicionar comentários claros em todas as classes e funções principais.
-   [ ] **Criar Documentação Externa:** Escrever guias no formato Markdown na pasta `docs/` do plugin.
-   [ ] **Criar um Projeto Demo Completo:** Montar um pequeno jogo ou cena de exemplo que utilize diversos estados e funcionalidades do StateCafe.
-   **Objetivo:** Garantir que o plugin seja acessível e fácil de aprender para novos usuários.

---

## 5. Considerações Futuras (Pós-MVP)

-   **Máquinas de Estado Hierárquicas (Sub-states):** Permitir que um estado contenha sua própria máquina de estados interna (ex: o estado `ON_GROUND` pode ter sub-estados como `idle`, `run`, `attack`).
-   **Editor Visual de Estados:** Uma ferramenta de `GraphEdit` para conectar visualmente os estados e suas transições, gerando os `resources` automaticamente.
-   **Recurso de Transição:** Criar um `StateTransition.tres` para encapsular a lógica de quando uma transição deve ocorrer, em vez de colocar essa lógica dentro do `process` de cada estado.
