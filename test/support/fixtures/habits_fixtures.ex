defmodule EcoHabits.HabitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EcoHabits.Habits` context.
  """

  @doc """
  Generate a habit.
  """
  def habit_fixture(attrs \\ %{}) do
    {:ok, habit} =
      attrs
      |> Enum.into(%{
        category: "some category",
        description: "some description",
        name: "some name",
        points: 42
      })
      |> EcoHabits.Habits.create_habit()

    habit
  end
end
