# Catálogo de StateBehaviors de Alto Nível

Este documento define uma lista de 30 `StateBehavior`s de alto nível propostos para a biblioteca do **StateCafe**. Cada item representa uma **sub-máquina de estados** completa para um domínio funcional, gerenciando seus próprios micro-estados internamente.

---

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
| 23 | `GameStateScene` | **Já definido:** Carrega e transiciona para uma cena inteira. | `LOADING`, `ACTIVE` | `PackedScene` |
| 24 | `GameStateMenu` | Gerencia a navegação em um menu complexo. | `MAIN_SCREEN`, `OPTIONS`, `CREDITS` | `Dictionary` |
| 25 | `GameStateLoading` | Controla uma tela de carregamento assíncrono. | `LOADING_ASSETS`, `WAITING_INPUT`, `FADING_OUT` | `Enum` |
| 26 | `GameStateCutscene` | Gerencia a reprodução de uma cutscene. | `PLAYING`, `PAUSED`, `SKIPPING` | `Enum` |
| 27 | `GameStatePaused` | Controla o estado de pausa global do jogo. | `PAUSED`, `RESUMING` | `Enum` |
| **UI (INTERFACE DE USUÁRIO)** | | | | |
| 28 | `StateBehaviorUIPanel` | Gerencia os estados de um painel de UI complexo. | `OPENING`, `IDLE`, `CLOSING`, `CLOSED` | `Enum` |
| 29 | `StateBehaviorTutorial` | Controla uma sequência de eventos de um tutorial. | `SHOWING_TEXT`, `WAITING_ACTION`, `COMPLETED` | `Array` de `Dictionary` |
| 30 | `StateBehaviorItemDrag` | Gerencia o estado de arrastar um item em um inventário. | `DRAGGING`, `CAN_DROP`, `INVALID_DROP` | `Enum` |
