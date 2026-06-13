defmodule EcoHabitsWeb.HabitLive.Form do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits
  alias EcoHabits.Habits.Habit

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage habit records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="habit-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input 
          field={@form[:category]} 
          type="select" 
          label="Categoria Sustentável" 
          options={["Alimentação": "alimentação", "Transporte": "transporte", "Energia": "energia", "Água": "água", "Resíduos": "resíduos"]} 
          prompt="Escolha uma categoria"
        />
        <.input field={@form[:points]} type="number" label="Points" />
        <footer>
          <.button phx-disable-with="Salvando..." class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-2 rounded-lg shadow-md transition-colors duration-200">
            Registrar Hábito
          </.button>
          <.button navigate={return_path(@return_to, @habit)}>
            Cancel
          </.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    habit = Habits.get_habit!(id)

    socket
    |> assign(:page_title, "Edit Habit")
    |> assign(:habit, habit)
    |> assign(:form, to_form(Habits.change_habit(habit)))
  end

  defp apply_action(socket, :new, _params) do
    habit = %Habit{}

    socket
    |> assign(:page_title, "New Habit")
    |> assign(:habit, habit)
    |> assign(:form, to_form(Habits.change_habit(habit)))
  end

  @impl true
  def handle_event("validate", %{"habit" => habit_params}, socket) do
    changeset = Habits.change_habit(socket.assigns.habit, habit_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"habit" => habit_params}, socket) do
    action = if socket.assigns.habit.id, do: :edit, else: :new

    params_finais =
      if action == :new do
        Map.put(habit_params, "user_id", socket.assigns.current_scope.user.id)
      else
        habit_params
      end

    save_habit(socket, action, params_finais)
  end

  defp save_habit(socket, :edit, habit_params) do
    if socket.assigns.habit.user_id == socket.assigns.current_scope.user.id do
      case Habits.update_habit(socket.assigns.habit, habit_params) do
        {:ok, _habit} ->
          {:noreply,
           socket
           |> put_flash(:info, "Hábito atualizado com sucesso!")
           |> push_navigate(to: ~p"/habits")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "Ação bloqueada: você não tem permissão para editar este hábito.")
       |> push_navigate(to: ~p"/habits")}
    end
  end

  defp save_habit(socket, :new, habit_params) do
    case Habits.create_habit(habit_params) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hábito criado com sucesso!")
         |> push_navigate(to: ~p"/habits")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _habit), do: ~p"/habits"
  defp return_path("show", habit), do: ~p"/habits/#{habit}"
end
