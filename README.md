# StateMachine - Plugin Design Document (PDD)

[![StateMachine](https://img.shields.io/badge/StateMachine-v1.0.0-478cbf?style=for-the-badge)](https://www.cafegame.dev/pt-BR/cafeengine)
[![License](https://img.shields.io/badge/License-MIT-f1c40f?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Versão do Documento:** 1.0
**Data:** 2025-10-14
**Autor:** Café GameDev

---

## 1. Visão Geral e Filosofia

### 1.1. Conceito

O **StateMachine** é um framework avançado para Godot Engine 4.x, projetado para simplificar e potencializar a criação de lógicas de comportamento complexas. Ele implementa uma arquitetura de **Máquina de Estados Paralela e em Camadas (Layered/Parallel State Machine)**, onde comportamentos são encapsulados em `Resource`s reutilizáveis.

### 1.2. Filosofia Central

*   **Modularidade:** Comportamentos de movimento, combate e IA são domínios separados e autocontidos, que podem ser desenvolvidos e testados de forma independente.
*   **Reutilização:** Um `StateBehavior` (ex: `StateBehaviorAIPatrol`) pode ser criado uma vez e reutilizado em múltiplos tipos de inimigos com configurações diferentes.
*   **Design Visual e Reativo:** A lógica deve ser tão visual quanto possível, e o sistema deve ser reativo a eventos, integrando-se perfeitamente ao sistema de sinais e nós do Godot. A integração com o `BlueprintEditor` é fundamental para isso.
*   **`Resource` como Objeto Ativo:** Nossos `StateBehavior`s não são meros contêineres de dados. Eles são objetos inteligentes com sua própria lógica, estado interno e capacidade de emitir sinais para comunicar suas intenções. A arquitetura reflete a filosofia de que o próprio estado é inteligente, decidindo quando transicionar e não sendo constantemente verificado por um gerente externo.

### 1.3. Política de Versão e Compatibilidade

*   **Versão Alvo:** Godot 4.5+
*   **Compatibilidade:** Mantida com versões futuras da série 4.x.
*   **Retrocompatibilidade:** Nenhum suporte a versões anteriores a 4.5, garantindo código moderno e limpo.

---

## 2. Arquitetura Central

O sistema é composto por três elementos centrais que trabalham em conjunto para criar um sistema de comportamento em camadas.

### 2.1. `StateComponent` (O Gerenciador de Comportamentos)

*   **Tipo:** `Node`.
*   **Função:** É o motor de execução que vive em uma cena. Ele gerencia um conjunto de `StateBehavior`s ativos **simultaneamente**, organizados em "camadas" ou "domínios" funcionais.
*   **Propriedades Chave:**
    *   `@export var initial_behaviors: Array[Dictionary]`: Define os comportamentos iniciais e seus domínios no Inspector. A estrutura de cada entrada do dicionário é `{"domain": StringName, "behavior": StateBehavior}`.
    *   `var active_behaviors: Dictionary`: Armazena os `StateBehavior`s atualmente ativos, usando o nome do domínio como chave (ex: `{"movement": res://..., "action": res://...}`).
    *   `var _is_transitioning := false`: Um flag interno para garantir transições seguras e evitar loops.
*   **Sinais Emitidos:**
    *   `signal state_changed(domain: StringName, previous: Resource, next: Resource)`: Emitido após uma transição de estado bem-sucedida em um domínio.
    *   `signal state_entered(domain: StringName, state: Resource)`: Emitido quando um estado entra em um domínio.
    *   `signal state_exited(domain: StringName, state: Resource)`: Emitido quando um estado sai de um domínio.
*   **Lógica Principal:**
    1.  **Ciclo de Vida:** Em `_process` e `_physics_process`, itera sobre todos os `active_behaviors` e executa seus respectivos métodos, permitindo comportamentos paralelos (ex: andar e atirar).
    2.  **Gerenciador de Eventos:** Atua como um "broker". Ouve sinais de nós externos (configurados via Inspector) e os propaga para **todos** os `StateBehavior`s ativos através da função `handle_event()`.
    3.  **Executor de Transição:** Ouve o sinal `transition_requested(domain: StringName, next_behavior: Resource)` emitido pelos `StateBehavior`s e executa a troca de estado de forma segura, substituindo o behavior apenas no domínio especificado.
    4.  **`is_in_state(domain: StringName, state_class: StringName) -> bool`**: Função auxiliar para verificar se um domínio está em um estado específico.

### 2.2. `StateBehavior` (A Sub-Máquina / Domínio Funcional)

*   **Tipo:** `Resource`.
*   **Função:** Encapsula a lógica completa de um domínio funcional (Movimento, Combate, IA). É, na prática, uma máquina de estados autocontida que gerencia seus próprios **micro-estados** internamente (usando `Enums`, `Dictionaries`, etc.). Além disso, `StateBehavior`s podem exportar dicionários complexos para configurar detalhes específicos do estado (ex: `{"animation": "punch", "damage": 10}` para ataques, ou `{"speed": 150, "acceleration": 0.8}` para movimento). Futuramente, esses dicionários poderão ser substituídos por `Resource`s dedicados do plugin `DataBehavior` para uma gestão de dados ainda mais robusta.
*   **Comunicação (Saída):**
    *   `signal transition_requested(domain: StringName, next_behavior: Resource)`: Sinal para solicitar a troca do behavior ativo dentro de um domínio específico.
    *   Pode emitir outros sinais específicos de ação (ex: `sound_requested`, `effect_spawned`).
*   **Comunicação (Entrada):**
    *   `func enter(owner: Node)`: Chamado uma vez quando o estado se torna ativo.
    *   `func exit(owner: Node)`: Chamado uma vez quando o estado deixa de ser ativo.
    *   `func process(owner: Node, delta: float)`: Chamado a cada frame do jogo.
    *   `func physics_process(owner: Node, delta: float)`: Chamado a cada frame de física.
    *   `func handle_event(owner: Node, event_name: StringName, payload: Variant)`: Método virtual que permite ao estado reagir a eventos externos.

### 2.3. `StateMachine` (O Autoload Singleton)

*   **Tipo:** `Node` (Singleton).
*   **Função:** Orquestrador de alto nível com um duplo papel.
*   **Papel 1 (Observador de Entidades):** Mantém um registro de todos os `StateComponent`s ativos na cena para depuração através do `StateSidePanel`.
*   **Papel 2 (Executor de Estados Globais):** Funciona como sua própria máquina de estados para gerenciar o fluxo geral do jogo (menus, níveis, pausa), utilizando `StateBehavior`s de alto nível como `GameStateScene`.
    *   **`GameStateScene`**: Um `StateBehavior` especializado para gerenciar transições entre cenas completas do jogo. Possui uma propriedade `@export var scene: PackedScene` e sua lógica `enter` lida com `change_scene_to_packed`.

---

## 3. Estrutura de Arquivos Padrão

```
addons/state_machine/
├── plugin.cfg
├── components/
│   ├── state_component.gd
│   └── state_component.tscn
├── resources/
│   ├── state_config.tres
│   └── behaviors/ # Subpasta para todos os StateBehaviors (recursos)
│       ├── state_behavior.gd
│       └── [outros_state_behaviors].gd
├── panel/
│   ├── state_bottom_panel.gd
│   ├── state_bottom_panel.tscn
│   └── state_side_panel.gd
│   └── state_side_panel.tscn
├── scripts/
│   ├── editor_plugin.gd
│   └── state_machine.gd
└── icons/
    └── [icones].svg
```

---

## 4. Plano de Desenvolvimento em Fases

### Fase 1: Fundação (MVP)

*   [x] **`StateBehavior`:** Implementar a classe base com suas funções virtuais e o sinal `transition_requested`.
*   [x] **`StateComponent`:** Implementar o componente com a arquitetura de domínios, transições seguras (`_is_transitioning`), e sinais (`state_changed`, `state_entered`, `state_exited`).
*   [x] **Estados Essenciais:** Desenvolver `StateBehaviorIdle` e `StateBehaviorMove`.
*   [x] **`GameStateScene`:** Implementar o `StateBehavior` para gerenciamento de cenas globais.
*   [x] **Ajustar Estrutura de Pastas:** Mover `StateBehavior`s para `resources/behaviors/`.
*   **Objetivo:** Ter um sistema funcional de estados paralelos, com transições seguras e a base para estados de jogo globais.

### Fase 2: Integração como Plugin Godot e Melhorias no Inspector

*   [x] **`plugin.cfg`:** Definir o plugin para o Godot.
*   [x] **`editor_plugin.gd`:** Registrar `StateBehavior` e `StateComponent` como tipos customizados com ícones próprios e configurar Autoload para `StateMachine`.
*   [x] **Inspector Aprimorado (Nível 1):** Utilizar `_get_property_list()` nos `StateBehavior`s para organizar propriedades em categorias (`logic/`, `transitions/`).
*   **Objetivo:** Transformar o sistema em um plugin fácil de instalar e usar, com melhor clareza no Inspector.

### Fase 3: Expansão da Biblioteca de Estados e Controles Customizados

*   [ ] **`StateBehaviorAttack`:** Desenvolver um estado de ataque que use `AnimationPlayer` e sinais.
*   [ ] **`StateBehaviorJump`:** Desenvolver um estado de pulo que lide com gravidade e detecção de chão.
*   [ ] **Outros `StateBehavior`s:** Implementar mais estados do catálogo (`behaviors_plan01.md`) para cobrir domínios comuns.
*   [ ] **Controles Customizados no Inspector (Nível 2):** Implementar `EditorInspectorPlugin` para adicionar botões de atalho, validações visuais e previews no Inspector para `StateBehavior`s.
*   **Objetivo:** Oferecer uma biblioteca robusta de estados e uma experiência de edição mais interativa.

### Fase 4: Painel de UI e Ferramentas de Depuração

*   [x] **`StateBottomPanel`:** Desenvolver o painel inferior para gerenciamento de `StateBehavior`s e scripts.
*   [x] **`StateSidePanel`:** Desenvolver o painel lateral para acesso à documentação e configurações.
*   [ ] **Integração com `BlueprintEditor`:** Desenvolver a funcionalidade para que o `BlueprintEditor` possa visualizar e manipular `StateComponent`s e `StateBehavior`s graficamente.
*   [ ] **Depuração Visual:** Mostrar o estado ativo em tempo real durante a execução do jogo no `BlueprintEditor`.
*   **Objetivo:** Fornecer feedback visual e ferramentas que acelerem o desenvolvimento e a depuração de máquinas de estado.

### Fase 5: Documentação e Exemplos

*   [ ] **Documentar o Código:** Adicionar comentários claros em todas as classes e funções principais.
*   [ ] **Documentação Externa:** Escrever guias no formato Markdown na pasta `docs/` do plugin.
*   [ ] **Projeto Demo Completo:** Montar um pequeno jogo ou cena de exemplo que utilize diversos estados e funcionalidades do StateMachine.
*   **Objetivo:** Garantir que o plugin seja acessível e fácil de aprender para novos usuários.

---

## 5. Padrões de Qualidade de Código

*   Todos os scripts de Resource e Editor devem usar `@tool`.
*   Classes documentadas com docstring.
*   Sinais seguem convenção: `changed`, `updated`, `requested`, `completed`.
*   Nenhum Resource deve depender diretamente de Nodes (exceto para referências de `owner` em `StateBehavior`s, por exemplo).

---

## 6. Considerações Futuras

*   **Máquinas de Estado Hierárquicas (Sub-states):** Permitir que um estado contenha sua própria máquina de estados interna.
*   **Recurso de Transição:** Criar um `StateTransition.tres` para encapsular a lógica de quando uma transição deve ocorrer.
*   **FSM Serializer:** Exportar/importar uma FSM inteira (como `.tres`).
*   **Behavior Templates:** Menu no editor para criar automaticamente um novo script herdando de `StateBehavior`.
*   **Live Hot-Reload:** Recarregar estados modificados sem reiniciar o jogo.

---

## Instalação

1.  **AssetLib (Recomendado):**
    *   Procure por "StateMachine" na Godot Asset Library e instale o plugin.
2.  **Manual (GitHub):**
    *   Baixe o repositório.
    *   Copie a pasta `addons/state_machine` para a pasta `addons/` do seu projeto.

Após a instalação, vá em `Project -> Project Settings -> Plugins` e ative o plugin **StateMachine**.

## Contribuição

Este projeto é open-source e contribuições são bem-venidas! Por favor, leia nosso [guia de contribuição](../../CONTRIBUTING.md) para saber como reportar bugs, sugerir funcionalidades e submeter pull requests.

## Licença

Este projeto é distribuído sob a Licença MIT. Veja o arquivo [LICENSE](../../LICENSE) para mais detalhes.