# 🎮 LAJE Launcher

Launcher em estilo videogame feito em **Godot** para expor os jogos da nossa liga de jogos eletrônicos em eventos. O jogador navega pelos ícones dos jogos, seleciona um e o launcher abre o `.exe` correspondente em primeiro plano. Quando o jogo é fechado, o launcher volta automaticamente para a tela de seleção.

## ✨ Funcionalidades

- Interface em tela cheia com um botão (ícone + nome) para cada jogo
- Navegação por teclado ou controle (sistema de foco da UI do Godot)
- Lista de jogos configurável por arquivo `games.json`, sem precisar reexportar o launcher
- Abre o executável do jogo e minimiza o launcher enquanto o jogo roda
- Detecta quando o jogo fecha e restaura o launcher em tela cheia
- Mensagens de erro na tela (JSON inválido, ícone ou `.exe` não encontrado)

## 📋 Requisitos

- [Godot](https://godotengine.org/) 4.x (a propriedade `vertical_icon_alignment` exige 4.2 ou superior)
- Windows (os jogos são executáveis `.exe` e o launcher usa `cmd.exe` para iniciá-los)

## 📁 Estrutura de pastas

Os jogos e o `games.json` ficam **fora** do projeto Godot, ao lado do executável exportado. Arquivos dentro de `res://` são empacotados no `.pck` e não podem ser executados.

```
laje_launcher/
├── projeto-laje-launcher (Projeto Godot)
├── lajelauncher.exe          # exportado do Godot
├── lajelauncher.pck
├── lajelauncher.x86_64
├── games.json            # lista de jogos
└── games/
    ├── jogo1/
    │   ├── jogo1.exe
    │   └── jogo1_icon.jpg (formato de imagem atual)
    └── jogo2/
        ├── jogo2.exe
        └── jogo2_icon.jpg
```

## ⚙️ Configurando os jogos

Edite o `games.json` e adicione um objeto para cada jogo. Os caminhos são relativos à pasta do `lajelauncher.exe`.

```json
[
  {
    "name": "Jogo 1",
    "exe": "games/jogo1/jogo1.exe",
    "icon": "games/jogo1/jogo1_icon.png"
  },
  {
    "name": "Jogo 2",
    "exe": "games/jogo2/jogo2.exe",
    "icon": "games/jogo2/jogo2_icon.png"
  }
]
```

| Campo  | Descrição                                                        |
| ------ | ---------------------------------------------------------------- |
| `name` | Nome exibido no botão                                            |
| `exe`  | Caminho do executável do jogo                                    |
| `icon` | Caminho da imagem do ícone (recomendado: quadrada, 256×256 ou 512×512) |

## 🧱 Estrutura da cena

```
Control               (script principal anexado, Anchors: Full Rect)
├── ColorRect         (fundo, Anchors: Full Rect)
└── CenterContainer   (Anchors: Full Rect)
    └── GridContainer (Columns = 3, h_separation/v_separation = 40)
```

Os botões são criados por código a partir do `games.json` e adicionados ao `GridContainer`.

## 🚀 Como rodar

### No editor (para testar)

1. Abra o projeto no Godot.
2. Coloque um `games.json` na **raiz do projeto**, ao lado do `project.godot`, com caminhos relativos a essa pasta.
3. Pressione **F5**.

No editor, o script usa a raiz do projeto como pasta base. No executável exportado, ele usa a pasta do `.exe`.

### Exportado

1. Vá em **Project → Export → Windows Desktop** e exporte o launcher.
2. Copie o `games.json` e a pasta `games/` para a **mesma pasta** do executável exportado.
3. Execute o `Launcher.exe`.

Para depurar erros no exportado, marque **Export With Debug** e use o executável `.console.exe`, que abre um terminal com os logs.

## 🛠️ Como funciona

- O launcher inicia o jogo com `OS.create_process()`, passando por `cmd.exe /c "cd /d <pasta do jogo> && <jogo>.exe"`. Isso define o diretório de trabalho correto, necessário para jogos que carregam arquivos por caminho relativo.
- Ao iniciar o jogo, a janela do launcher é minimizada.
- A cada frame, `OS.is_process_running(pid)` verifica se o jogo ainda está aberto. Quando ele fecha, o launcher volta para tela cheia.

## 🏫 Dicas do Claude para eventos

- Teste tudo no **computador do evento**, com os mesmos controles e o mesmo monitor ou projetor.
- Verifique se os jogos precisam de runtimes instalados (por exemplo, Visual C++ Redistributable) e teste em um PC limpo.
- O Windows Defender/SmartScreen pode alertar sobre `.exe` desconhecidos. Faça o primeiro teste com antecedência.
- Deixe o launcher em tela cheia: **Project Settings → Display → Window → Mode = Fullscreen**.
- Considere implementar um atalho para sair do launcher e outro para encerrar um jogo travado com `OS.kill(pid)`.
- Informe na tela como sair de jogos que não têm botão de sair (por exemplo, `Alt+F4`).

## 🩺 Solução de problemas

| Problema | O que verificar |
| -------- | --------------- |
| Tela vazia | O `Control` raiz e o `CenterContainer` estão com Anchors em **Full Rect**? Um `GridContainer` sem tamanho deixa os botões invisíveis. |
| "Não achei o games.json" | O arquivo está na pasta do `.exe` exportado (ou na raiz do projeto, se estiver rodando pelo editor)? |
| "games.json inválido" | Confira vírgulas e aspas no JSON. |
| Ícone não aparece | Confira o caminho no `games.json` e se a imagem é PNG/JPG válida. |
| Jogo abre atrás do launcher | Use janela sem bordas em vez de fullscreen exclusivo, ou garanta que o launcher está minimizado ao lançar. |
| Jogo abre mas quebra | Provável dependência de caminhos relativos ou runtime ausente. Teste o `.exe` direto na pasta dele. |

## 🤝 Contribuindo

Para adicionar um jogo, basta incluir a pasta do jogo e o ícone em `games/` e uma nova entrada no `games.json`. Não é necessário alterar o código nem reexportar o launcher.