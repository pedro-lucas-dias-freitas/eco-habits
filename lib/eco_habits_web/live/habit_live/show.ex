defmodule EcoHabitsWeb.HabitLive.Show do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Habit {@habit.id}
        <:subtitle>This is a habit record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/habits"}>
            <.icon name="hero-arrow-left" />
          </.button>
          
          <%= if @habit.user_id == @current_scope.user.id do %>
            <.button variant="primary" navigate={~p"/habits/#{@habit}/edit?return_to=show"}>
              <.icon name="hero-pencil-square" /> Edit habit
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@habit.name}</:item>
        <:item title="Description">{@habit.description}</:item>
        <:item title="Category">{@habit.category}</:item>
        <:item title="Points">{@habit.points}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Habit")
     |> assign(:habit, Habits.get_habit!(id))}
  end
end
