defmodule EcoHabitsWeb.PageController do
  use EcoHabitsWeb, :controller

  def home(conn, _params) do
    case conn.assigns[:current_scope] do
      %{user: user} when not is_nil(user) ->
        redirect(conn, to: ~p"/profile")

        _->
          redirect(conn, to: ~p"/users/log-in")
    end
  end
end
