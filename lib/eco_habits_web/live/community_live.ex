defmodule EcoHabitsWeb.CommunityLive do
  use EcoHabitsWeb, :live_view
  alias EcoHabits.Checkins
  alias EcoHabits.Checkins.Checkin
  alias EcoHabits.Repo
  import EcoHabitsWeb.DateHelpers

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Checkins.subscribe_community()

    # Carrega os check-ins preenchendo os dados do usuário
    checkins =
      Checkin
      |> EcoHabits.Repo.all()
      |> EcoHabits.Repo.preload(:user) # &lt;--- Importante para ver nomes antigos
      |> Enum.sort_by(& &1.inserted_at, :desc)
      |> Enum.take(20)

    {:ok, assign(socket, checkins: checkins)}
  end

  #def mount(_params, _session, socket) do
  #  if connected?(socket), do: Checkins.subscribe_community()
#
  #  # Carrega checkins iniciais (ajuste para carregar de todos os usuários)
  #  # Por enquanto, listamos os últimos 20 registros do banco
  #  checkins = EcoHabits.Repo.all(EcoHabits.Checkins.Checkin)
  #             |> Enum.sort_by(& &1.inserted_at, :desc)
  #             |> Enum.take(20)
#
  #  {:ok, assign(socket, checkins: checkins)}
  #end

  @impl true
  def handle_info({:checkin_created, checkin}, socket) do
    # Adiciona o novo checkin no topo da lista
    {:noreply, assign(socket, checkins: [checkin | socket.assigns.checkins])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-2xl mx-auto">
      <h1 class="text-2xl font-bold mb-6 text-green-700">Feed da Comunidade</h1>
      <div id="feed" phx-update="prepend" class="space-y-4">
        <%= for checkin <- @checkins do %>
          <div id={"checkin-#{checkin.id}"} class="bg-white p-4 rounded-lg shadow border-l-4 border-green-500 animate-in fade-in slide-in-from-top-4 duration-500">
            <div class="flex justify-between items-start">
              <div>
                <p class="font-bold text-gray-900">
                <%= checkin.user.name %>
                </p>
                <p class="font-bold text-gray-700">Novo Hábito Praticado!</p>
                <p class="text-sm text-gray-600">Hábito #<%= checkin.habit_id %></p>
              </div>
              <span class="text-xs text-gray-400">
                <%= format_br_datetime(checkin.inserted_at) %>
              </span>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
