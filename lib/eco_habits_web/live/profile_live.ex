defmodule EcoHabitsWeb.ProfileLive do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Accounts
  alias EcoHabits.Checkins
  alias EcoHabitsWeb.PointHelpers

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    changeset = Accounts.change_user_profile(user)

    # 1. Buscamos os check-ins reais para calcular a pontuação
    checkins = Checkins.list_checkins(socket.assigns.current_scope)
    total_points = PointHelpers.total_points(checkins)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:total_points, total_points) # Assign da pontuação calculada
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user_profile(socket.assigns.user, user_params) do
      {:ok, user} ->
        socket =
          socket
          |> put_flash(:info, "Perfil atualizado com sucesso.")
          |> assign(:user, user)
          |> assign(:form, to_form(Accounts.change_user_profile(user)))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-2xl space-y-6">
        <div class="rounded-xl bg-white p-6 shadow">
          <h1 class="text-2xl font-bold text-gray-900">Meu Perfil</h1>

          <p class="mt-2 text-gray-600">
            Gerencie suas informações pessoais e acompanhe sua pontuação sustentável.
          </p>
        </div>

        <div class="rounded-xl bg-white p-6 shadow">
          <h2 class="text-lg font-semibold text-gray-900">Pontuação total</h2>

          <p class="mt-2 text-4xl font-bold text-green-700">
            {@total_points} pontos
          </p>
        </div>

        <div class="rounded-xl bg-white p-6 shadow">
          <h2 class="text-lg font-semibold text-gray-900">Editar perfil</h2>

          <.form
            for={@form}
            phx-change="validate"
            phx-submit="save"
            class="mt-4 space-y-4"
          >
            <.input
              field={@form[:name]}
              type="text"
              label="Nome"
              required
            />

            <.input
              field={@form[:bio]}
              type="textarea"
              label="Bio"
              placeholder="Conte um pouco sobre seus hábitos sustentáveis..."
            />

            <.button class="btn btn-primary">
              Salvar perfil
            </.button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

end
