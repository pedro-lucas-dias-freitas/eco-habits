defmodule EcoHabits.CheckinsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EcoHabits.Checkins` context.
  """

  @doc """
  Generate a checkin.
  """
  def checkin_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        data_do_checkin: ~U[2026-06-11 21:10:00Z],
        habit_id: 42
      })

    {:ok, checkin} = EcoHabits.Checkins.create_checkin(scope, attrs)
    checkin
  end
end
