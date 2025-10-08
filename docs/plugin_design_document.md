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
-   **`Resource` como Objeto Ativo:** Nossos `StateBehavior`s não são meros contêineres de dados. Eles são objetos inteligentes com sua própria lógica, estado interno e capacidade de emitir sinais para comunicar suas intenções.

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
-   **Lógica Principal:**
    1.  **Ciclo de Vida:** Em `_process` e `_physics_process`, itera sobre todos os `active_behaviors` e executa seus respectivos métodos, permitindo comportamentos paralelos (ex: andar e atirar).
    2.  **Gerenciador de Eventos:** Atua como um "broker". Ouve sinais de nós externos (configurados via Inspector) e os propaga para **todos** os `StateBehavior`s ativos através da função `handle_event()`.
    3.  **Executor de Transição:** Ouve o sinal `transition_requested(domain: StringName, next_behavior: Resource)` emitido pelos `StateBehavior`s e executa a troca de estado de forma segura, substituindo o behavior apenas no domínio especificado.

### 2.2. `StateBehavior` (A Sub-Máquina / Domínio Funcional)

-   **Tipo:** `Resource`.
-   **Função:** Encapsula a lógica completa de um domínio funcional (Movimento, Combate, IA). É, na prática, uma máquina de estados autocontida que gerencia seus próprios **micro-estados** internamente (usando `Enums`, `Dictionaries`, etc.).
-   **Comunicação (Saída):**
    -   `signal transition_requested(domain: StringName, next_behavior: Resource)`: Sinal para solicitar a troca do behavior ativo dentro de um domínio específico.
    -   Pode emitir outros sinais específicos de ação (ex: `sound_requested`, `effect_spawned`).
-   **Comunicação (Entrada):**
    -   `func handle_event(owner: Node, event_name: StringName, payload: Variant)`: Método virtual que permite ao estado reagir a eventos externos.

### 2.3. `StateMachine` (O Autoload Singleton)

-   **Tipo:** `Node` (Singleton).
-   **Função:** Orquestrador de alto nível com um duplo papel.
-   **Papel 1 (Observador de Entidades):** Mantém um registro de todos os `StateComponent`s ativos na cena para depuração através do `StatePanel`.
-   **Papel 2 (Executor de Estados Globais):** Funciona como sua própria máquina de estados para gerenciar o fluxo geral do jogo (menus, níveis, pausa), utilizando `StateBehavior`s de alto nível como `GameStateScene`.

---

## 3. Catálogo de `StateBehavior`s Propostos

(Esta seção consolida o `behaviors_plan01.md`)

| # | Nome do Resource (`class_name`) | Função Principal | Micro-Estados Internos (Exemplos) | Estrutura Sugerida |
|---|---|---|---|---|
| **MOVIMENTO** | | | | |
| 1 | `StateBehaviorMove` | Gerencia movimento terrestre e aéreo. | `IDLE`, `WALK`, `RUN`, `JUMP`, `FALL` | `Enum` |
| 2 | `StateBehaviorClimbing` | Gerencia a lógica de escalar superfícies. | `LATCHED`, `CLIMB_UP`, `CLIMB_DOWN` | `Enum` |
| ... | *(e os outros comportamentos que definimos)* | ... | ... | ... |

---

## 4. Arquitetura de Interface (UI)

A interface do StateCafe é dividida em componentes modulares para uma experiência de usuário limpa e focada.

-   **`CafePanel` (O Host da Dock):** Um contêiner simples que fica na dock lateral do editor. Sua única função é abrigar os painéis dos diferentes plugins da suíte CafeEngine.

-   **`StatePanel` (O Navegador / Visualizador):** O painel principal do StateCafe, filho do `CafePanel`. Sua responsabilidade é a **visualização e navegação** da máquina de estados. É aqui que o `GraphEdit` reside, mostrando o "mapa" dos `StateBehavior`s e suas possíveis transições.

-   **`StateModal` (O Editor Pop-up):** Uma janela modal que surge para tarefas de edição detalhadas, evitando sobrecarregar o `StatePanel`. Exemplos de uso:
    -   **Editor de Transições:** Ao clicar em uma conexão no grafo, um `StateModal` abre para configurar as condições daquela transição.
    -   **Criador de Estado:** Um `StateModal` pode guiar o usuário na criação de um novo `StateBehavior` a partir de um template.
