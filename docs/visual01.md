# StateCafe - Visualização e Edição de States

Este documento explora as estratégias para tornar a criação e edição dos `StateBehavior` resources uma experiência visual e intuitiva, indo além da simples lista de propriedades no Inspector.

## O Problema

Por padrão, um `Resource` em Godot mostra apenas suas propriedades exportadas (`@export`). Para uma máquina de estados, isso não é o ideal. As conexões (transições) entre os estados não são claras, e a lógica fica escondida dentro do código. Nosso objetivo é trazer essa estrutura para a superfície.

## Proposta de Abordagem em Níveis

Propomos três níveis de aprimoramento visual, que podem ser implementados em fases.

---

### Nível 1: Inspector Aprimorado com Categorias

**Conceito:** Organizar as propriedades dos nossos `StateBehavior`s no Inspector usando categorias e grupos, tornando a leitura e edição mais lógicas.

**Como:** Utilizando a função `_get_property_list()` nos scripts dos `StateBehavior`s para agrupar propriedades relacionadas.

**Exemplo Prático (`StateBehaviorAttack.gd`):**

*   **Antes (Inspector Padrão):**
    ```
    - Script
    - Damage: 10
    - Attack Animation: "slash"
    - Cooldown: 0.5
    - Idle State: [StateBehavior]
    - Move State: [StateBehavior]
    ```

*   **Depois (Inspector Organizado):**
    ```
    - Script
    ▼ Lógica do Ataque
        - Damage: 10
        - Attack Animation: "slash"
        - Cooldown: 0.5
    ▼ Transições
        - Idle State: [StateBehavior]
        - Move State: [StateBehavior]
    ```

Isso já melhora drasticamente a clareza sem a necessidade de ferramentas complexas.

---

### Nível 2: Controles Customizados no Inspector (`EditorInspectorPlugin`)

**Conceito:** Adicionar botões, sliders customizados e outros widgets diretamente no Inspector para um `StateBehavior` específico. Isso permite "ações rápidas" e feedback visual.

**Como:** Criando um `EditorInspectorPlugin`. Este tipo de plugin pode adicionar controles customizados para tipos de objetos específicos (como nossos `StateBehavior`s).

**Exemplos Práticos:**

1.  **Botão de Atalho:** Para um `StateBehaviorAttack`, poderíamos adicionar um botão "Criar Novo Estado de Cooldown" ao lado da propriedade de transição. Clicar nele criaria um novo `StateBehaviorIdle.tres` e o atribuiria automaticamente.

2.  **Preview Visual:** Para um `StateBehaviorMovie`, poderíamos adicionar um pequeno player de animação ou um thumbnail diretamente no Inspector para dar um preview da cutscene que ele controla.

3.  **Validação Visual:** Mudar a cor de uma propriedade se ela não for preenchida corretamente (ex: deixar o campo `Idle State` vermelho se estiver vazio).

![Exemplo de Inspector Customizado](https://i.imgur.com/O1hI2jU.png) *<-- Imagem conceitual de como o Inspector poderia se parecer.*

---

### Nível 3: Editor de Grafos Visual (`GraphEdit`)

**Conceito:** A solução definitiva. Um editor de grafos completo, similar ao `AnimationTree` ou ao Editor de Shaders Visuais do Godot, onde o usuário pode criar e conectar estados de forma totalmente visual.

**Como:** Esta é a abordagem mais complexa, implementada como parte do `EditorPlugin` principal.

1.  **Criar um Novo Painel:** Adicionar um novo painel/aba "State Editor" no Godot.
2.  **Usar `GraphEdit`:** Este nó é a base para criar editores de grafos.
3.  **Nós do Grafo (`GraphNode`):** Cada `GraphNode` no editor representaria um `StateBehavior` resource.
    -   Clicar em um nó selecionaria o `Resource` correspondente no FileSystem e mostraria suas propriedades no Inspector.
    -   O nó poderia exibir informações chave (como nome e tipo).
4.  **Conexões:** As linhas conectando os nós representariam as transições.
    -   A lógica da transição (ex: `Input.is_action_pressed("jump")`) poderia ser definida em um `Resource` de `StateTransition` e configurada na própria conexão.

**Fluxo de Trabalho do Usuário com o Grafo:**
1.  Abre o editor de grafos para um `StateComponent`.
2.  Arrasta `StateBehavior` resources do FileSystem para o grafo, ou clica com o botão direito para criar novos.
3.  Conecta os nós visualmente para definir as transições.
4.  Salva o grafo, que atualiza as referências dentro dos `Resource`s.

![Exemplo de Grafo](https://i.imgur.com/e2Xb02y.png) *<-- Imagem conceitual de um editor de grafos para o StateCafe.*

---

## Conclusão e Recomendação

-   **Fase Inicial:** Devemos focar nos **Níveis 1 e 2**. Eles oferecem um grande ganho de usabilidade com um esforço de desenvolvimento moderado e se encaixam perfeitamente nas Fases 2 e 4 do nosso plano de desenvolvimento principal.
-   **Longo Prazo:** O **Nível 3 (Editor de Grafos)** é o objetivo final que tornaria o StateCafe uma ferramenta de nível profissional. Deve ser planejado como uma feature principal para uma futura versão 2.0, após a base do plugin estar sólida e testada.
