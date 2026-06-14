defmodule EcoHabitsWeb.CommunityLive do
  use EcoHabitsWeb, :live_view
  alias EcoHabits.Checkins
  alias EcoHabits.Checkins.Checkin
  alias EcoHabits.Repo
  import EcoHabitsWeb.DateHelpers

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Checkins.subscribe_community()

    # Carregamos e filtramos registros que possam estar incompletos
    checkins =
      Checkin
      |> Repo.all()
      |> Repo.preload([:user, :habit])
      |> Enum.filter(fn c -> c.user && c.habit end) # FILTRO: Remove órfãos
      |> Enum.sort_by(& &1.inserted_at, :desc)
      |> Enum.take(20)

    {:ok,
     socket
     |> assign(:page_title, "Feed da Comunidade")
     |> stream(:checkins, checkins)}
  end

  @impl true
  def handle_info({:checkin_created, checkin}, socket) do
    # Preload imediato do novo check-in
    checkin_completo = Repo.preload(checkin, [:user, :habit])

    # Só insere no feed se os dados estiverem íntegros
    if checkin_completo.user && checkin_completo.habit do
      {:noreply, stream_insert(socket, :checkins, checkin_completo, at: 0)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="p-6 max-w-2xl mx-auto">
        <header class="mb-8">
          <h1 class="text-3xl font-bold text-green-700">Feed da   Comunidade</h1>
          <p class="text-gray-400">Veja o impacto positivo que  estamos gerando juntos!</p>
        </header>
        <div id="community-feed" phx-update="stream" class="space-y-6">
          <%= for {id, checkin} <- @streams.checkins do %>
            <div id={id} class="bg-white p-5 rounded-xl shadow-sm border border-gray-100 flex gap-4 animate-in fade-in slide-in-from-top-4 duration-500" >
              <div class="h-12 w-12 rounded-full bg-green-100 flex items-center justify-center text-green-700 font-bold shrink-0">
                <%= String.at(checkin.user.name, 0) |> String.upcase() %>
              </div>
              <div class="flex-1">
                <div class="flex justify-between items-start">
                  <div>
                    <p class="text-sm font-bold text-gray-900"><%= checkin.user.name %></p>
                    <p class="text-gray-700 mt-1">
                      Praticou:
                      <span class="font-semibold text-green-600"><%= checkin.habit.name %></span>
                    </p>
                  </div>
                  <span class="text-[10px] font-medium text-gray-400 uppercase">
                    <%= format_br_datetime(checkin.inserted_at) %>
                  </span>
                </div>
                <div class="mt-3 flex items-center gap-3">
                  <span class="px-2 py-1 rounded-md bg-gray-50 text-[10px] font-bold text-gray-500 uppercase tracking-wider">
                    <%= checkin.habit.category %>
                  </span>
                  <span class="text-xs font-bold text-green-600">+<%= checkin.habit.points %> pts</span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
