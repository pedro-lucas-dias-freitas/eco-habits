defmodule EcoHabitsWeb.UserLive.Registration do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Accounts
  alias EcoHabits.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <div class="text-center">
          <.header>
            Register for an account
            <:subtitle>
              Already registered?
              <.link navigate={~p"/users/log-in"} class="font-semibold text-brand hover:underline">
                Log in
              </.link>
              to your account now.
            </:subtitle>
          </.header>
        </div>

     <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
      <.input
        field={@form[:name]}
        type="text"
        label="Nome"
        required
        phx-mounted={JS.focus()}
      />

      <.input
        field={@form[:email]}
        type="email"
        label="E-mail"
        autocomplete="username"
        spellcheck="false"
        required
      />

      <.input
        field={@form[:password]}
        type="password"
        label="Senha"
        autocomplete="new-password"
        required
      />

      <.button phx-disable-with="Criando conta..." class="btn btn-primary w-full">
        Criar conta
      </.button>
    </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: EcoHabitsWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
  changeset = Accounts.change_user_registration(%User{}, %{}, validate_unique: false)

  {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
 def handle_event("save", %{"user" => user_params}, socket) do
  case Accounts.register_user(user_params) do
    {:ok, _user} ->
      {:noreply,
       socket
       |> put_flash(:info, "Conta criada com sucesso. Faça login para continuar.")
       |> push_navigate(to: ~p"/users/log-in")}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign_form(socket, changeset)}
  end
end

  def handle_event("validate", %{"user" => user_params}, socket) do
  changeset = Accounts.change_user_registration(%User{}, user_params, validate_unique: false)
    |> Map.put(:action, :validate)

  {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
