defmodule EcoHabitsWeb.PointHelpers do
  @doc """
  Calcula a pontuação total de uma lista de check-ins.
  Espera que a associação :habit esteja carregada em cada check-in.
  """
  def total_points(check_ins) when is_list(check_ins) do
    Enum.reduce(check_ins, 0, fn check_in, acc ->
      acc + (check_in.habit.points || 0)
    end)
  end
end
