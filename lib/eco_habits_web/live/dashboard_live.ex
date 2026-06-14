defmodule EcoHabitsWeb.DashboardLive do
  use EcoHabitsWeb, :live_view
  alias EcoHabits.Checkins
  alias EcoHabitsWeb.PointHelpers
  import EcoHabitsWeb.DateHelpers

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="p-6 max-w-7xl mx-auto">
        <header class="mb-8">
          <h1 class="text-3xl font-bold text-green-600">Dashboard de Impacto</h1>
          <p class="text-gray-400">Acompanhe sua jornada rumo a uma vida mais sustentável.</p>
        </header>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <%!-- Card: Contador Total --%>
          <div class="bg-green-600 p-6 rounded-xl shadow-md text-white">
          <h3 class="font-semibold uppercase text-xs tracking-wider opacity-80">Pontuação Total</h3>
          <p class="text-4xl font-black mt-2"><%= @total_points %> pts</p>
        </div>

          <%!-- Card: Distribuição (Lista simples por enquanto) --%>
          <div class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm col-span-2">
            <h3 class="text-gray-500 font-semibold uppercase text-xs mb-4">Distribuição por Categoria</h3>
            <div class="flex gap-4">
              <%= for {name, count} <- @category_data do %>
                <div class="flex-1 bg-gray-50 p-3 rounded-lg text-center">
                  <span class="block text-sm font-medium text-gray-600"><%= name %></span>
                  <span class="text-xl font-bold text-gray-900"><%= count %></span>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <%!-- Lista de Check-ins Recentes --%>
          <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="p-4 border-b border-gray-50 bg-gray-50/50">
              <h3 class="font-bold text-gray-700">Atividades Recentes</h3>
            </div>
            <ul class="divide-y divide-gray-100">
              <%= for checkin <- @recent_checkins do %>
                <li class="p-4 hover:bg-gray-50 transition">
                  <div class="flex justify-between items-center">
                    <div>
                      <span class="font-bold text-gray-800 block"><%=checkin.habit.name %></span>
                      <span class="text-xs text-green-600   font-medium uppercase"><%= checkin.habit.  category %></span>
                    </div>
                    <div class="text-right">
                      <span class="text-sm font-bold text-gray-900  block">+<%= checkin.habit.points %></span>
                      <span class="text-[10px]  text-gray-400"><%= format_br_datetime (checkin.inserted_at) %></span>
                    </div>
                  </div>
                </li>
              <% end %>
            </ul>
          </div>

          <%!-- Espaço para Gráfico Semanal (Placeholder) --%>
          <div class="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
            <h3 class="text-gray-500 font-semibold uppercase text-xs mb-8 text-center">
              Volume de Hábitos por Semana
            </h3>
            <div class="flex items-end justify-around h-48 gap-4 px-4">
              <%= for week <- @weeks_comparison do %>
                <div class="flex-1 flex flex-col items-center gap-3 group relative">
                  <%!-- Barra Semanal --%>
                  <div
                    class="w-full max-w-[60px] bg-green-500 rounded-t-lg transition-all duration-500 hover:bg-green-600"
                    style={"height: #{min(week.count * 5, 180)}px; min-height: 4px;"}
                  >
                    <%!-- Badge com o número exato --%>
                    <span class="absolute -top-7 left-1/2 -translate-x-1/2 text-xs font-bold text-green-700">
                      <%= week.count %>
                    </span>
                  </div>
                  <span class="text-[11px] text-gray-400 font-bold uppercase tracking-tighter">
                    <%= week.label %>
                  </span>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>

    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # Buscamos todos os check-ins do usuário logado
    checkins = Checkins.list_checkins(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Meu Impacto Sustentável")
     |> assign_stats(checkins)
     |> assign_weekly_comparison(checkins)}

  end

  defp assign_stats(socket, checkins) do
    # 1. Contador Total e Pontuação Real
    total_count = length(checkins)
    total_points = PointHelpers.total_points(checkins)
    # 2. Check-ins Recentes (últimos 5)
    recent_checkins = Enum.take(checkins, 5)

    # 3. Distribuição por Categoria Real (vinda do Módulo B)
    category_data =
      checkins
      |> Enum.group_by(fn c -> c.habit.category end)
      |> Enum.map(fn {name, list} -> {name, length(list)} end)

    socket
    |> assign(:total_count, total_count)
    |> assign(:total_points, total_points)
    |> assign(:recent_checkins, recent_checkins)
    |> assign(:category_data, category_data)
  end

  defp assign_weekly_comparison(socket, checkins) do
    hoje = Date.utc_today()

    # Corrigido para 3..0//-1 para evitar avisos de compilação
    weeks_data =
      Enum.map(0..3, fn w ->
        fim = Date.add(hoje, -(w * 7))
        inicio = Date.add(fim, -6)

        count = Enum.count(checkins, fn c ->
          data_c = DateTime.to_date(c.inserted_at)
          Date.compare(data_c, inicio) != :lt and Date.compare(data_c, fim) != :gt
        end)

        label = if w == 0, do: "Atual", else: "Há #{w} sem."
        %{label: label, count: count}
      end) |> Enum.reverse()

    assign(socket, :weeks_comparison, weeks_data)
  end


end
