# 🍃 EcoHabits

O **EcoHabits** é uma aplicação web colaborativa focada em sustentabilidade. O sistema permite que os usuários registrem, gerenciem e acompanhem hábitos sustentáveis do cotidiano , como economia de água, uso de transporte ativo e redução de resíduos, acumulando pontos e interagindo com o engajamento da comunidade em tempo real.

---

## 🛠️ Tecnologias e Requisitos Técnicos Atendidos

Este projeto foi desenvolvido utilizando o ecossistema Elixir/Phoenix, cumprindo rigorosamente os requisitos técnicos (RT) da disciplina:

- **[RT01]** Construído com **Phoenix Framework** e **LiveView** para interatividade no lado do servidor.
- **[RT02]** Banco de dados relacional **MySQL** operado através do **Ecto**.
- **[RT03]** Sistema de autenticação completo gerado nativamente via `mix phx.gen.auth`.
- **[RT04]** Interface de usuário e layouts construídos com **HEEx**, **Tailwind CSS** e componentes DaisyUI.
- **[RT05]** Atualizações em tempo real (Real-time) na interface utilizando **Phoenix.PubSub**.
- **[RT06]** Validações robustas de dados na camada de banco utilizando **Ecto Changesets** (validação de campos obrigatórios, escopo de categorias, pontuação mínima e unicidade).
- **[RT07]** Navegação fluida entre telas (LiveViews) e redirecionamentos seguros utilizando o **Phoenix Router**.

---

## 🎯 Módulos e Requisitos Funcionais

A aplicação é dividida em três módulos principais de negócio:

### Módulo A - Autenticação e Perfil
- **[RF01]** Cadastro de usuários com nome, e-mail e senha (via `phx.gen.auth`).
- **[RF02]** Controle de sessão (Login/Logout) com persistência de acesso.
- **[RF03]** Área de perfil dedicada, exibindo nome, biografia (editável pelo próprio usuário) e pontuação total acumulada.

### Módulo B - Gestão de Hábitos
- **[RF04]** Cadastro de hábitos sustentáveis contendo nome, descrição, categoria estruturada (alimentação, transporte, energia, água, resíduos) e pontuação associada.
- **[RF05]** Listagem dinâmica da comunidade de hábitos com aplicação de filtros por categoria em tempo real.
- **[RF06]** Controle de autorização de recursos (IDOR protection): edição e remoção de hábitos permitidas exclusivamente para o autor do registro.

### Módulo C - Registro e Acompanhamento
- **[RF07]** Sistema de Check-in diário de hábitos, com travas de duplicidade para o mesmo usuário na mesma data.
- **[RF08]** Dashboard pessoal interativo exibindo o histórico de check-ins e a totalização da pontuação semanal.
- **[RF09]** Feed da comunidade atualizado em tempo real via PubSub, refletindo os check-ins mais recentes de todos os membros da plataforma.

---

## 🚀 Como executar o projeto localmente

Para rodar o servidor do EcoHabits na sua máquina, certifique-se de ter o Elixir e o MySQL instalados e configurados.

1. Clone o repositório e acesse a pasta do projeto:
   ```bash
   git clone <url-do-repositorio>
   cd eco_habits```

2. Instale as dependências e configure o banco de dados (certifique-se de que as credenciais no config/dev.exs estejam corretas para o seu MySQL local):
```mix setup```

3. Inicie o servidor Phoenix (rode junto ao terminal interativo para depuração):
```iex -S mix phx.server```

4. Acesse a aplicação no seu navegador:
```http://localhost:4000```