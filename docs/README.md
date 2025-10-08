# StateCafe ☕

[![Godot Asset Library](https://img.shields.io/badge/Godot_Asset_Library-StateCafe-478cbf?style=for-the-badge&logo=godot-engine)](https://godotengine.org/asset-library/asset/link-to-asset) <!-- Placeholder -->
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**StateCafe** é um framework de Máquina de Estados Paralela e em Camadas para Godot 4.x, projetado para ser modular, reutilizável e intuitivo.

Cansado de máquinas de estado monolíticas e difíceis de gerenciar? O StateCafe introduz uma arquitetura onde comportamentos são `Resources` independentes, permitindo que você construa lógicas complexas de forma visual e organizada.

---

## Principais Funcionalidades

-   **Máquinas de Estado Paralelas:** Execute múltiplos comportamentos (como `Movimento` e `Ataque`) simultaneamente e em sincronia, sem criar estados complexos para cada combinação.
-   **Comportamentos baseados em `Resource`:** Crie, configure e reutilize lógicas de estado (como `Patrulha`, `Pulo`, `Diálogo`) diretamente do FileSystem e do Inspector.
-   **Arquitetura Reativa:** Use o poder dos sinais do Godot para transições de estado e para que os estados comuniquem suas necessidades (tocar um som, instanciar um efeito) de forma desacoplada.
-   **Gerenciamento Global e Local:** Controle tanto o fluxo de cenas do seu jogo (nível macro) quanto a IA de um inimigo específico (nível micro) usando o mesmo sistema unificado.
-   Editor Visual (Planejado): Uma futura interface de grafos permitirá criar, conectar e depurar suas máquinas de estado de forma totalmente visual.

---

## Documentação

A documentação completa, com guias detalhados, tutoriais e a referência da API, pode ser encontrada no nosso site oficial:

[https://www.cafegame.dev/cafeengine/statecafe](https://www.cafegame.dev/cafeengine/statecafe)

---

## Compatibilidade

Este plugin foi projetado especificamente para **Godot 4.5** e versões futuras. O projeto será mantido para acompanhar as novas atualizações da engine, mas não há planos de oferecer retrocompatibilidade com versões anteriores.

---

## Instalação

1.  **AssetLib (Recomendado):**
    -   Procure por "StateCafe" na Godot Asset Library e instale o plugin.
2.  **Manual (GitHub):**
    -   Baixe o repositório.
    -   Copie a pasta `addons/statecafe` para a pasta `addons/` do seu projeto.

Após a instalação, vá em `Project -> Project Settings -> Plugins` e ative o plugin **StateCafe**.

---

## Como Usar (Guia Rápido)

1.  **Adicione o Componente:** Na cena do seu personagem ou objeto, adicione o nó `StateComponent`.
2.  **Crie um Behavior:** No FileSystem, clique com o botão direito -> `Create Resource` e escolha um tipo de `StateBehavior` (ex: `StateBehaviorGroundMove`). Salve como `MyMoveBehavior.tres`.
3.  **Configure o Behavior:** No Inspector do `StateComponent`, adicione um elemento ao array `Initial Behaviors`. Defina o `domain` como `"movement"` e arraste seu `MyMoveBehavior.tres` para o campo `behavior`.
4.  **Implemente a Lógica:** Abra o `MyMoveBehavior.tres` (ou seu script anexo) e adicione sua lógica de movimento e transição nos métodos `physics_process` e `process`.
5.  **Execute!** O `StateComponent` irá automaticamente rodar seu behavior.

---

## Contribuição

O StateCafe é um projeto open-source. Contribuições são bem-vindas! Por favor, leia nosso [guia de contribuição](CONTRIBUTING.md) para saber como reportar bugs, sugerir funcionalidades e submeter pull requests.

## Licença

Este projeto é distribuído sob a Licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
