defmodule EcoHabitsWeb.CheckinLive.Form do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Checkins
  alias EcoHabits.Checkins.Checkin
  alias EcoHabits.Habits
  alias EcoHabits.Habits.Habit

    # --- DADOS MOCKADOS (Módulo B temporário) ---
#  @categories ["Alimentação", "Transporte", "Energia", "Água", "Resíduos"]
#  @mock_habits %{
#    "Alimentação" => [{"Segunda sem carne", 1}, {"Compostagem doméstica", 2}],
#    "Transporte" => [{"Usar bicicleta", 3}, {"Caronas coletivas", 4}],
#    "Energia" => [{"Apagar luzes desnecessárias", 5}, {"Banho curto", 6}],
#    "Água" => [{"Reuso de água da chuva", 7}],
#    "Resíduos" => [{"Reciclagem de plástico", 8}, {"Descarte de pilhas", 9}]
#  }

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage checkin records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="checkin-form" phx-change="validate" phx-submit="save">
        <.input name="category" value={@selected_category} type="select" label="1. Escolha a Categoria" options={@categories} prompt="Selecione uma categoria"/>

        <.input field={@form[:habit_id]} type="select" label="2. Selecione o Hábito" options={@available_habits} prompt="Selecione o hábito praticado" disabled={@selected_category == nil or @available_habits == []}/>



        <footer>
          <.button phx-disable-with="Salvando..." variant="primary">Salvar Checkin</.button>
          <.button navigate={return_path(@current_scope, @return_to, @checkin)}>Cancelar</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

#  @impl true
#  def mount(params, _session, socket) do
#    {:ok,
#     socket
#     |> assign(:return_to, return_to(params["return_to"]))
#     |> apply_action(socket.assigns.live_action, params)}
#  end

  # def mockada
#  @impl true
#  def mount(params, _session, socket) do
#    {:ok,
#     socket
#     |> assign(:categories, @categories)
#     |> assign(:selected_category, nil)
#     |> assign(:available_habits, [])
#     |> assign(:return_to, return_to(params["return_to"]))
#     |> apply_action(socket.assigns.live_action, params)}
#  end

  @impl true
  def mount(params, _session, socket) do
    # Categorias devem bater com a validação do Módulo B
    categories = ["alimentação", "transporte", "energia", "água", "resíduos"]

    {:ok,
     socket
     |> assign(:categories, categories)
     |> assign(:selected_category, nil)
     |> assign(:available_habits, [])
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

#  defp apply_action(socket, :edit, %{"id" => id}) do
#    checkin = Checkins.get_checkin!(socket.assigns.current_scope, id)
#
#    socket
#    |> assign(:page_title, "Edit Checkin")
#    |> assign(:checkin, checkin)
#    |> assign(:form, to_form(Checkins.change_checkin(socket.assigns.current_scope, checkin)))
#  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # Precarregamos o hábito para saber qual era a categoria original na edição
    checkin = Checkins.get_checkin!(socket.assigns.current_scope, id)
              |> EcoHabits.Repo.preload(:habit)

    habits = Habits.list_habits(checkin.habit.category)
    habit_options = Enum.map(habits, &{&1.name, &1.id})

    socket
    |> assign(:page_title, "Editar Checkin")
    |> assign(:checkin, checkin)
    |> assign(:selected_category, checkin.habit.category)
    |> assign(:available_habits, habit_options)
    |> assign(:form, to_form(Checkins.change_checkin(socket.assigns.current_scope, checkin)))
  end

  defp apply_action(socket, :new, _params) do
    checkin = %Checkin{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Checkin")
    |> assign(:checkin, checkin)
    |> assign(:form, to_form(Checkins.change_checkin(socket.assigns.current_scope, checkin)))
  end

  @impl true
  # def mockada
#  def handle_event("validate", %{"category" => category, "checkin" => checkin_params}, socket) do
#    # Quando a categoria muda, atualizamos a lista de hábitos disponíveis
#    habits = Map.get(@mock_habits, category, [])
#
#    changeset = Checkins.change_checkin(socket.assigns.current_scope, socket.assigns.checkin, checkin_params)
#
#    {:noreply,
#      socket
#      |> assign(selected_category: category)
#      |> assign(available_habits: habits)
#      |> assign(form: to_form(changeset, action: :validate))}
#  end
  def handle_event("validate", %{"category" => category} = params,  socket) do
    # Se "checkin" não vier nos parâmetros, usamos um mapa vazio
    checkin_params = Map.get(params, "checkin", %{})

    # Busca os hábitos reais da categoria
    habits = Habits.list_habits(category)
    habit_options = Enum.map(habits, &{&1.name, &1.id})

    changeset =
      Checkins.change_checkin(socket.assigns.current_scope, socket. assigns.checkin, checkin_params)

    {:noreply,
      socket
      |> assign(selected_category: category)
      |> assign(available_habits: habit_options)
      |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("validate", %{"checkin" => checkin_params}, socket) do
    changeset = Checkins.change_checkin(socket.assigns.current_scope, socket.assigns.checkin, checkin_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"checkin" => checkin_params}, socket) do
    save_checkin(socket, socket.assigns.live_action, checkin_params)
  end

  defp save_checkin(socket, :edit, checkin_params) do
    case Checkins.update_checkin(socket.assigns.current_scope, socket.assigns.checkin, checkin_params) do
      {:ok, checkin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Checkin updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, checkin)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  #defp save_checkin(socket, :new, checkin_params) do
  #  case Checkins.create_checkin(socket.assigns.current_scope, checkin_params) do
  #    {:ok, checkin} ->
  #      {:noreply,
  #       socket
  #       |> put_flash(:info, "Checkin created successfully")
  #       |> push_navigate(
  #         to: return_path(socket.assigns.current_scope, socket.assigns.return_to, checkin)
  #       )}

#      {:error, %Ecto.Changeset{} = changeset} ->
#        {:noreply, assign(socket, form: to_form(changeset))}
#    end
#  end

# função alterada para aceitar o erro
  defp save_checkin(socket, :new, checkin_params) do
    case Checkins.create_checkin(socket.assigns.current_scope,  checkin_params) do
      {:ok, checkin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Checkin criado com sucesso")
         |> push_navigate(to: return_path(socket.assigns. current_scope, socket.assigns.return_to, checkin))}

      {:error, %Ecto.Changeset{} = changeset} ->
        # Esta linha é crucial: ela pega o erro do banco e joga de  volta para o formulário
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _checkin), do: ~p"/checkins"
  defp return_path(_scope, "show", checkin), do: ~p"/checkins/#{checkin}"
end
