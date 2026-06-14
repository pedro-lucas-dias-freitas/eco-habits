defmodule EcoHabitsWeb.CheckinLive.Show do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Checkins
  alias EcoHabitsWeb.DateHelpers

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Checkin {@checkin.id}
        <:subtitle>This is a checkin record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/checkins"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/checkins/#{@checkin}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit checkin
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Hábito">{@checkin.habit.name}</:item>
        <:item title="Categoria">
          <span class="capitalize">{@checkin.habit.category}</span>
        </:item>
        <:item title="Pontuação Gerada">
          <span class="font-bold text-green-600">+ {@checkin.habit.points} pontos</span>
        </:item>
        <:item title="Realizado em">
          {DateHelpers.format_br_datetime(@checkin.inserted_at)}
        </:item>
        <:item title="Última atualização">
          {DateHelpers.format_br_datetime(@checkin.updated_at)}
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Checkins.subscribe_checkins(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Checkin")
     |> assign(:checkin, Checkins.get_checkin!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %EcoHabits.Checkins.Checkin{id: id} = checkin},
        %{assigns: %{checkin: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :checkin, checkin)}
  end

  def handle_info(
        {:deleted, %EcoHabits.Checkins.Checkin{id: id}},
        %{assigns: %{checkin: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current checkin was deleted.")
     |> push_navigate(to: ~p"/checkins")}
  end

  def handle_info({type, %EcoHabits.Checkins.Checkin{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
