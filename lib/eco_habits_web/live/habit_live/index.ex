defmodule EcoHabitsWeb.HabitLive.Index do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Habits
        <:actions>
          <.button variant="primary" navigate={~p"/habits/new"}>
            <.icon name="hero-plus" /> New Habit
          </.button>
        </:actions>
      </.header>

      <div class="my-6 bg-white p-4 rounded-lg shadow-sm border border-gray-100">
        <form phx-change="filter">
          <.input 
            type="select" 
            name="category" 
            value={@current_filter} 
            options={[
              "Todas as Categorias": "", 
              "Alimentação": "alimentação", 
              "Transporte": "transporte", 
              "Energia": "energia", 
              "Água": "água", 
              "Resíduos": "resíduos"
            ]} 
            label="Filtrar por Categoria" 
          />
        </form>
      </div>
      <.table
        id="habits"
        rows={@streams.habits}
        row_click={fn {_id, habit} -> JS.navigate(~p"/habits/#{habit}") end}
      >
        <:col :let={{_id, habit}} label="Name">{habit.name}</:col>
        <:col :let={{_id, habit}} label="Description">{habit.description}</:col>
        <:col :let={{_id, habit}} label="Category">{habit.category}</:col>
        <:col :let={{_id, habit}} label="Points">{habit.points}</:col>

        <:action :let={{_id, habit}}>
          <div class="sr-only">
            <.link navigate={~p"/habits/#{habit}"}>Show</.link>
          </div>
          
          <%= if habit.user_id == @current_scope.user.id do %>
            <.link navigate={~p"/habits/#{habit}/edit"}>Edit</.link>
          <% end %>
        </:action>
        
        <:action :let={{id, habit}}>
          <%= if habit.user_id == @current_scope.user.id do %>
            <.link
              phx-click={JS.push("delete", value: %{id: habit.id}) |> hide("##{id}")}
              data-confirm="Você tem certeza que deseja excluir?"
            >
              Delete
            </.link>
          <% end %>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Habits")
     |> assign(:current_filter, "")
     |> stream(:habits, Habits.list_habits(""))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    habit = Habits.get_habit!(id)

    if habit.user_id == socket.assigns.current_scope.user.id do
      {:ok, _} = Habits.delete_habit(habit)
      {:noreply, stream_delete(socket, :habits, habit)}
    else
      {:noreply, put_flash(socket, :error, "Ação bloqueada: você só pode excluir os seus próprios hábitos.")}
    end
  end

  @impl true
  def handle_event("filter", %{"category" => category}, socket) do
    habits = Habits.list_habits(category)

    {:noreply, 
     socket
     |> assign(:current_filter, category)
     |> stream(:habits, habits, reset: true)}
  end
end