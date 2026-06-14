defmodule EcoHabitsWeb.PageController do
  use EcoHabitsWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/habits")
  end
end