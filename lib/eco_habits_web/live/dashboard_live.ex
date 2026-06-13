defmodule EcoHabitsWeb.DashboardLive do
  use EcoHabitsWeb, :live_view
  alias EcoHabits.Checkins
  import EcoHabitsWeb.DateHelpers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-7xl mx-auto">
      <header class="mb-8">
        <h1 class="text-3xl font-bold text-green-600">Dashboard de Impacto</h1>
        <p class="text-green-400">Acompanhe sua jornada rumo a uma vida mais sustentável.</p>
      </header>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <%!-- Card: Contador Total --%>
        <div class="bg-green-50 p-6 rounded-xl border border-green-100 shadow-sm">
          <h3 class="text-green-800 font-semibold uppercase text-xs tracking-wider">Total de Ações</h3>
          <p class="text-4xl font-black text-green-600 mt-2"><%= @total_count %></p>
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
                  <span class="font-medium text-gray-800">Hábito #<%= checkin.habit_id %></span>
                  <span class="text-sm text-gray-500"><%= format_br_datetime(checkin.updated_at) %></span>
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
       |> assign_weekly_comparison(checkins)} # <--- Adicione esta linha

  end

  defp assign_stats(socket, checkins) do
    # 1. Contador Total
    total_count = length(checkins)

    # 2. Check-ins Recentes (últimos 5)
    recent_checkins = Enum.take(checkins, -5) |> Enum.reverse()

    # 3. Distribuição por Categoria (Mockado conforme os IDs que usamos no Form)
    # Aqui mapeamos os IDs dos hábitos para suas categorias
    category_data =
      checkins
      |> Enum.group_by(fn c -> get_category_name(c.habit_id) end)
      |> Enum.map(fn {name, list} -> {name, length(list)} end)

    # Lógica para o Gráfico Semanal
    #hoje = Date.utc_today()
    #ultimos_7_dias = Enum.map(6..0, fn d -> Date.add(hoje, -d) end)
#
    #weekly_stats =
    #  Enum.map(ultimos_7_dias, fn data ->
    #    count = Enum.count(checkins, fn c ->
    #      DateTime.to_date(c.data_do_checkin) == data
    #    end)
    #    %{date: data, count: count}
    #  end)

    socket
    |> assign(:total_count, total_count)
    |> assign(:recent_checkins, recent_checkins)
    |> assign(:category_data, category_data)
    #|> assign(:weekly_stats, weekly_stats)

  end

  defp assign_weekly_comparison(socket, checkins) do
  hoje = Date.utc_today()

  # Calculamos os totais para as últimas 4 semanas
  weeks_data =
    Enum.map(3..0, fn w ->
      # Define o intervalo da semana (ex: 0 = atual, 1 = anterior...)
      fim = Date.add(hoje, -(w * 7))
      inicio = Date.add(fim, -6)

      count = Enum.count(checkins, fn c ->
        data_c = DateTime.to_date(c.data_do_checkin)
        Date.compare(data_c, inicio) != :lt and Date.compare(data_c, fim) != :gt
      end)

      label = if w == 0, do: "Atual", else: "Há #{w} sem."
      %{label: label, count: count}
    end)

  assign(socket, :weeks_comparison, weeks_data)
end

  # Auxiliar temporário para o Mock
  defp get_category_name(id) when id in [1, 2], do: "Alimentação"
  defp get_category_name(id) when id in [3, 4], do: "Transporte"
  defp get_category_name(_), do: "Outros"
end
