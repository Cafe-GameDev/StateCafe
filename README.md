# StateMachine ☕

[![DataBehavior](https://img.shields.io/badge/StateMachine-v1.0.0-478cbf?style=for-the-badge)](https://www.cafegame.dev/pt-BR/cafeengine)
[![License](https://img.shields.io/badge/License-MIT-f1c40f?style=for-the-badge)](https://opensource.org/licenses/MIT)

**StateMachine** é um framework de Máquina de Estados Paralela e em Camadas para Godot 4.x, projetado para ser modular, reutilizável e intuitivo.

Cansado de máquinas de estado monolíticas e difíceis de gerenciar? O StateMachine introduz uma arquitetura onde comportamentos são `Resources` independentes, permitindo que você construa lógicas complexas de forma visual e organizada.

---

## Principais Funcionalidades

-   **Máquinas de Estado Paralelas:** Execute múltiplos comportamentos (como `Movimento` e `Ataque`) simultaneamente e em sincronia, sem criar estados complexos para cada combinação.
-   **Comportamentos baseados em `Resource`:** Crie, configure e reutilize lógicas de estado (como `Patrulha`, `Pulo`, `Diálogo`) diretamente do FileSystem e do Inspector.
-   **Arquitetura Reativa:** Use o poder dos sinais do Godot para transições de estado e para que os estados comuniquem suas necessidades (tocar um som, instanciar um efeito) de forma desacoplada.
-   **Gerenciamento Global e Local:** Controle tanto o fluxo de cenas do seu jogo (nível macro) quanto a IA de um inimigo específico (nível micro) usando o mesmo sistema unificado.
-   **Editor Visual Integrado:** Através do **BlueprintEditor**, você pode visualizar, criar e depurar suas máquinas de estado de forma totalmente visual, manipulando `StateComponent`s, `Machines` e `Behaviors` em um ambiente de grafo.

---

## Documentação

A documentação completa, com guias detalhados, tutoriais e a referência da API, pode ser encontrada no nosso site oficial:

[https://www.cafegame.dev/cafeengine/statemachine](https://www.cafegame.dev/cafeengine/statemachine)

---

## Compatibilidade

Este plugin foi projetado especificamente para **Godot 4.5** e versões futuras. O projeto será mantido para acompanhar as novas atualizações da engine, mas não há planos de oferecer retrocompatibilidade com versões anteriores.

---

## Instalação

1.  **AssetLib (Recomendado):**
    *   Procure por "StateMachine" na Godot Asset Library e instale o plugin.
2.  **Manual (GitHub):**
    *   Baixe o repositório.
    *   Copie a pasta `addons/state_machine` para a pasta `addons/` do seu projeto.

Após a instalação, vá em `Project -> Project Settings -> Plugins` e ative o plugin **StateMachine**.

---

## Como Usar (Guia Rápido)

1.  **Adicione o Componente:** Na cena do seu personagem ou objeto, adicione o nó `StateComponent`.
2.  **Crie um Behavior:** No FileSystem, clique com o botão direito -> `Create Resource` e escolha um tipo de `StateBehavior` (ex: `StateBehaviorMove`). Salve como `MyMoveBehavior.tres`.
3.  **Configure os Domínios:** No Inspector do `StateComponent`, adicione um ou mais elementos ao array `Initial Behaviors`. Para cada um, defina um `domain` (ex: `"movement"` ou `"action"`) e arraste seu `StateBehavior` correspondente para o campo `behavior`.
4.  **Implemente a Lógica:** Abra o `MyMoveBehavior.tres` (ou seu script anexo) e adicione sua lógica de movimento e transições internas.
5.  **Execute!** O `StateComponent` irá automaticamente rodar todos os seus behaviors ativos em paralelo.

---

## Contribuição

O StateMachine é um projeto open-source. Contribuições são bem-vindas! Por favor, leia nosso [guia de contribuição](CONTRIBUTING.md) para saber como reportar bugs, sugerir funcionalidades e submeter pull requests.

## Licença

Este projeto é distribuído sob a Licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
