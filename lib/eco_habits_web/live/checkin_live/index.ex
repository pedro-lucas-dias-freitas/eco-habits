defmodule EcoHabitsWeb.CheckinLive.Index do
  use EcoHabitsWeb, :live_view
  import EcoHabitsWeb.DateHelpers

  alias EcoHabits.Checkins

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Checkins
        <:actions>
          <.button variant="primary" navigate={~p"/checkins/new"}>
            <.icon name="hero-plus" /> New Checkin
          </.button>
        </:actions>
      </.header>

      <.table
        id="checkins"
        rows={@streams.checkins}
        row_click={fn {_id, checkin} -> JS.navigate(~p"/checkins/#{checkin}") end}
      >
        <:col :let={{_id, checkin}} label="Habit">{checkin.habit_id}</:col>
        <:col :let={{_id, checkin}} label="Data do checkin">{format_simple_datetime(checkin.data_do_checkin)}</:col>
        <:col :let={{_id, checkin}} label="Data do criação do checkin">{format_br_datetime(checkin.inserted_at)}</:col>
        <:col :let={{_id, checkin}} label="Última atualização">{format_br_datetime(checkin.updated_at)}</:col>
        <:action :let={{_id, checkin}}>
          <div class="sr-only">
            <.link navigate={~p"/checkins/#{checkin}"}>Show</.link>
          </div>
          <.link navigate={~p"/checkins/#{checkin}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, checkin}}>
          <.link
            phx-click={JS.push("delete", value: %{id: checkin.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Checkins.subscribe_checkins(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Checkins")
     |> stream(:checkins, list_checkins(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    checkin = Checkins.get_checkin!(socket.assigns.current_scope, id)
    {:ok, _} = Checkins.delete_checkin(socket.assigns.current_scope, checkin)

    {:noreply, stream_delete(socket, :checkins, checkin)}
  end

  @impl true
  def handle_info({type, %EcoHabits.Checkins.Checkin{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :checkins, list_checkins(socket.assigns.current_scope), reset: true)}
  end

  defp list_checkins(current_scope) do
    Checkins.list_checkins(current_scope)
  end
end
